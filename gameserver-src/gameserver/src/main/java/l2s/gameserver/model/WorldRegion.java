/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model;

import java.util.Iterator;
import java.util.List;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.ObservePoint;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public final class WorldRegion
implements Iterable<GameObject> {
    public static final WorldRegion[] EMPTY_L2WORLDREGION_ARRAY = new WorldRegion[0];
    private final int tileX;
    private final int tileY;
    private final int tileZ;
    private volatile GameObject[] _objects = GameObject.EMPTY_L2OBJECT_ARRAY;
    private int _objectsCount = 0;
    private volatile Zone[] _zones = Zone.EMPTY_L2ZONE_ARRAY;
    private int _playersCount = 0;
    private final AtomicBoolean _isActive = new AtomicBoolean();
    private Future<?> _activateTask;
    private final Lock lock = new ReentrantLock();

    WorldRegion(int x, int y, int z) {
        this.tileX = x;
        this.tileY = y;
        this.tileZ = z;
    }

    int getX() {
        return this.tileX;
    }

    int getY() {
        return this.tileY;
    }

    int getZ() {
        return this.tileZ;
    }

    void setActive(boolean activate) {
        if (!this._isActive.compareAndSet(!activate, activate)) {
            return;
        }
        for (GameObject obj : this) {
            NpcInstance npc;
            if (!obj.isNpc() || (npc = (NpcInstance)obj).getAI().isActive() == this.isActive()) continue;
            if (this.isActive()) {
                npc.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                npc.getAI().startAITask();
                npc.startRandomAnimation();
                continue;
            }
            if (npc.getAI().isGlobalAI()) continue;
            npc.stopRandomAnimation();
            npc.getAI().stopAITask();
            npc.getAI().setIntention(CtrlIntention.AI_INTENTION_IDLE);
        }
    }

    void addToObservers(GameObject object, Creature dropper) {
        if (object == null) {
            return;
        }
        Player player = null;
        if (object.isPlayer()) {
            player = (Player)object;
        } else if (object.isObservePoint()) {
            player = ((ObservePoint)object).getPlayer();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        for (GameObject obj : this) {
            if (obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
            if (player != null) {
                player.sendPacket(player.addVisibleObject(obj, null));
            }
            if (!obj.isPlayer() && !obj.isObservePoint()) continue;
            Player p = obj.getPlayer();
            p.sendPacket(p.addVisibleObject(object, dropper));
        }
    }

    void removeFromObservers(GameObject object) {
        if (object == null) {
            return;
        }
        Player player = null;
        if (object.isPlayer()) {
            player = (Player)object;
        } else if (object.isObservePoint()) {
            player = ((ObservePoint)object).getPlayer();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        List<L2GameServerPacket> d = null;
        for (GameObject obj : this) {
            if (obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
            if (player != null) {
                player.sendPacket(player.removeVisibleObject(obj, null));
            }
            if (obj.isPlayer() || obj.isObservePoint()) {
                Player p = obj.getPlayer();
                p.sendPacket(p.removeVisibleObject(object, d == null ? object.deletePacketList(p) : d));
                continue;
            }
            if (!obj.isNpc()) continue;
            ((NpcInstance)obj).getAI().notifyEvent(CtrlEvent.EVT_FORGET_OBJECT, object);
        }
    }

    void forgetObject(GameObject object) {
        if (object == null) {
            return;
        }
        Player player = null;
        if (object.isPlayer()) {
            player = (Player)object;
        } else if (object.isObservePoint()) {
            player = ((ObservePoint)object).getPlayer();
        }
        int oid = object.getObjectId();
        int rid = object.getReflectionId();
        Object d = null;
        for (GameObject obj : this) {
            if (obj.getObjectId() == oid || obj.getReflectionId() != rid) continue;
            if (player != null) {
                player.getAI().notifyEvent(CtrlEvent.EVT_FORGET_OBJECT, obj);
            }
            if (obj.isPlayer() || obj.isObservePoint()) {
                Player p = obj.getPlayer();
                p.getAI().notifyEvent(CtrlEvent.EVT_FORGET_OBJECT, object);
                continue;
            }
            if (!obj.isNpc()) continue;
            ((NpcInstance)obj).getAI().notifyEvent(CtrlEvent.EVT_FORGET_OBJECT, object);
        }
    }

    
    public void addObject(GameObject obj) {
        if (obj == null) {
            return;
        }
        this.lock.lock();
        try {
            GameObject[] objects = this._objects;
            GameObject[] resizedObjects = new GameObject[this._objectsCount + 1];
            System.arraycopy(objects, 0, resizedObjects, 0, this._objectsCount);
            objects = resizedObjects;
            objects[this._objectsCount++] = obj;
            this._objects = resizedObjects;
            if (obj.isPlayer() && this._playersCount++ == 0) {
                if (this._activateTask != null) {
                    this._activateTask.cancel(false);
                }
                this._activateTask = ThreadPoolManager.getInstance().schedule(new ActivateTask(true), 1000L);
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    
    public void removeObject(GameObject obj) {
        if (obj == null) {
            return;
        }
        this.lock.lock();
        try {
            GameObject[] objects = this._objects;
            int index = -1;
            for (int i = 0; i < this._objectsCount; ++i) {
                if (objects[i] != obj) continue;
                index = i;
                break;
            }
            if (index == -1) {
                return;
            }
            --this._objectsCount;
            GameObject[] resizedObjects = new GameObject[this._objectsCount];
            objects[index] = objects[this._objectsCount];
            System.arraycopy(objects, 0, resizedObjects, 0, this._objectsCount);
            this._objects = resizedObjects;
            if (obj.isPlayer() && --this._playersCount == 0) {
                if (this._activateTask != null) {
                    this._activateTask.cancel(false);
                }
                this._activateTask = ThreadPoolManager.getInstance().schedule(new ActivateTask(false), 60000L);
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public int getObjectsSize() {
        return this._objectsCount;
    }

    public int getPlayersCount() {
        return this._playersCount;
    }

    public boolean isEmpty() {
        return this._playersCount == 0;
    }

    public boolean isActive() {
        return this._isActive.get();
    }

    void addZone(Zone zone) {
        this.lock.lock();
        try {
            this._zones = (Zone[])ArrayUtils.add((Object[])this._zones, (Object)zone);
        }
        finally {
            this.lock.unlock();
        }
    }

    void removeZone(Zone zone) {
        this.lock.lock();
        try {
            this._zones = (Zone[])ArrayUtils.remove((Object[])this._zones, (Object)zone);
        }
        finally {
            this.lock.unlock();
        }
    }

    Zone[] getZones() {
        return this._zones;
    }

    public String toString() {
        return "[" + this.tileX + ", " + this.tileY + ", " + this.tileZ + "]";
    }

    @Override
    public Iterator<GameObject> iterator() {
        return new InternalIterator(this._objects);
    }

    private class InternalIterator
    implements Iterator<GameObject> {
        final GameObject[] objects;
        int cursor = 0;

        public InternalIterator(GameObject[] objects) {
            this.objects = objects;
        }

        @Override
        public boolean hasNext() {
            if (this.cursor < this.objects.length) {
                return this.objects[this.cursor] != null;
            }
            return false;
        }

        @Override
        public GameObject next() {
            return this.objects[this.cursor++];
        }

        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
    }

    public class ActivateTask
    implements Runnable {
        private boolean _isActivating;

        public ActivateTask(boolean isActivating) {
            this._isActivating = isActivating;
        }

        @Override
        public void run() {
            if (this._isActivating) {
                World.activate(WorldRegion.this);
            } else {
                World.deactivate(WorldRegion.this);
            }
        }
    }
}

