package l2s.authserver.network.gamecomm;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.CancelledKeyException;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.SocketChannel;
import java.util.ArrayDeque;
import java.util.Queue;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.authserver.Config;
import l2s.authserver.ThreadPoolManager;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.SendablePacket;
import l2s.authserver.network.gamecomm.as2gs.PingRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GameServerConnection {
    private static final Logger _log = LoggerFactory.getLogger(GameServerConnection.class);
    final ByteBuffer readBuffer = ByteBuffer.allocate(65536).order(ByteOrder.LITTLE_ENDIAN);
    final Queue<SendablePacket> sendQueue = new ArrayDeque<SendablePacket>();
    final Lock sendLock = new ReentrantLock();
    final AtomicBoolean isPengingWrite = new AtomicBoolean();
    private final Selector selector;
    private final SelectionKey key;
    private GameServer gameServer;
    private Future<?> _pingTask;
    private int _pingRetry;

    public GameServerConnection(SelectionKey key) {
        this.key = key;
        this.selector = key.selector();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void sendPacket(SendablePacket packet) {
        boolean wakeUp;
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

    protected boolean disableWriteInterest() throws CancelledKeyException {
        if (this.isPengingWrite.compareAndSet(true, false)) {
            this.key.interestOps(this.key.interestOps() & 0xFFFFFFFB);
            return true;
        }
        return false;
    }

    protected boolean enableWriteInterest() throws CancelledKeyException {
        if (!this.isPengingWrite.getAndSet(true)) {
            this.key.interestOps(this.key.interestOps() | 4);
            return true;
        }
        return false;
    }

    public void closeNow() {
        this.key.interestOps(8);
        this.selector.wakeup();
    }

    public void onDisconnection() {
        try {
            this.stopPingTask();
            this.readBuffer.clear();
            this.sendLock.lock();
            try {
                this.sendQueue.clear();
            }
            finally {
                this.sendLock.unlock();
            }
            this.isPengingWrite.set(false);
            if (this.gameServer != null && this.gameServer.isAuthed()) {
                _log.info("Connection with gameserver IP[" + this.getIpAddress() + "] lost.");
                _log.info("Setting gameserver down.");
                this.gameServer.setDown();
            }
            this.gameServer = null;
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
        }
    }

    ByteBuffer getReadBuffer() {
        return this.readBuffer;
    }

    GameServer getGameServer() {
        return this.gameServer;
    }

    void setGameServer(GameServer gameServer) {
        this.gameServer = gameServer;
    }

    public String getIpAddress() {
        return ((SocketChannel)this.key.channel()).socket().getInetAddress().getHostAddress();
    }

    public void onPingResponse() {
        this._pingRetry = 0;
    }

    public void startPingTask() {
        if (Config.GAME_SERVER_PING_DELAY == 0L) {
            return;
        }
        this._pingTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new PingTask(), Config.GAME_SERVER_PING_DELAY, Config.GAME_SERVER_PING_DELAY);
    }

    public void stopPingTask() {
        if (this._pingTask != null) {
            this._pingTask.cancel(false);
            this._pingTask = null;
        }
    }

    private class PingTask
    implements Runnable {
        private PingTask() {
        }

        @Override
        public void run() {
            if (Config.GAME_SERVER_PING_RETRY > 0 && GameServerConnection.this._pingRetry > Config.GAME_SERVER_PING_RETRY) {
                _log.warn("Gameserver IP[" + GameServerConnection.this.getIpAddress() + "]: ping timeout!");
                GameServerConnection.this.closeNow();
                return;
            }
            GameServerConnection.this._pingRetry++;
            GameServerConnection.this.sendPacket(new PingRequest());
        }
    }
}

