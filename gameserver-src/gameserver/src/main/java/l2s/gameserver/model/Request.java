package l2s.gameserver.model;

import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicInteger;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Request
extends MultiValueSet<String> {
    private static final Logger _log = LoggerFactory.getLogger(Request.class);
    private static final AtomicInteger _nextId = new AtomicInteger();
    private final int _id = _nextId.incrementAndGet();
    private L2RequestType _type;
    private HardReference<Player> _requestor;
    private HardReference<Player> _reciever;
    private boolean _isRequestorConfirmed;
    private boolean _isRecieverConfirmed;
    private boolean _isCancelled;
    private boolean _isDone;
    private long _timeout;
    private Future<?> _timeoutTask;

    public Request(L2RequestType type, Player requestor, Player reciever) {
        this._requestor = requestor.getRef();
        this._reciever = reciever != null ? reciever.getRef() : HardReferences.emptyRef();
        this._type = type;
        requestor.setRequest(this);
        if (reciever != null) {
            reciever.setRequest(this);
        }
    }

    public Request setTimeout(long timeout) {
        this._timeout = timeout > 0L ? System.currentTimeMillis() + timeout : 0L;
        this._timeoutTask = ThreadPoolManager.getInstance().schedule(() -> this.timeout(new IBroadcastPacket[0]), timeout);
        return this;
    }

    public int getId() {
        return this._id;
    }

    private void cancel0(IBroadcastPacket ... packets) {
        if (this._timeoutTask != null) {
            this._timeoutTask.cancel(false);
        }
        this._timeoutTask = null;
        Player player = this.getRequestor();
        if (player != null && player.getRequest() == this) {
            player.setRequest(null);
            player.sendPacket(packets);
        }
        if ((player = this.getReciever()) != null && player.getRequest() == this) {
            player.setRequest(null);
            player.sendPacket(packets);
        }
    }

    public void cancel(IBroadcastPacket ... packets) {
        this._isCancelled = true;
        this.cancel0(packets);
    }

    public void done(IBroadcastPacket ... packets) {
        this._isDone = true;
        this.cancel0(packets);
    }

    public void timeout(IBroadcastPacket ... packets) {
        Player player = this.getReciever();
        if (player != null && player.getRequest() == this) {
            player.sendPacket((IBroadcastPacket)SystemMsg.TIME_EXPIRED);
        }
        this.cancel(packets);
    }

    public Player getOtherPlayer(Player player) {
        if (player == this.getRequestor()) {
            return this.getReciever();
        }
        if (player == this.getReciever()) {
            return this.getRequestor();
        }
        return null;
    }

    public Player getRequestor() {
        return (Player)this._requestor.get();
    }

    public Player getReciever() {
        return (Player)this._reciever.get();
    }

    public boolean isInProgress() {
        if (this._isCancelled) {
            return false;
        }
        if (this._isDone) {
            return false;
        }
        if (this._timeout == 0L) {
            return true;
        }
        return this._timeout > System.currentTimeMillis();
    }

    public boolean isTypeOf(L2RequestType type) {
        return this._type == type;
    }

    public void confirm(Player player) {
        if (player == this.getRequestor()) {
            this._isRequestorConfirmed = true;
        } else if (player == this.getReciever()) {
            this._isRecieverConfirmed = true;
        }
    }

    public boolean isConfirmed(Player player) {
        if (player == this.getRequestor()) {
            return this._isRequestorConfirmed;
        }
        if (player == this.getReciever()) {
            return this._isRecieverConfirmed;
        }
        return false;
    }

    public static enum L2RequestType {
        CUSTOM,
        PARTY,
        PARTY_ROOM,
        CLAN,
        CLAN_WAR_START,
        CLAN_WAR_STOP,
        CLAN_WAR_SURRENDER,
        ALLY,
        TRADE,
        TRADE_REQUEST,
        FRIEND,
        CHANNEL,
        DUEL,
        COUPLE_ACTION,
        MENTEE,
        PARTY_MEMBER_SUBSTITUTE;

    }
}

