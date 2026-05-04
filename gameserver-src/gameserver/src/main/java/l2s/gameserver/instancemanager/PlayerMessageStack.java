package l2s.gameserver.instancemanager;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import l2s.gameserver.Config;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;

public class PlayerMessageStack {
    private static PlayerMessageStack _instance;
    private static final int MAX_MESSAGES_PER_PLAYER = 100;
    private final Map<Integer, List<IBroadcastPacket>> _stack = new LinkedHashMap<Integer, List<IBroadcastPacket>>(256, 0.75f, false) {
        @Override
        protected boolean removeEldestEntry(Map.Entry<Integer, List<IBroadcastPacket>> eldest) {
            int cap = Config.OFFLINE_MESSAGE_STACK_MAX_CHAR_IDS;
            return cap > 0 && size() > cap;
        }
    };

    public static PlayerMessageStack getInstance() {
        if (_instance == null) {
            _instance = new PlayerMessageStack();
        }
        return _instance;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void mailto(int char_obj_id, IBroadcastPacket message) {
        Player cha = GameObjectsStorage.getPlayer(char_obj_id);
        if (cha != null) {
            cha.sendPacket(message);
            return;
        }
        Map<Integer, List<IBroadcastPacket>> map = this._stack;
        synchronized (map) {
            List<IBroadcastPacket> messages = this._stack.containsKey(char_obj_id) ? this._stack.remove(char_obj_id) : new ArrayList<IBroadcastPacket>();
            messages.add(message);
            while (messages.size() > MAX_MESSAGES_PER_PLAYER) {
                messages.remove(0);
            }
            this._stack.put(char_obj_id, messages);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void CheckMessages(Player cha) {
        List<IBroadcastPacket> messages = null;
        Map<Integer, List<IBroadcastPacket>> map = this._stack;
        synchronized (map) {
            if (!this._stack.containsKey(cha.getObjectId())) {
                return;
            }
            messages = this._stack.remove(cha.getObjectId());
        }
        if (messages == null || messages.size() == 0) {
            return;
        }
        for (IBroadcastPacket message : messages) {
            cha.sendPacket(message);
        }
    }

    public void cleanup() {
        synchronized (this._stack) {
            Iterator<Map.Entry<Integer, List<IBroadcastPacket>>> it = this._stack.entrySet().iterator();
            while (it.hasNext()) {
                Map.Entry<Integer, List<IBroadcastPacket>> entry = it.next();
                if (entry.getValue() == null || entry.getValue().isEmpty()) {
                    it.remove();
                }
            }
        }
    }
}
