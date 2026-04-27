/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.set.hash.TIntHashSet
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.skills.skillclasses;

import gnu.trove.set.hash.TIntHashSet;
import java.util.ArrayList;
import java.util.Collections;
import l2s.commons.util.Rnd;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.utils.AbnormalsComparator;

public class StealBuff
extends Skill {
    private final int _stealCount;

    public StealBuff(StatsSet set) {
        super(set);
        this._stealCount = set.getInteger("stealCount", 1);
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (target == null || !target.isPlayer()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            return false;
        }
        return true;
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        if (!target.isPlayer()) {
            return;
        }
        if (this.calcStealChance(target, activeChar)) {
            int stealCount = Rnd.get((int)1, (int)this._stealCount);
            TIntHashSet stelledSkillIds = new TIntHashSet();
            ArrayList<Abnormal> effects = new ArrayList<Abnormal>(target.getAbnormalList().values());
            Collections.sort(effects, AbnormalsComparator.getInstance());
            Collections.reverse(effects);
            for (Abnormal effect : effects) {
                Skill effectSkill;
                if (effect.isOffensive() || !effect.isOfUseType(EffectUseType.NORMAL) || !effect.isCancelable() || (effectSkill = effect.getSkill()) == null || !stelledSkillIds.contains(effectSkill.getId()) && stelledSkillIds.size() < stealCount || effectSkill.isToggle() || effectSkill.isPassive() || target.isSpecialAbnormal(effectSkill)) continue;
                this.stealAbnormal(activeChar, effect);
                effect.exit();
                stelledSkillIds.add(effectSkill.getId());
            }
        } else {
            activeChar.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_RESISTED_YOUR_S2).addName(target)).addSkillName(this.getId(), this.getLevel()));
            activeChar.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(activeChar.getObjectId(), target.getObjectId(), 6));
        }
    }

    private boolean calcStealChance(Creature effected, Creature effector) {
        double cancel_res_multiplier = effected.getStat().calc(Stats.CANCEL_RESIST, 1.0, null, null);
        int dml = effector.getLevel() - effected.getLevel();
        double prelimChance = (double)(dml + 50) * (1.0 - cancel_res_multiplier * 0.01);
        return Rnd.chance((double)prelimChance);
    }

    private void stealAbnormal(Creature character, Abnormal abnormal) {
        Abnormal a = new Abnormal(character, character, abnormal);
        a.setDuration(abnormal.getDuration());
        a.setTimeLeft(abnormal.getTimeLeft());
        character.getAbnormalList().add(a);
    }
}

