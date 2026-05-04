package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_death_link
extends i_abstract_effect {
    public i_death_link(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return !effected.isDead();
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        double lethalDmg;
        Creature realTarget = reflected ? effector : effected;
        Formulas.AttackInfo info = Formulas.calcMagicDam(effector, realTarget, this.getSkill(), this.getValue() * (-(effector.getCurrentHp() * 2.0 / (double)effector.getMaxHp()) + 2.0), this.getSkill().isSSPossible(), false);
        realTarget.reduceCurrentHp(info.damage, effector, this.getSkill(), true, true, false, true, false, false, this.getTemplate().isInstant(), this.getTemplate().isInstant(), info.crit, info.miss, info.shld);
        if (info.damage >= 1.0 && (lethalDmg = Formulas.calcLethalDamage(effector, realTarget, this.getSkill())) > 0.0) {
            realTarget.reduceCurrentHp(lethalDmg, effector, this.getSkill(), true, true, false, false, false, false, false);
        }
    }
}

