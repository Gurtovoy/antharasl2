package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.StatsSet;

public class DestroySummon
extends Skill {
    public DestroySummon(StatsSet set) {
        super(set);
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        if (this.getActivateRate() > 0 && !Formulas.calcEffectsSuccess(activeChar, target, this, this.getActivateRate())) {
            activeChar.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_RESISTED_YOUR_S2).addName(target)).addSkillName(this.getId(), this.getLevel()));
            activeChar.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(activeChar.getObjectId(), target.getObjectId(), 6));
            return;
        }
        if (target.isSummon()) {
            ((Servitor)target).unSummon(false);
        }
    }
}

