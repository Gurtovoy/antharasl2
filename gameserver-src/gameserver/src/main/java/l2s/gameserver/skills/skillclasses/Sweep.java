/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import java.util.Set;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

public class Sweep
extends Skill {
    public Sweep(StatsSet set) {
        super(set);
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (this.isNotTargetAoE()) {
            return true;
        }
        if (target == null) {
            return false;
        }
        if (!target.isMonster() || !target.isDead()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return false;
        }
        MonsterInstance monter = (MonsterInstance)target;
        if (monter.isSweeped()) {
            return false;
        }
        if (!monter.isSpoiled()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.SWEEPER_FAILED_TARGET_NOT_SPOILED);
            return false;
        }
        if (!monter.isSpoiled((Player)activeChar)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NO_PRIORITY_RIGHTS_ON_A_SWEEPER);
            return false;
        }
        return true;
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        if (!activeChar.isPlayer()) {
            return;
        }
        if (target == null || !target.isMonster() || !target.isDead()) {
            return;
        }
        MonsterInstance monter = (MonsterInstance)target;
        if (monter.isSweeped() || !monter.isSpoiled()) {
            return;
        }
        Player player = activeChar.getPlayer();
        if (!monter.isSpoiled(player)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NO_PRIORITY_RIGHTS_ON_A_SWEEPER);
            return;
        }
        monter.takeSweep(player);
    }

    @Override
    public void onFinishCast(Creature aimingTarget, Creature activeChar, Set<Creature> targets) {
        for (Creature target : targets) {
            MonsterInstance monter;
            if (!target.isMonster() || !target.isDead() || !(monter = (MonsterInstance)target).isSweeped()) continue;
            monter.endDecayTask();
        }
    }
}

