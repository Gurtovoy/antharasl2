/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.tick;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.skill.EffectTemplate;

public class t_hp_magic
extends EffectHandler {
    public t_hp_magic(EffectTemplate template) {
        super(template);
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isDead()) {
            return true;
        }
        double hp = this.getValue() * (double)this.getInterval();
        double damage = Formulas.calcMagicDam((Creature)effector, (Creature)effected, (Skill)this.getSkill(), (double)Math.abs((double)hp), (boolean)this.getSkill().isSSPossible(), (boolean)false).damage;
        damage = Math.min(damage, effected.getCurrentHp() - 1.0);
        if (this.getSkill().getAbsorbPart() > 0.0) {
            effector.setCurrentHp(this.getSkill().getAbsorbPart() * Math.min(effected.getCurrentHp(), damage) + effector.getCurrentHp(), false);
        }
        boolean awake = !effected.isNpc() && effected != effector;
        boolean standUp = effected != effector;
        boolean directHp = effector.isNpc() || effected == effector;
        effected.reduceCurrentHp(damage, effector, this.getSkill(), awake, standUp, directHp, false, false, true, false);
        return true;
    }
}

