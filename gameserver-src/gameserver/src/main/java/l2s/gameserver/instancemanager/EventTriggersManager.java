/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.napile.primitive.collections.IntCollection
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.CHashIntObjectMap
 *  org.napile.primitive.sets.IntSet
 *  org.napile.primitive.sets.impl.CArrayIntSet
 */
package l2s.gameserver.instancemanager;

import java.util.Iterator;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.EventTriggerPacket;
import org.napile.primitive.collections.IntCollection;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.sets.IntSet;
import org.napile.primitive.sets.impl.CArrayIntSet;

public class EventTriggersManager {
    private static final EventTriggersManager _instance = new EventTriggersManager();
    private static final int[] EMPTY_INT_ARRAY = new int[0];
    private final IntObjectMap<IntSet> _activeTriggers = new CHashIntObjectMap();
    private final IntObjectMap<IntSet> _activeTriggersByMap = new CHashIntObjectMap();

    public static EventTriggersManager getInstance() {
        return _instance;
    }

    private EventTriggersManager() {
    }

    public boolean addTrigger(Reflection reflection, int triggerId) {
        IntSet triggers = (IntSet)this._activeTriggers.get(reflection.getId());
        if (triggers == null) {
            triggers = new CArrayIntSet();
            this._activeTriggers.put(reflection.getId(), triggers);
        }
        if (triggers.add(triggerId)) {
            this.onAddTrigger(reflection, triggerId);
            return true;
        }
        return false;
    }

    public boolean addTrigger(int mapX, int mapY, int triggerId) {
        IntSet triggers = (IntSet)this._activeTriggersByMap.get(EventTriggersManager.getMapHash(mapX, mapY));
        if (triggers == null) {
            triggers = new CArrayIntSet();
            this._activeTriggersByMap.put(EventTriggersManager.getMapHash(mapX, mapY), triggers);
        }
        if (triggers.add(triggerId)) {
            this.onAddTrigger(ReflectionManager.MAIN, triggerId);
            return true;
        }
        return false;
    }

    public boolean removeTrigger(Reflection reflection, int triggerId) {
        IntSet triggers = (IntSet)this._activeTriggers.get(reflection.getId());
        if (triggers != null && triggers.remove(triggerId)) {
            this.onRemoveTrigger(reflection, triggerId);
            return true;
        }
        return false;
    }

    public boolean removeTrigger(int mapX, int mapY, int triggerId) {
        IntSet triggers = (IntSet)this._activeTriggersByMap.get(EventTriggersManager.getMapHash(mapX, mapY));
        if (triggers != null && triggers.remove(triggerId)) {
            this.onRemoveTrigger(ReflectionManager.MAIN, triggerId);
            return true;
        }
        return false;
    }

    public int[] getTriggers(Reflection reflection, boolean all) {
        if (all && reflection.isMain()) {
            CArrayIntSet allTriggers = new CArrayIntSet();
            IntSet triggers = (IntSet)this._activeTriggers.get(reflection.getId());
            if (triggers != null) {
                allTriggers.addAll((IntCollection)triggers);
            }
            for (IntSet t : this._activeTriggersByMap.valueCollection()) {
                allTriggers.addAll((IntCollection)t);
            }
            return allTriggers.toArray();
        }
        IntSet triggers = (IntSet)this._activeTriggers.get(reflection.getId());
        if (triggers == null) {
            return EMPTY_INT_ARRAY;
        }
        return triggers.toArray();
    }

    public int[] getTriggers(int mapX, int mapY) {
        IntSet triggers = (IntSet)this._activeTriggersByMap.get(EventTriggersManager.getMapHash(mapX, mapY));
        if (triggers == null) {
            return EMPTY_INT_ARRAY;
        }
        return triggers.toArray();
    }

    public void removeTriggers(Reflection reflection) {
        IntSet triggers = (IntSet)this._activeTriggers.remove(reflection.getId());
        if (triggers != null) {
            for (int triggerId : triggers.toArray()) {
                this.onRemoveTrigger(reflection, triggerId);
            }
        }
        if (reflection.isMain()) {
            Iterator<IntSet> object = this._activeTriggersByMap.valueCollection().iterator();
            while (object.hasNext()) {
                IntSet t = object.next();
                for (int triggerId : t.toArray()) {
                    this.onRemoveTrigger(reflection, triggerId);
                }
            }
            this._activeTriggersByMap.clear();
        }
    }

    private void onAddTrigger(Reflection reflection, int triggerId) {
        EventTriggerPacket packet = new EventTriggerPacket(triggerId, true);
        for (Player player : reflection.getPlayers()) {
            player.sendPacket((IBroadcastPacket)packet);
        }
    }

    private void onRemoveTrigger(Reflection reflection, int triggerId) {
        EventTriggerPacket packet = new EventTriggerPacket(triggerId, false);
        for (Player player : reflection.getPlayers()) {
            player.sendPacket((IBroadcastPacket)packet);
        }
    }

    private static int getMapHash(int mapX, int mapY) {
        return mapX * 1000 + mapY;
    }
}

