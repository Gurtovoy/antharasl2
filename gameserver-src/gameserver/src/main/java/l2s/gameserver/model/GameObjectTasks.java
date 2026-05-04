package l2s.gameserver.model;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;

public class GameObjectTasks {

    public static class NotifyAITask
    implements Runnable {
        private final CtrlEvent _evt;
        private final Object _agr0;
        private final Object _agr1;
        private final Object _agr2;
        private final HardReference<? extends Creature> _charRef;

        public NotifyAITask(Creature cha, CtrlEvent evt, Object agr0, Object agr1, Object agr2) {
            this._charRef = cha.getRef();
            this._evt = evt;
            this._agr0 = agr0;
            this._agr1 = agr1;
            this._agr2 = agr2;
        }

        public NotifyAITask(Creature cha, CtrlEvent evt) {
            this(cha, evt, null, null, null);
        }

        @Override
        public void run() {
            Creature character = (Creature)this._charRef.get();
            if (character == null || !character.hasAI()) {
                return;
            }
            character.getAI().notifyEvent(this._evt, this._agr0, this._agr1, this._agr2);
        }
    }

    public static class HitTask
    implements Runnable {
        boolean _crit;
        boolean _miss;
        boolean _shld;
        boolean _soulshot;
        boolean _unchargeSS;
        boolean _notify;
        int _damage;
        int _sAtk;
        private final HardReference<? extends Creature> _charRef;
        private final HardReference<? extends Creature> _targetRef;

        public HitTask(Creature cha, Creature target, int damage, boolean crit, boolean miss, boolean soulshot, boolean shld, boolean unchargeSS, boolean notify, int sAtk) {
            this._charRef = cha.getRef();
            this._targetRef = target.getRef();
            this._damage = damage;
            this._crit = crit;
            this._shld = shld;
            this._miss = miss;
            this._soulshot = soulshot;
            this._unchargeSS = unchargeSS;
            this._notify = notify;
            this._sAtk = sAtk;
        }

        @Override
        public void run() {
            Creature target;
            Creature character = (Creature)this._charRef.get();
            if (character == null || (target = (Creature)this._targetRef.get()) == null) {
                return;
            }
            if (character.isAttackAborted()) {
                return;
            }
            character.onHitTimer(target, this._damage, this._crit, this._miss, this._soulshot, this._shld, this._unchargeSS);
            if (this._notify) {
                ThreadPoolManager.getInstance().schedule(new NotifyAITask(character, CtrlEvent.EVT_READY_TO_ACT), this._sAtk / 2);
            }
        }
    }

    public static class EndBreakFakeDeathTask
    implements Runnable {
        private final HardReference<Player> _playerRef;

        public EndBreakFakeDeathTask(Player player) {
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            player.setFakeDeath(false);
            if (!player.getAI().setNextIntention()) {
                player.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            }
        }
    }

    public static class EndStandUpTask
    implements Runnable {
        private final HardReference<Player> _playerRef;

        public EndStandUpTask(Player player) {
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            player.sittingTaskLaunched = false;
            player.setSitting(false);
            if (!player.getAI().setNextIntention()) {
                player.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            }
        }
    }

    public static class EndSitDownTask
    implements Runnable {
        private final HardReference<Player> _playerRef;

        public EndSitDownTask(Player player) {
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            player.sittingTaskLaunched = false;
            player.getAI().clearNextAction();
        }
    }

    public static class UnJailTask
    implements Runnable {
        private final HardReference<Player> _playerRef;

        public UnJailTask(Player player) {
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            player.fromJail();
        }
    }

    public static class KickTask
    implements Runnable {
        private final HardReference<Player> _playerRef;

        public KickTask(Player player) {
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            player.setOfflineMode(false);
            player.kick();
        }
    }

    public static class WaterTask
    implements Runnable {
        private final HardReference<Player> _playerRef;

        public WaterTask(Player player) {
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            if (player.isDead() || !player.isInWater()) {
                player.stopWaterTask();
                return;
            }
            double reduceHp = player.getMaxHp() < 100 ? 1.0 : (double)(player.getMaxHp() / 100);
            player.reduceCurrentHp(reduceHp, player, null, false, true, true, false, false, false, false);
            player.sendPacket((IBroadcastPacket)new SystemMessage(297).addNumber((long)reduceHp));
        }
    }

    public static class HourlyTask
    implements Runnable {
        private final HardReference<Player> _playerRef;

        public HourlyTask(Player player) {
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            int hoursInGame = player.getHoursInGame().incrementAndGet();
            player.sendPacket((IBroadcastPacket)new SystemMessage(764).addNumber(hoursInGame));
        }
    }

    public static class PvPFlagTask
    implements Runnable {
        private final HardReference<Player> _playerRef;

        public PvPFlagTask(Player player) {
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                return;
            }
            long diff = Math.abs(System.currentTimeMillis() - player.getLastPvPAttack());
            if (diff > (long)Config.PVP_TIME) {
                player.stopPvPFlag();
            } else if (diff > (long)(Config.PVP_TIME - 20000)) {
                player.updatePvPFlag(2);
            } else {
                player.updatePvPFlag(1);
            }
        }
    }

    public static class DeleteTask
    implements Runnable {
        private final HardReference<? extends Creature> _ref;

        public DeleteTask(Creature c) {
            this._ref = c.getRef();
        }

        @Override
        public void run() {
            Creature c = (Creature)this._ref.get();
            if (c != null) {
                c.deleteMe();
            }
        }
    }
}

