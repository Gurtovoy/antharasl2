/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.reference.HardReference
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.taskmanager;

import java.util.ArrayList;
import java.util.Iterator;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.utils.Util;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SpawnTaskManager {
    private static final Logger _log = LoggerFactory.getLogger(SpawnTaskManager.class);
    private SpawnTask[] _spawnTasks = new SpawnTask[500];
    private int _spawnTasksSize = 0;
    private final Object spawnTasks_lock = new Object();
    private static SpawnTaskManager _instance;

    public SpawnTaskManager() {
        ThreadPoolManager.getInstance().scheduleAtFixedRate(new SpawnScheduler(), 2000L, 2000L);
    }

    public static SpawnTaskManager getInstance() {
        if (_instance == null) {
            _instance = new SpawnTaskManager();
        }
        return _instance;
    }

    public void addSpawnTask(NpcInstance actor, long interval) {
        this.removeObject(actor);
        this.addObject(new SpawnTask(actor, System.currentTimeMillis() + interval));
    }

    public String toString() {
        StringBuilder sb = new StringBuilder("============= SpawnTask Manager Report ============\n\r");
        sb.append("Tasks count: ").append(this._spawnTasksSize).append("\n\r");
        sb.append("Tasks dump:\n\r");
        long current = System.currentTimeMillis();
        for (SpawnTask container : this._spawnTasks) {
            sb.append("Class/Name: ").append(container.getClass().getSimpleName()).append('/').append(container.getActor());
            sb.append(" spawn timer: ").append(Util.formatTime((int)(container.endtime - current))).append("\n\r");
        }
        return sb.toString();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void addObject(SpawnTask decay) {
        Object object = this.spawnTasks_lock;
        synchronized (object) {
            if (this._spawnTasksSize >= this._spawnTasks.length) {
                SpawnTask[] temp = new SpawnTask[this._spawnTasks.length * 2];
                for (int i = 0; i < this._spawnTasksSize; ++i) {
                    temp[i] = this._spawnTasks[i];
                }
                this._spawnTasks = temp;
            }
            this._spawnTasks[this._spawnTasksSize] = decay;
            ++this._spawnTasksSize;
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void removeObject(NpcInstance actor) {
        Object object = this.spawnTasks_lock;
        synchronized (object) {
            if (this._spawnTasksSize > 1) {
                int k = -1;
                for (int i = 0; i < this._spawnTasksSize; ++i) {
                    if (this._spawnTasks[i].getActor() != actor) continue;
                    k = i;
                }
                if (k > -1) {
                    this._spawnTasks[k] = this._spawnTasks[this._spawnTasksSize - 1];
                    this._spawnTasks[this._spawnTasksSize - 1] = null;
                    --this._spawnTasksSize;
                }
            } else if (this._spawnTasksSize == 1 && this._spawnTasks[0].getActor() == actor) {
                this._spawnTasks[0] = null;
                this._spawnTasksSize = 0;
            }
        }
    }

    private class SpawnTask {
        private final HardReference<NpcInstance> _npcRef;
        public long endtime;

        SpawnTask(NpcInstance cha, long delay) {
            this._npcRef = cha.getRef();
            this.endtime = delay;
        }

        public NpcInstance getActor() {
            return (NpcInstance)this._npcRef.get();
        }
    }

    public class SpawnScheduler
    implements Runnable {
        /*
         * WARNING - Removed try catching itself - possible behaviour change.
         */
        @Override
        public void run() {
            if (SpawnTaskManager.this._spawnTasksSize > 0) {
                try {
                    ArrayList<NpcInstance> works = new ArrayList<NpcInstance>();
                    Object iterator = SpawnTaskManager.this.spawnTasks_lock;
                    synchronized (iterator) {
                        long current = System.currentTimeMillis();
                        int size = SpawnTaskManager.this._spawnTasksSize;
                        for (int i = size - 1; i >= 0; --i) {
                            try {
                                SpawnTask container = SpawnTaskManager.this._spawnTasks[i];
                                if (container != null && container.endtime > 0L && current > container.endtime) {
                                    NpcInstance actor = container.getActor();
                                    if (actor != null && actor.getSpawn() != null) {
                                        works.add(actor);
                                    }
                                    container.endtime = -1L;
                                }
                                if (container != null && container.getActor() != null && container.endtime >= 0L) continue;
                                if (i == SpawnTaskManager.this._spawnTasksSize - 1) {
                                    ((SpawnTaskManager)SpawnTaskManager.this)._spawnTasks[i] = null;
                                } else {
                                    ((SpawnTaskManager)SpawnTaskManager.this)._spawnTasks[i] = SpawnTaskManager.this._spawnTasks[SpawnTaskManager.this._spawnTasksSize - 1];
                                    ((SpawnTaskManager)SpawnTaskManager.this)._spawnTasks[((SpawnTaskManager)SpawnTaskManager.this)._spawnTasksSize - 1] = null;
                                }
                                if (SpawnTaskManager.this._spawnTasksSize <= 0) continue;
                                SpawnTaskManager.this._spawnTasksSize--;
                                continue;
                            }
                            catch (Exception e) {
                                _log.error("", (Throwable)e);
                            }
                        }
                    }
                    for (NpcInstance work : works) {
                        Spawner spawn = work.getSpawn();
                        if (spawn == null) continue;
                        spawn.decreaseScheduledCount();
                        if (!spawn.isDoRespawn()) continue;
                        spawn.respawnNpc(work);
                    }
                }
                catch (Exception e) {
                    _log.error("", (Throwable)e);
                }
            }
        }
    }
}

