package l2s.gameserver.handler.onshiftaction;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHandler;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;

public class OnShiftActionHolder
extends AbstractHolder {
    private static final OnShiftActionHolder _instance = new OnShiftActionHolder();
    private Map<Class<?>, OnShiftActionHandler<?>> _handlers = new HashMap();

    public static OnShiftActionHolder getInstance() {
        return _instance;
    }

    public <T> void register(Class<T> clazz, OnShiftActionHandler<T> t) {
        this._handlers.put(clazz, t);
    }

    public <T extends GameObject> boolean callShiftAction(Player player, Class<T> clazz, T obj, boolean select) {
        @SuppressWarnings("unchecked")
        OnShiftActionHandler<T> l = (OnShiftActionHandler<T>)this._handlers.get(clazz);
        if (l == null) {
            return false;
        }
        if (select && player.getTarget() != obj) {
            player.setTarget(obj);
        }
        boolean b = l.call(obj, player);
        player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
        return b;
    }

    public int size() {
        return this._handlers.size();
    }

    public void clear() {
        this._handlers.clear();
    }
}

