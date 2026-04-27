/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.threading.SteppingRunnableQueueManager
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.taskmanager;

import l2s.commons.threading.SteppingRunnableQueueManager;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;

public class AiTaskManager
extends SteppingRunnableQueueManager {
    private static final long TICK = 250L;
    private static int _randomizer;
    private static final AiTaskManager[] _instances;

    public static final AiTaskManager getInstance() {
        return _instances[_randomizer++ & _instances.length - 1];
    }

    private AiTaskManager() {
        super(250L);
        ThreadPoolManager.getInstance().scheduleAtFixedRate((Runnable)((Object)this), Rnd.get((long)250L), 250L);
        ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> this.purge(), 60000L + 1000L * (long)_randomizer++, 60000L);
    }

    public CharSequence getStats(int num) {
        return _instances[num].getStats();
    }

    static {
        _instances = new AiTaskManager[Config.AI_TASK_MANAGER_COUNT];
        for (int i = 0; i < _instances.length; ++i) {
            AiTaskManager._instances[i] = new AiTaskManager();
        }
    }
}

