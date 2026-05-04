package l2s.commons.net.nio.impl;

import java.io.IOException;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.CancelledKeyException;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.util.ArrayDeque;
import java.util.Iterator;
import java.util.List;
import java.util.Queue;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.commons.net.nio.impl.IAcceptFilter;
import l2s.commons.net.nio.impl.IClientFactory;
import l2s.commons.net.nio.impl.IMMOExecutor;
import l2s.commons.net.nio.impl.IPacketHandler;
import l2s.commons.net.nio.impl.MMOClient;
import l2s.commons.net.nio.impl.MMOConnection;
import l2s.commons.net.nio.impl.ReceivablePacket;
import l2s.commons.net.nio.impl.SelectorConfig;
import l2s.commons.net.nio.impl.SelectorStats;
import l2s.commons.net.nio.impl.SendablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SelectorThread<T extends MMOClient>
extends Thread {
    private static final Logger _log = LoggerFactory.getLogger(SelectorThread.class);
    private final Selector _selector = Selector.open();
    private final IPacketHandler<T> _packetHandler;
    private final IMMOExecutor<T> _executor;
    private final IClientFactory<T> _clientFactory;
    private final IAcceptFilter _acceptFilter;
    private final SelectorConfig _sc;
    private final int HELPER_BUFFER_SIZE;
    private ByteBuffer DIRECT_WRITE_BUFFER;
    private final ByteBuffer WRITE_BUFFER;
    private final ByteBuffer READ_BUFFER;
    private T WRITE_CLIENT;
    private final Queue<ByteBuffer> _bufferPool;
    private final List<MMOConnection<T>> _connections;
    private final SelectorStats _stats;
    private boolean _shutdown;

    public SelectorThread(SelectorConfig sc, SelectorStats stats, IPacketHandler<T> packetHandler, IMMOExecutor<T> executor, IClientFactory<T> clientFactory, IAcceptFilter acceptFilter) throws IOException {
        this._sc = sc;
        this._stats = stats;
        this._acceptFilter = acceptFilter;
        this._packetHandler = packetHandler;
        this._clientFactory = clientFactory;
        this._executor = executor;
        this._bufferPool = new ArrayDeque<ByteBuffer>(this._sc.HELPER_BUFFER_COUNT);
        this._connections = new CopyOnWriteArrayList<MMOConnection<T>>();
        this.DIRECT_WRITE_BUFFER = ByteBuffer.wrap(new byte[this._sc.WRITE_BUFFER_SIZE]).order(this._sc.BYTE_ORDER);
        this.WRITE_BUFFER = ByteBuffer.wrap(new byte[this._sc.WRITE_BUFFER_SIZE]).order(this._sc.BYTE_ORDER);
        this.READ_BUFFER = ByteBuffer.wrap(new byte[this._sc.READ_BUFFER_SIZE]).order(this._sc.BYTE_ORDER);
        this.HELPER_BUFFER_SIZE = Math.max(this._sc.READ_BUFFER_SIZE, this._sc.WRITE_BUFFER_SIZE);
        for (int i = 0; i < this._sc.HELPER_BUFFER_COUNT; ++i) {
            this._bufferPool.add(ByteBuffer.wrap(new byte[this.HELPER_BUFFER_SIZE]).order(this._sc.BYTE_ORDER));
        }
    }

    public void openServerSocket(InetAddress address, int tcpPort) throws IOException {
        ServerSocketChannel selectable = ServerSocketChannel.open();
        selectable.configureBlocking(false);
        selectable.socket().bind(address == null ? new InetSocketAddress(tcpPort) : new InetSocketAddress(address, tcpPort), this._sc.BACKLOG);
        selectable.register(this.getSelector(), selectable.validOps());
        this.setName("SelectorThread:" + selectable.socket().getLocalPort());
    }

    protected ByteBuffer getPooledBuffer() {
        if (this._bufferPool.isEmpty()) {
            return ByteBuffer.wrap(new byte[this.HELPER_BUFFER_SIZE]).order(this._sc.BYTE_ORDER);
        }
        return this._bufferPool.poll();
    }

    protected void recycleBuffer(ByteBuffer buf) {
        if (this._bufferPool.size() < this._sc.HELPER_BUFFER_COUNT) {
            buf.clear();
            this._bufferPool.add(buf);
        }
    }

    protected void freeBuffer(ByteBuffer buf, MMOConnection<T> con) {
        if (buf == this.READ_BUFFER) {
            this.READ_BUFFER.clear();
        } else {
            con.setReadBuffer(null);
            this.recycleBuffer(buf);
        }
    }

    @Override
    public void run() {
        int totalKeys = 0;
        Set<SelectionKey> keys = null;
        Iterator<SelectionKey> itr = null;
        Iterator<MMOConnection<T>> conItr = null;
        SelectionKey key = null;
        MMOConnection<T> con_ = null;
        long currentMillis = 0L;
        block8: while (true) {
            try {
                block9: while (true) {
                    if (this.isShuttingDown()) {
                        this.closeSelectorThread();
                        break block8;
                    }
                    currentMillis = System.currentTimeMillis();
                    for (MMOConnection<T> con : this._connections) {
                        if (!((MMOClient)con.getClient()).isAuthed() && currentMillis - con.getConnectionOpenTime() >= this._sc.AUTH_TIMEOUT) {
                            this.closeConnectionImpl(con);
                            continue;
                        }
                        if (con.isPengingClose() && (!con.isPendingWrite() || currentMillis - con.getPendingCloseTime() >= this._sc.CLOSEWAIT_TIMEOUT)) {
                            this.closeConnectionImpl(con);
                            continue;
                        }
                        if (!con.isPendingWrite() || currentMillis - con.getPendingWriteTime() < this._sc.INTEREST_DELAY) continue;
                        con.enableWriteInterest();
                    }
                    totalKeys = this.getSelector().selectNow();
                    if (totalKeys > 0) {
                        keys = this.getSelector().selectedKeys();
                        itr = keys.iterator();
                        while (true) {
                            if (!itr.hasNext()) continue block9;
                            key = itr.next();
                            itr.remove();
                            if (!key.isValid()) continue;
                            try {
                                if (key.isAcceptable()) {
                                    this.acceptConnection(key);
                                    continue;
                                }
                                if (key.isConnectable()) {
                                    this.finishConnection(key);
                                    continue;
                                }
                                if (key.isReadable()) {
                                    this.readPacket(key);
                                }
                                if (!key.isValid() || !key.isWritable()) continue;
                                this.writePacket(key);
                            }
                            catch (CancelledKeyException cke) {}
                        }
                    }
                    try {
                        Thread.sleep(this._sc.SLEEP_TIME);
                        continue block8;
                    }
                    catch (InterruptedException ie) {
                        continue;
                    }
                }
            }
            catch (IOException e) {
                _log.error("Error in " + this.getName(), (Throwable)e);
                try {
                    Thread.sleep(1000L);
                }
                catch (InterruptedException ie) {}
                continue;
            }
        }
    }

    protected void finishConnection(SelectionKey key) {
        try {
            ((SocketChannel)key.channel()).finishConnect();
        }
        catch (IOException e) {
            MMOConnection con = (MMOConnection)key.attachment();
            Object client = con.getClient();
            ((MMOConnection)((MMOClient)client).getConnection()).onForcedDisconnection();
            this.closeConnectionImpl((MMOConnection<T>)((MMOClient)client).getConnection());
        }
    }

    protected void acceptConnection(SelectionKey key) {
        ServerSocketChannel ssc = (ServerSocketChannel)key.channel();
        try {
            SocketChannel sc;
            while ((sc = ssc.accept()) != null) {
                if (this.getAcceptFilter() == null || this.getAcceptFilter().accept(sc)) {
                    sc.configureBlocking(false);
                    SelectionKey clientKey = sc.register(this.getSelector(), 1);
                    MMOConnection<T> con = new MMOConnection<T>(this, sc.socket(), clientKey);
                    T client = this.getClientFactory().create(con);
                    ((MMOClient)client).setConnection(con);
                    con.setClient(client);
                    clientKey.attach(con);
                    this._connections.add(con);
                    this._stats.increaseOpenedConnections();
                    continue;
                }
                sc.close();
            }
        }
        catch (IOException e) {
            _log.error("Error in " + this.getName(), (Throwable)e);
        }
    }

    protected void readPacket(SelectionKey key) {
        MMOConnection con = (MMOConnection)key.attachment();
        if (con.isClosed()) {
            return;
        }
        int result = -2;
        ByteBuffer buf = con.getReadBuffer();
        if (buf == null) {
            buf = this.READ_BUFFER;
        }
        if (buf.position() == buf.limit()) {
            _log.error("Read buffer exhausted for client : " + con.getClient() + ", try to adjust buffer size, current : " + buf.capacity() + ", primary : " + (buf == this.READ_BUFFER) + ". Closing connection.");
            this.closeConnectionImpl(con);
        } else {
            try {
                result = con.getReadableByteChannel().read(buf);
            }
            catch (IOException e) {
                // empty catch block
            }
            if (result > 0) {
                buf.flip();
                this._stats.increaseIncomingBytes(result);
                int i = 0;
                while (this.tryReadPacket2(key, con, buf)) {
                    ++i;
                }
            } else if (result == 0) {
                this.closeConnectionImpl(con);
            } else if (result == -1) {
                this.closeConnectionImpl(con);
            } else {
                con.onForcedDisconnection();
                this.closeConnectionImpl(con);
            }
        }
        if (buf == this.READ_BUFFER) {
            buf.clear();
        }
    }

    protected boolean tryReadPacket2(SelectionKey key, MMOConnection<T> con, ByteBuffer buf) {
        if (con.isClosed()) {
            return false;
        }
        int pos = buf.position();
        if (buf.remaining() > this._sc.HEADER_SIZE) {
            int size = buf.getShort() & 0xFFFF;
            if (size <= this._sc.HEADER_SIZE || size > this._sc.PACKET_SIZE) {
                _log.error("Incorrect packet size : " + size + "! Client : " + con.getClient() + ". Closing connection.");
                this.closeConnectionImpl(con);
                return false;
            }
            if ((size -= this._sc.HEADER_SIZE) <= buf.remaining()) {
                this._stats.increaseIncomingPacketsCount();
                this.parseClientPacket(this.getPacketHandler(), buf, size, con);
                buf.position(pos + size + this._sc.HEADER_SIZE);
                if (!buf.hasRemaining()) {
                    this.freeBuffer(buf, con);
                    return false;
                }
                return true;
            }
            buf.position(pos);
        }
        if (pos == buf.capacity()) {
            _log.warn("Read buffer exhausted for client : " + con.getClient() + ", try to adjust buffer size, current : " + buf.capacity() + ", primary : " + (buf == this.READ_BUFFER) + ".");
        }
        if (buf == this.READ_BUFFER) {
            this.allocateReadBuffer(con);
        } else {
            buf.compact();
        }
        return false;
    }

    protected void allocateReadBuffer(MMOConnection<T> con) {
        con.setReadBuffer(this.getPooledBuffer().put(this.READ_BUFFER));
        this.READ_BUFFER.clear();
    }

    protected boolean parseClientPacket(IPacketHandler<T> handler, ByteBuffer buf, int dataSize, MMOConnection<T> con) {
        T client = con.getClient();
        int pos = buf.position();
        ((MMOClient)client).decrypt(buf, dataSize);
        buf.position(pos);
        if (buf.hasRemaining()) {
            int limit = buf.limit();
            buf.limit(pos + dataSize);
            ReceivablePacket<T> rp = handler.handlePacket(buf, client);
            if (rp != null) {
                rp.setByteBuffer(buf);
                rp.setClient(client);
                if (rp.read()) {
                    con.recvPacket(rp);
                }
                rp.setByteBuffer(null);
            }
            buf.limit(limit);
        }
        return true;
    }

    protected void writePacket(SelectionKey key) {
        MMOConnection con = (MMOConnection)key.attachment();
        this.prepareWriteBuffer(con);
        this.DIRECT_WRITE_BUFFER.flip();
        int size = this.DIRECT_WRITE_BUFFER.remaining();
        int result = -1;
        try {
            result = con.getWritableChannel().write(this.DIRECT_WRITE_BUFFER);
        }
        catch (IOException e) {
            // empty catch block
        }
        if (result >= 0) {
            this._stats.increaseOutgoingBytes(result);
            if (result != size) {
                con.createWriteBuffer(this.DIRECT_WRITE_BUFFER);
            }
            if (!con.getSendQueue().isEmpty() || con.hasPendingWriteBuffer()) {
                con.scheduleWriteInterest();
            } else {
                con.disableWriteInterest();
            }
        } else {
            con.onForcedDisconnection();
            this.closeConnectionImpl(con);
        }
    }

    protected T getWriteClient() {
        return this.WRITE_CLIENT;
    }

    protected ByteBuffer getWriteBuffer() {
        return this.WRITE_BUFFER;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    protected void prepareWriteBuffer(MMOConnection<T> con) {
        this.WRITE_CLIENT = con.getClient();
        this.DIRECT_WRITE_BUFFER.clear();
        if (con.hasPendingWriteBuffer()) {
            con.movePendingWriteBufferTo(this.DIRECT_WRITE_BUFFER);
        }
        if (this.DIRECT_WRITE_BUFFER.hasRemaining() && !con.hasPendingWriteBuffer()) {
            Queue<SendablePacket<T>> sendQueue = con.getSendQueue();
            for (int i = 0; i < this._sc.MAX_SEND_PER_PASS; ++i) {
                SendablePacket<T> sp;
                con.lock();
                try {
                    sp = sendQueue.poll();
                    if (sp == null) {
                        break;
                    }
                }
                finally {
                    con.unlock();
                }
                try {
                    this._stats.increaseOutgoingPacketsCount();
                    this.putPacketIntoWriteBuffer(sp, true);
                    this.WRITE_BUFFER.flip();
                    if (this.DIRECT_WRITE_BUFFER.remaining() >= this.WRITE_BUFFER.limit()) {
                        this.DIRECT_WRITE_BUFFER.put(this.WRITE_BUFFER);
                        continue;
                    }
                    con.createWriteBuffer(this.WRITE_BUFFER);
                }
                catch (Exception e) {
                    _log.error("Error in " + this.getName(), (Throwable)e);
                }
                break;
            }
        }
        this.WRITE_BUFFER.clear();
        this.WRITE_CLIENT = null;
    }

    protected final void putPacketIntoWriteBuffer(SendablePacket<T> sp, boolean encrypt) {
        this.WRITE_BUFFER.clear();
        int headerPos = this.WRITE_BUFFER.position();
        this.WRITE_BUFFER.position(headerPos + this._sc.HEADER_SIZE);
        sp.write();
        int dataSize = this.WRITE_BUFFER.position() - headerPos - this._sc.HEADER_SIZE;
        if (dataSize == 0) {
            this.WRITE_BUFFER.position(headerPos);
            return;
        }
        this.WRITE_BUFFER.position(headerPos + this._sc.HEADER_SIZE);
        if (encrypt) {
            ((MMOClient)this.WRITE_CLIENT).encrypt(this.WRITE_BUFFER, dataSize);
            dataSize = this.WRITE_BUFFER.position() - headerPos - this._sc.HEADER_SIZE;
        }
        this.WRITE_BUFFER.position(headerPos);
        this.WRITE_BUFFER.putShort((short)(this._sc.HEADER_SIZE + dataSize));
        this.WRITE_BUFFER.position(headerPos + this._sc.HEADER_SIZE + dataSize);
    }

    protected SelectorConfig getConfig() {
        return this._sc;
    }

    protected Selector getSelector() {
        return this._selector;
    }

    protected IMMOExecutor<T> getExecutor() {
        return this._executor;
    }

    protected IPacketHandler<T> getPacketHandler() {
        return this._packetHandler;
    }

    protected IClientFactory<T> getClientFactory() {
        return this._clientFactory;
    }

    protected IAcceptFilter getAcceptFilter() {
        return this._acceptFilter;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    protected void closeConnectionImpl(MMOConnection<T> con) {
        try {
            con.onDisconnection();
        }
        catch (Throwable throwable) {
            try {
                con.close();
            }
            catch (IOException e) {
                try {
                    con.releaseBuffers();
                    con.clearQueues();
                    ((MMOClient)con.getClient()).setConnection(null);
                    con.getSelectionKey().attach(null);
                    con.getSelectionKey().cancel();
                }
                finally {
                    this._connections.remove(con);
                    this._stats.decreaseOpenedConnections();
                }
            }
            finally {
                try {
                    con.releaseBuffers();
                    con.clearQueues();
                    ((MMOClient)con.getClient()).setConnection(null);
                    con.getSelectionKey().attach(null);
                    con.getSelectionKey().cancel();
                }
                finally {
                    this._connections.remove(con);
                    this._stats.decreaseOpenedConnections();
                }
            }
            throw throwable;
        }
        try {
            con.close();
        }
        catch (IOException iOException) {
            try {
                con.releaseBuffers();
                con.clearQueues();
                ((MMOClient)con.getClient()).setConnection(null);
                con.getSelectionKey().attach(null);
                con.getSelectionKey().cancel();
            }
            finally {
                this._connections.remove(con);
                this._stats.decreaseOpenedConnections();
            }
        }
        finally {
            try {
                con.releaseBuffers();
                con.clearQueues();
                ((MMOClient)con.getClient()).setConnection(null);
                con.getSelectionKey().attach(null);
                con.getSelectionKey().cancel();
            }
            finally {
                this._connections.remove(con);
                this._stats.decreaseOpenedConnections();
            }
        }
    }

    public void shutdown() {
        this._shutdown = true;
    }

    public boolean isShuttingDown() {
        return this._shutdown;
    }

    protected void closeAllChannels() {
        Set<SelectionKey> keys = this.getSelector().keys();
        for (SelectionKey key : keys) {
            try {
                key.channel().close();
            }
            catch (IOException e) {}
        }
    }

    protected void closeSelectorThread() {
        this.closeAllChannels();
        try {
            this.getSelector().close();
        }
        catch (IOException iOException) {
            // empty catch block
        }
    }
}

