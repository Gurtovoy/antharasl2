/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.StatsSet;

public class ChainHeal
extends Skill {
    private final int[] _healPercents;
    private final int _healRadius;
    private final int _maxTargets;

    public ChainHeal(StatsSet set) {
        super(set);
        this._healRadius = set.getInteger("healRadius", 350);
        String[] params = set.getString("healPercents", "").split(";");
        this._maxTargets = params.length;
        this._healPercents = new int[params.length];
        for (int i = 0; i < params.length; ++i) {
            this._healPercents[i] = Integer.parseInt(params[i]);
        }
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (!this.checkMainTarget(activeChar, target)) {
            activeChar.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            return false;
        }
        return true;
    }

    @Override
    public void onEndCast(Creature activeChar, Set<Creature> targets) {
        super.onEndCast(activeChar, targets);
        int curTarget = 0;
        for (Creature target : targets) {
            if (target == null || target.isHealBlocked()) continue;
            double hp = (double)(this._healPercents[curTarget] * target.getMaxHp()) / 100.0;
            double addToHp = Math.max(0.0, Math.min(hp, target.getStat().calc(Stats.HP_LIMIT, null, null) * (double)target.getMaxHp() / 100.0 - target.getCurrentHp()));
            if (addToHp > 0.0) {
                target.setCurrentHp(addToHp + target.getCurrentHp(), false);
            }
            if (target.isPlayer()) {
                if (activeChar != target) {
                    target.sendPacket((IBroadcastPacket)new SystemMessage(1067).addString(activeChar.getName()).addNumber(Math.round(addToHp)));
                } else {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessage(1066).addNumber(Math.round(addToHp)));
                }
            }
            ++curTarget;
        }
    }

    private boolean checkMainTarget(Creature activeChar, Creature target) {
        if (target == null) {
            return false;
        }
        if (activeChar == target) {
            return true;
        }
        if (target.isDoor() || target.isMonster() || activeChar.isAutoAttackable(target)) {
            return false;
        }
        if (target.isPlayer()) {
            Player activeCharTarget = target.getPlayer();
            Player activeCharPlayer = activeChar.getPlayer();
            if (activeCharTarget.isInDuel() && activeCharPlayer.getObjectId() != activeCharTarget.getObjectId() || activeCharPlayer != null && !this.isTargetFriendly(activeCharPlayer, activeCharTarget)) {
                return false;
            }
        }
        return true;
    }

    private boolean isTargetFriendly(Player activeCharPlayer, Player activeCharTarget) {
        return true;
    }

    @Override
    public Set<Creature> getTargets(SkillEntry skillEntry, Creature activeChar, Creature aimingTarget, boolean forceUse) {
        HashSet<Creature> result = new HashSet<Creature>();
        List<Creature> targets = aimingTarget.getAroundCharacters(this._healRadius, 128);
        ArrayList<HealTarget> healTargets = new ArrayList<HealTarget>();
        healTargets.add(new HealTarget(-100.0, aimingTarget));
        Player activeCharPlayer = null;
        if (activeChar.isPlayer()) {
            activeCharPlayer = activeChar.getPlayer();
        }
        if (targets != null && !targets.isEmpty() && (activeCharPlayer != null && !activeCharPlayer.isInDuel() || activeCharPlayer == null)) {
            for (Creature target : targets) {
                Player activeCharTarget;
                Player owner;
                if (target == null || (target.getObjectId() != activeChar.getObjectId() ? target.isDoor() || target.isMonster() || target.isAutoAttackable(activeChar) || target.isAlikeDead() : activeChar.getObjectId() != aimingTarget.getObjectId())) continue;
                if (target.isSummon() || target.isPet() ? (owner = target.getPlayer()) != null && activeCharPlayer != null && !this.isTargetFriendly(activeCharPlayer, owner) && owner.getObjectId() != activeCharPlayer.getObjectId() : target.isPlayer() && ((activeCharTarget = target.getPlayer()).isInDuel() || activeCharPlayer != null && !this.isTargetFriendly(activeCharPlayer, activeCharTarget))) continue;
                double hpPercent = target.getCurrentHp() / (double)target.getMaxHp();
                healTargets.add(new HealTarget(hpPercent, target));
            }
        }
        HealTarget[] healTargetsArr = new HealTarget[healTargets.size()];
        healTargets.toArray(healTargetsArr);
        Arrays.sort(healTargetsArr, (o1, o2) -> {
            if (o1 == null || o2 == null) {
                return 0;
            }
            if (o1.getHpPercent() < o2.getHpPercent()) {
                return -1;
            }
            if (o1.getHpPercent() > o2.getHpPercent()) {
                return 1;
            }
            return 0;
        });
        int targetsCount = 0;
        for (HealTarget ht : healTargetsArr) {
            result.add(ht.getTarget());
            if (++targetsCount >= this._maxTargets) break;
        }
        return result;
    }

    private static class HealTarget {
        private final double hpPercent;
        private final Creature target;

        public HealTarget(double hpPercent, Creature target) {
            this.hpPercent = hpPercent;
            this.target = target;
        }

        public double getHpPercent() {
            return this.hpPercent;
        }

        public Creature getTarget() {
            return this.target;
        }
    }
}

