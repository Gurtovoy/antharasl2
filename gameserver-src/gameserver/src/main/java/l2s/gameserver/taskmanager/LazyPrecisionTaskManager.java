package l2s.gameserver.taskmanager;

import java.util.concurrent.Future;
import l2s.commons.threading.SteppingRunnableQueueManager;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;

public class LazyPrecisionTaskManager
extends SteppingRunnableQueueManager {
    private static final LazyPrecisionTaskManager _instance = new LazyPrecisionTaskManager();

    public static final LazyPrecisionTaskManager getInstance() {
        return _instance;
    }

    private LazyPrecisionTaskManager() {
        super(1000L);
        ThreadPoolManager.getInstance().scheduleAtFixedRate((Runnable)((Object)this), 1000L, 1000L);
        ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> this.purge(), 60000L, 60000L);
    }

    public Future<?> addPCCafePointsTask(Player player) {
        long delay = (long)Config.ALT_PCBANG_POINTS_DELAY * 60000L;
        return this.scheduleAtFixedRate(() -> {
            if (player.isInOfflineMode() || player.getLevel() < Config.ALT_PCBANG_POINTS_MIN_LVL) {
                return;
            }
            if (Config.ALT_PCBANG_POINTS_ONLY_PREMIUM && !player.hasPremiumAccount()) {
                return;
            }
            player.addPcBangPoints(Config.ALT_PCBANG_POINTS_BONUS, Config.ALT_PCBANG_POINTS_BONUS_DOUBLE_CHANCE > 0.0 && Rnd.chance((double)Config.ALT_PCBANG_POINTS_BONUS_DOUBLE_CHANCE), true);
        }, delay, delay);
    }

    public Future<?> startPremiumAccountExpirationTask(Player player, int expire) {
        long delay = (long)expire * 1000L - System.currentTimeMillis();
        return this.schedule(() -> player.removePremiumAccount(), delay);
    }

    public Future<?> addNpcAnimationTask(NpcInstance npc) {
        return this.scheduleAtFixedRate(() -> {
            if (npc.isVisible() && !npc.isActionsDisabled() && !npc.getMovement().isMoving() && !npc.isInCombat()) {
                npc.onRandomAnimation();
            }
        }, 1000L, (long)Rnd.get((int)Config.MIN_NPC_ANIMATION, (int)Config.MAX_NPC_ANIMATION) * 1000L);
    }
}

