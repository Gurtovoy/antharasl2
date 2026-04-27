/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.model.MinionSpawner;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.spawn.SpawnRange;

public class MinionList {
    private final NpcInstance _master;
    private final Lock lock = new ReentrantLock();
    private final Map<MinionData, MinionSpawner> _minionSpawners = new HashMap<MinionData, MinionSpawner>();

    public MinionList(NpcInstance master) {
        this._master = master;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public MinionSpawner addMinion(MinionData minionData) {
        this.lock.lock();
        try {
            if (this._minionSpawners.containsKey(minionData)) {
                MinionSpawner minionSpawner = null;
                return minionSpawner;
            }
            MinionSpawner spawner = new MinionSpawner(minionData, this._master);
            this._minionSpawners.put(minionData, spawner);
            MinionSpawner minionSpawner = spawner;
            return minionSpawner;
        }
        finally {
            this.lock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public MinionSpawner addMinion(int minionId, String ai, int minionCount, int respawnTime) {
        this.lock.lock();
        try {
            MinionData minionData = new MinionData(minionId, ai, minionCount, respawnTime, null);
            MinionSpawner spawner = new MinionSpawner(minionData, this._master);
            this._minionSpawners.put(minionData, spawner);
            MinionSpawner minionSpawner = spawner;
            return minionSpawner;
        }
        finally {
            this.lock.unlock();
        }
    }

    public boolean hasMinions() {
        this.lock.lock();
        try {
            boolean bl = this._minionSpawners.size() > 0;
            return bl;
        }
        finally {
            this.lock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean hasAliveMinions() {
        this.lock.lock();
        try {
            for (MinionSpawner spawner : this._minionSpawners.values()) {
                for (NpcInstance m : spawner.getAllSpawned()) {
                    if (!m.isVisible() || m.isDead()) continue;
                    boolean bl = true;
                    return bl;
                }
            }
        }
        finally {
            this.lock.unlock();
        }
        return false;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public List<NpcInstance> getAliveMinions() {
        ArrayList<NpcInstance> result = new ArrayList<NpcInstance>();
        this.lock.lock();
        try {
            for (MinionSpawner spawner : this._minionSpawners.values()) {
                for (NpcInstance m : spawner.getAllSpawned()) {
                    if (!m.isVisible() || m.isDead()) continue;
                    result.add(m);
                }
            }
        }
        finally {
            this.lock.unlock();
        }
        return result;
    }

    public void spawnMinions() {
        this.lock.lock();
        try {
            for (MinionSpawner spawner : this._minionSpawners.values()) {
                spawner.init();
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public void despawnMinions() {
        this.lock.lock();
        try {
            for (MinionSpawner spawner : this._minionSpawners.values()) {
                spawner.deleteAll();
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public void onMasterDeath() {
        this.lock.lock();
        try {
            if (this._master.isRaid()) {
                this.despawnMinions();
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public void onMasterDelete() {
        this.lock.lock();
        try {
            this.despawnMinions();
            this._minionSpawners.clear();
        }
        finally {
            this.lock.unlock();
        }
    }

    public void onMinionDelete(NpcInstance minion) {
        this.lock.lock();
        try {
            if (!this._master.isVisible() && !this.hasAliveMinions()) {
                Spawner spawn = this._master.getSpawn();
                if (spawn != null) {
                    spawn.decreaseCount(this._master);
                } else {
                    this._master.deleteMe();
                }
            }
        }
        finally {
            this.lock.unlock();
        }
    }

    public SpawnRange getMinionSpawnRange(MinionData minionData) {
        Territory territory = minionData.getTerritory();
        if (territory != null) {
            return territory;
        }
        return this._master.getRndMinionPosition();
    }
}

