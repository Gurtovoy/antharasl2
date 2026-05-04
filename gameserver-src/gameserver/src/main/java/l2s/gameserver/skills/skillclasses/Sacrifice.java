package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.residences.SiegeFlagInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.StatsSet;

public class Sacrifice
extends Skill {
    public Sacrifice(StatsSet set) {
        super(set);
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        return target != null && !target.isDoor() && !(target instanceof SiegeFlagInstance);
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        if (target.isHealBlocked()) {
            return;
        }
        double addToHp = Math.max(0.0, Math.min(this.getPower(), target.getStat().calc(Stats.HP_LIMIT, null, null) * (double)target.getMaxHp() / 100.0 - target.getCurrentHp()));
        if (addToHp > 0.0) {
            target.setCurrentHp(addToHp + target.getCurrentHp(), false);
            if (this.getId() == 4051) {
                target.sendPacket((IBroadcastPacket)SystemMsg.REJUVENATING_HP);
            } else if (target.isPlayer()) {
                if (activeChar == target) {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HP_HAS_BEEN_RESTORED).addInteger(Math.round(addToHp)));
                } else {
                    target.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_HP_HAS_BEEN_RESTORED_BY_C1).addName(activeChar)).addInteger(Math.round(addToHp)));
                }
            }
        }
    }
}

