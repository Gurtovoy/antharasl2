/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.skillclasses;

import l2s.commons.util.Rnd;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.StatsSet;

public class ManaDam
extends Skill {
    public ManaDam(StatsSet set) {
        super(set);
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        if (target.isDead()) {
            return;
        }
        int magicLevel = this.getMagicLevel() == 0 ? activeChar.getLevel() : this.getMagicLevel();
        int landRate = Rnd.get((int)30, (int)100) * target.getLevel() / magicLevel;
        if (Rnd.chance((int)landRate)) {
            double mDef;
            double mAtk = activeChar.getMAtk(target, this);
            if (this.isSSPossible()) {
                mAtk *= (100.0 + activeChar.getChargedSpiritshotPower()) / 100.0;
            }
            if ((mDef = Math.max(1.0, (double)target.getMDef(activeChar, this))) < 1.0) {
                mDef = 1.0;
            }
            double damage = Math.sqrt(mAtk) * this.getPower() * (double)(target.getMaxMp() / 97) / mDef;
            if (Formulas.calcMCrit(activeChar, target, this)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.MAGIC_CRITICAL_HIT);
                damage *= 1.0 + activeChar.getStat().getMul(Stats.MAGIC_CRITICAL_DMG, target, this);
                damage += activeChar.getStat().getAdd(Stats.MAGIC_CRITICAL_DMG, target, this);
            }
            target.reduceCurrentMp(damage, activeChar);
        } else {
            SystemMessagePacket msg = (SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_RESISTED_C2S_MAGIC).addName(target)).addName(activeChar);
            activeChar.sendPacket((IBroadcastPacket)msg);
            target.sendPacket((IBroadcastPacket)msg);
            activeChar.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(activeChar.getObjectId(), target.getObjectId(), 6));
            target.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(activeChar.getObjectId(), target.getObjectId(), 6));
            target.reduceCurrentHp(1.0, activeChar, this, true, true, false, true, false, false, true);
        }
    }
}

