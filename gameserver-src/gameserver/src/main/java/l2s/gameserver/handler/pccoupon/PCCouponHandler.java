package l2s.gameserver.handler.pccoupon;

import l2s.gameserver.handler.pccoupon.IPCCouponHandler;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PCCouponHandler {
    private static final Logger _log = LoggerFactory.getLogger(PCCouponHandler.class);
    private static final PCCouponHandler _instance = new PCCouponHandler();
    private final IntObjectMap<IPCCouponHandler> _handlers = new HashIntObjectMap();

    public static PCCouponHandler getInstance() {
        return _instance;
    }

    private PCCouponHandler() {
    }

    public void registerHandler(IPCCouponHandler handler) {
        if (this._handlers.containsKey(handler.getType())) {
            _log.warn(this.getClass().getSimpleName() + ": dublicate bypass registered! First handler: " + ((IPCCouponHandler)this._handlers.get(handler.getType())).getClass().getSimpleName() + " second: " + handler.getClass().getSimpleName());
            return;
        }
        this._handlers.put(handler.getType(), handler);
    }

    public void removeHandler(IPCCouponHandler handler) {
        if (this._handlers.remove(handler.getType()) != null) {
            _log.info(this.getClass().getSimpleName() + ": " + handler.getClass().getSimpleName() + " unloaded.");
        }
    }

    public IPCCouponHandler getHandler(int type) {
        return (IPCCouponHandler)this._handlers.get(type);
    }
}

