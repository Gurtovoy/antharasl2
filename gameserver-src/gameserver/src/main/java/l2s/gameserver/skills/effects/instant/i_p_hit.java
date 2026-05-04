package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_p_hit
extends i_abstract_effect {
    private final boolean _canCrit = this.getParams().getBool("can_critical", false);

    public i_p_hit(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return !effected.isDead();
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        boolean dual = false;
        boolean bow = false;
        switch (effector.getBaseStats().getAttackType()) {
            case DUAL: 
            case DUALFIST: 
            case DUALDAGGER: 
            case DUALBLUNT: {
                dual = true;
                break;
            }
            case BOW: 
            case CROSSBOW: 
            case TWOHANDCROSSBOW: {
                bow = true;
            }
        }
        double power = this.getValue();
        if (dual) {
            power /= 2.0;
        }
        int damage = 0;
        boolean shld = false;
        boolean crit = false;
        Formulas.AttackInfo info = Formulas.calcAutoAttackDamage(effector, effected, power, bow, effector.getChargedSoulshotPower() > 0.0, this._canCrit);
        if (info != null) {
            damage = (int)info.damage;
            shld = info.shld;
            crit = info.crit;
        }
        effected.reduceCurrentHp(damage, effector, null, true, true, false, true, false, false, true, true, crit, false, shld);
        if (dual) {
            damage = 0;
            shld = false;
            crit = false;
            info = Formulas.calcAutoAttackDamage(effector, effected, power, bow, effector.getChargedSoulshotPower() > 0.0, this._canCrit);
            if (info != null) {
                damage = (int)info.damage;
                shld = info.shld;
                crit = info.crit;
            }
            effected.reduceCurrentHp(damage, effector, null, true, true, false, true, false, false, true, true, crit, false, shld);
        }
    }
}

