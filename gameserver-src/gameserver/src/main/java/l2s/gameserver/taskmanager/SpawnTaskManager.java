/*
 * This file was originally decompiled from L2S rev.[31495].
 * Refactored: replaced manual array+lock with CopyOnWriteArrayList, fixed singleton thread-safety,
 * removed CFR decompiler artifacts.
 */
package l2s.gameserver.taskmanager;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.utils.Util;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SpawnTaskManager
{
    private static final Logger _log = LoggerFactory.getLogger(SpawnTaskManager.class);

    private static volatile SpawnTaskManager _instance;

    /** Thread-safe list of pending spawn tasks. CopyOnWriteArrayList suits well:
     *  tasks are added/removed rarely, but iterated every 2 seconds by SpawnScheduler. */
    private final CopyOnWriteArrayList<SpawnTask> _spawnTasks = new CopyOnWriteArrayList<>();

    private SpawnTaskManager()
    {
        ThreadPoolManager.getInstance().scheduleAtFixedRate(new SpawnScheduler(), 2000L, 2000L);
    }

    public static SpawnTaskManager getInstance()
    {
        if (_instance == null)
        {
            synchronized (SpawnTaskManager.class)
            {
                if (_instance == null)
                {
                    _instance = new SpawnTaskManager();
                }
            }
        }
        return _instance;
    }

    public void addSpawnTask(NpcInstance actor, long interval)
    {
        removeObject(actor);
        _spawnTasks.add(new SpawnTask(actor, System.currentTimeMillis() + interval));
    }

    public void removeObject(NpcInstance actor)
    {
        _spawnTasks.removeIf(task -> task.getActor() == actor);
    }

    @Override
    public String toString()
    {
        StringBuilder sb = new StringBuilder("============= SpawnTask Manager Report =============\n\r");
        sb.append("Tasks count: ").append(_spawnTasks.size()).append("\n\r");
        sb.append("Tasks dump:\n\r");
        long current = System.currentTimeMillis();
        for (SpawnTask task : _spawnTasks)
        {
            sb.append("Class/Name: ").append(task.getClass().getSimpleName()).append('/').append(task.getActor());
            sb.append(" spawn timer: ").append(Util.formatTime((int)(task.endtime - current))).append("\n\r");
        }
        return sb.toString();
    }

    private static class SpawnTask
    {
        private final HardReference<NpcInstance> _npcRef;
        final long endtime;

        SpawnTask(NpcInstance npc, long endtime)
        {
            this._npcRef = npc.getRef();
            this.endtime = endtime;
        }

        NpcInstance getActor()
        {
            return (NpcInstance) _npcRef.get();
        }
    }

    private class SpawnScheduler implements Runnable
    {
        @Override
        public void run()
        {
            if (_spawnTasks.isEmpty())
            {
                return;
            }
            try
            {
                long current = System.currentTimeMillis();
                List<NpcInstance> toRespawn = new ArrayList<>();

                _spawnTasks.removeIf(task ->
                {
                    if (task == null)
                    {
                        return true;
                    }
                    NpcInstance actor = task.getActor();
                    if (actor == null)
                    {
                        return true;
                    }
                    if (current > task.endtime)
                    {
                        if (actor.getSpawn() != null)
                        {
                            toRespawn.add(actor);
                        }
                        return true;
                    }
                    return false;
                });

                for (NpcInstance npc : toRespawn)
                {
                    try
                    {
                        Spawner spawn = npc.getSpawn();
                        if (spawn == null)
                        {
                            continue;
                        }
                        spawn.decreaseScheduledCount();
                        if (spawn.isDoRespawn())
                        {
                            spawn.respawnNpc(npc);
                        }
                    }
                    catch (Exception e)
                    {
                        _log.error("SpawnTaskManager: error respawning npc", e);
                    }
                }
            }
            catch (Exception e)
            {
                _log.error("SpawnTaskManager: error in SpawnScheduler", e);
            }
        }
    }
}
