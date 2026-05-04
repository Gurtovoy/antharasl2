/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.authcomm;

import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.CancelledKeyException;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;
import java.util.ArrayDeque;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Queue;
import java.util.Set;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.net.HostInfo;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.config.xml.holder.HostsConfigHolder;
import l2s.gameserver.network.authcomm.PacketHandler;
import l2s.gameserver.network.authcomm.ReceivablePacket;
import l2s.gameserver.network.authcomm.SendablePacket;
import l2s.gameserver.network.authcomm.gs2as.AuthRequest;
import l2s.gameserver.network.l2.GameClient;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AuthServerCommunication
extends Thread {
    private static final Logger _log = LoggerFactory.getLogger(AuthServerCommunication.class);
    private static final AuthServerCommunication instance = new AuthServerCommunication();
    private final Map<String, GameClient> waitingClients = new HashMap<String, GameClient>();
    private final Map<String, GameClient> authedClients = new HashMap<String, GameClient>();
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    private final Lock readLock = this.lock.readLock();
    private final Lock writeLock = this.lock.writeLock();
    private final ByteBuffer readBuffer = ByteBuffer.allocate(65536).order(ByteOrder.LITTLE_ENDIAN);
    private final ByteBuffer writeBuffer = ByteBuffer.allocate(65536).order(ByteOrder.LITTLE_ENDIAN);
    private final Queue<SendablePacket> sendQueue = new ArrayDeque<SendablePacket>();
    private final Lock sendLock = new ReentrantLock();
    private final AtomicBoolean isPengingWrite = new AtomicBoolean();
    private SelectionKey key;
    private Selector selector;
    private boolean shutdown;
    private boolean restart;

    public static final AuthServerCommunication getInstance() {
        return instance;
    }

    private AuthServerCommunication() {
        try {
            this.selector = Selector.open();
        }
        catch (IOException e) {
            _log.error("", (Throwable)e);
        }
    }

    private void connect() throws IOException {
        HostInfo hostInfo = HostsConfigHolder.getInstance().getAuthServerHost();
        _log.info("Connecting to authserver on " + hostInfo.getAddress() + ":" + hostInfo.getPort());
        SocketChannel channel = SocketChannel.open();
        channel.configureBlocking(false);
        this.key = channel.register(this.selector, 8);
        channel.connect(new InetSocketAddress(hostInfo.getAddress(), hostInfo.getPort()));
    }

    
    public void sendPacket(SendablePacket packet) {
        boolean wakeUp;
        if (this.isShutdown()) {
            return;
        }
        this.sendLock.lock();
        try {
            this.sendQueue.add(packet);
            wakeUp = this.enableWriteInterest();
        }
        catch (CancelledKeyException e) {
            return;
        }
        finally {
            this.sendLock.unlock();
        }
        if (wakeUp) {
            this.selector.wakeup();
        }
    }

    private boolean disableWriteInterest() throws CancelledKeyException {
        if (this.isPengingWrite.compareAndSet(true, false)) {
            this.key.interestOps(this.key.interestOps() & 0xFFFFFFFB);
            return true;
        }
        return false;
    }

    private boolean enableWriteInterest() throws CancelledKeyException {
        if (!this.isPengingWrite.getAndSet(true)) {
            this.key.interestOps(this.key.interestOps() | 4);
            return true;
        }
        return false;
    }

    protected ByteBuffer getReadBuffer() {
        return this.readBuffer;
    }

    protected ByteBuffer getWriteBuffer() {
        return this.writeBuffer;
    }

    @Override
    public void run() {
        while (!this.shutdown) {
            this.restart = false;
            try {
                int opts;
                SelectionKey key;
                Iterator<SelectionKey> iterator;
                Set<SelectionKey> keys;
                block17: while (!this.isShutdown()) {
                    this.connect();
                    this.selector.select(5000L);
                    keys = this.selector.selectedKeys();
                    if (keys.isEmpty()) {
                        throw new IOException("Connection timeout.");
                    }
                    iterator = keys.iterator();
                    try {
                        while (iterator.hasNext()) {
                            key = iterator.next();
                            iterator.remove();
                            opts = key.readyOps();
                            switch (opts) {
                                case 8: {
                                    this.connect(key);
                                    break block17;
                                }
                            }
                        }
                    }
                    catch (CancelledKeyException e) {
                        // empty catch block
                        break;
                    }
                }
                while (!this.isShutdown()) {
                    this.selector.select();
                    keys = this.selector.selectedKeys();
                    iterator = keys.iterator();
                    try {
                        while (iterator.hasNext()) {
                            key = iterator.next();
                            iterator.remove();
                            opts = key.readyOps();
                            switch (opts) {
                                case 4: {
                                    this.write(key);
                                    break;
                                }
                                case 1: {
                                    this.read(key);
                                    break;
                                }
                                case 5: {
                                    this.write(key);
                                    this.read(key);
                                }
                            }
                        }
                    }
                    catch (CancelledKeyException e) {
                        break;
                    }
                }
            }
            catch (IOException e) {
                _log.error("AuthServer I/O error: " + e.getMessage());
            }
            this.close();
            try {
                Thread.sleep(5000L);
            }
            catch (InterruptedException e) {}
        }
    }

    private void read(SelectionKey key) throws IOException {
        ByteBuffer buf;
        SocketChannel channel = (SocketChannel)key.channel();
        int count = channel.read(buf = this.getReadBuffer());
        if (count == -1) {
            throw new IOException("End of stream.");
        }
        if (count == 0) {
            return;
        }
        buf.flip();
        while (this.tryReadPacket(key, buf)) {
        }
    }

    private boolean tryReadPacket(SelectionKey key, ByteBuffer buf) throws IOException {
        int pos = buf.position();
        if (buf.remaining() > 2) {
            int size = buf.getShort() & 0xFFFF;
            if (size <= 2) {
                throw new IOException("Incorrect packet size: <= 2");
            }
            if ((size -= 2) <= buf.remaining()) {
                int limit = buf.limit();
                buf.limit(pos + size + 2);
                ReceivablePacket rp = PacketHandler.handlePacket(buf);
                if (rp != null && rp.read()) {
                    ThreadPoolManager.getInstance().execute((Runnable)((Object)rp));
                }
                buf.limit(limit);
                buf.position(pos + size + 2);
                if (!buf.hasRemaining()) {
                    buf.clear();
                    return false;
                }
                return true;
            }
            buf.position(pos);
        }
        buf.compact();
        return false;
    }

    
    private void write(SelectionKey key) throws IOException {
        boolean done;
        SocketChannel channel = (SocketChannel)key.channel();
        ByteBuffer buf = this.getWriteBuffer();
        this.sendLock.lock();
        try {
            SendablePacket sp;
            int i = 0;
            while (i++ < 64 && (sp = this.sendQueue.poll()) != null) {
                int headerPos = buf.position();
                buf.position(headerPos + 2);
                sp.write();
                int dataSize = buf.position() - headerPos - 2;
                if (dataSize == 0) {
                    buf.position(headerPos);
                    continue;
                }
                buf.position(headerPos);
                buf.putShort((short)(dataSize + 2));
                buf.position(headerPos + dataSize + 2);
            }
            done = this.sendQueue.isEmpty();
            if (done) {
                this.disableWriteInterest();
            }
        }
        finally {
            this.sendLock.unlock();
        }
        buf.flip();
        channel.write(buf);
        if (buf.remaining() > 0) {
            buf.compact();
            done = false;
        } else {
            buf.clear();
        }
        if (!done && this.enableWriteInterest()) {
            this.selector.wakeup();
        }
    }

    private void connect(SelectionKey key) throws IOException {
        SocketChannel channel = (SocketChannel)key.channel();
        channel.finishConnect();
        key.interestOps(key.interestOps() & 0xFFFFFFF7);
        key.interestOps(key.interestOps() | 1);
        this.sendPacket(new AuthRequest());
    }

    private void close() {
        this.restart = !this.shutdown;
        this.sendLock.lock();
        try {
            this.sendQueue.clear();
        }
        finally {
            this.sendLock.unlock();
        }
        this.readBuffer.clear();
        this.writeBuffer.clear();
        this.isPengingWrite.set(false);
        try {
            if (this.key != null) {
                this.key.channel().close();
                this.key.cancel();
            }
        }
        catch (IOException iOException) {
            // empty catch block
        }
        this.writeLock.lock();
        try {
            this.waitingClients.clear();
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public void shutdown() {
        this.shutdown = true;
        this.selector.wakeup();
    }

    public boolean isShutdown() {
        return this.shutdown || this.restart;
    }

    public void restart() {
        this.restart = true;
        this.selector.wakeup();
    }

    public GameClient addWaitingClient(GameClient client) {
        this.writeLock.lock();
        try {
            GameClient gameClient = this.waitingClients.put(client.getLogin(), client);
            return gameClient;
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public GameClient removeWaitingClient(String account) {
        this.writeLock.lock();
        try {
            GameClient gameClient = this.waitingClients.remove(account);
            return gameClient;
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public GameClient getWaitingClient(String login) {
        this.readLock.lock();
        try {
            GameClient gameClient = this.waitingClients.get(login);
            return gameClient;
        }
        finally {
            this.readLock.unlock();
        }
    }

    
    public List<GameClient> getWaitingClientsByIP(String ip) {
        ArrayList<GameClient> clients = new ArrayList<GameClient>();
        this.readLock.lock();
        try {
            for (GameClient client : this.waitingClients.values()) {
                if (!client.getIpAddr().equalsIgnoreCase(ip)) continue;
                clients.add(client);
            }
        }
        finally {
            this.readLock.unlock();
        }
        return clients;
    }

    
    public List<GameClient> getWaitingClientsByHWID(String hwid) {
        ArrayList<GameClient> clients = new ArrayList<GameClient>();
        if (StringUtils.isEmpty((CharSequence)hwid)) {
            return clients;
        }
        this.readLock.lock();
        try {
            for (GameClient client : this.waitingClients.values()) {
                String h = client.getHWID();
                if (StringUtils.isEmpty((CharSequence)h) || !h.equalsIgnoreCase(hwid)) continue;
                clients.add(client);
            }
        }
        finally {
            this.readLock.unlock();
        }
        return clients;
    }

    public GameClient addAuthedClient(GameClient client) {
        this.writeLock.lock();
        try {
            GameClient gameClient = this.authedClients.put(client.getLogin(), client);
            return gameClient;
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public GameClient removeAuthedClient(String login) {
        this.writeLock.lock();
        try {
            GameClient gameClient = this.authedClients.remove(login);
            return gameClient;
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public GameClient getAuthedClient(String login) {
        this.readLock.lock();
        try {
            GameClient gameClient = this.authedClients.get(login);
            return gameClient;
        }
        finally {
            this.readLock.unlock();
        }
    }

    
    public List<GameClient> getAuthedClientsByIP(String ip) {
        ArrayList<GameClient> clients = new ArrayList<GameClient>();
        this.readLock.lock();
        try {
            for (GameClient client : this.authedClients.values()) {
                if (!client.getIpAddr().equalsIgnoreCase(ip)) continue;
                clients.add(client);
            }
        }
        finally {
            this.readLock.unlock();
        }
        return clients;
    }

    
    public List<GameClient> getAuthedClientsByHWID(String hwid) {
        ArrayList<GameClient> clients = new ArrayList<GameClient>();
        if (StringUtils.isEmpty((CharSequence)hwid)) {
            return clients;
        }
        this.readLock.lock();
        try {
            for (GameClient client : this.authedClients.values()) {
                String h = client.getHWID();
                if (StringUtils.isEmpty((CharSequence)h) || !h.equalsIgnoreCase(hwid)) continue;
                clients.add(client);
            }
        }
        finally {
            this.readLock.unlock();
        }
        return clients;
    }

    public GameClient removeClient(GameClient client) {
        this.writeLock.lock();
        try {
            if (client.isAuthed()) {
                GameClient gameClient = this.authedClients.remove(client.getLogin());
                return gameClient;
            }
            GameClient gameClient = this.waitingClients.remove(client.getLogin());
            return gameClient;
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public String[] getAccounts() {
        this.readLock.lock();
        try {
            String[] stringArray = this.authedClients.keySet().toArray(new String[this.authedClients.size()]);
            return stringArray;
        }
        finally {
            this.readLock.unlock();
        }
    }
}

