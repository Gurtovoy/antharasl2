/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.Config;
import l2s.gameserver.model.Creature;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_hp_drain
extends i_abstract_effect {
    private final double _absorbPercent = this.getParams().getDouble("absorb_percent", 0.0);

    public i_hp_drain(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        if (this.getValue() <= 0.0) {
            return false;
        }
        if (!effected.isPlayable() && Config.DISABLE_VAMPIRIC_VS_MOB_ON_PVP) {
            return false;
        }
        return effector.getPvpFlag() == 0;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        Formulas.AttackInfo info;
        Creature realTarget;
        Creature creature = realTarget = reflected ? effector : effected;
        if (realTarget.isDead()) {
            return;
        }
        double targetHp = realTarget.getCurrentHp();
        double targetCP = realTarget.getCurrentCp();
        double damage = 0.0;
        if (this.getSkill().isMagic()) {
            double lethalDmg;
            info = Formulas.calcMagicDam(effector, realTarget, this.getSkill(), this.getValue(), this.getSkill().isSSPossible(), true);
            realTarget.reduceCurrentHp(info.damage, effector, this.getSkill(), true, true, false, true, false, false, true, true, info.crit, info.miss, info.shld);
            if (info.damage >= 1.0 && (lethalDmg = Formulas.calcLethalDamage(effector, realTarget, this.getSkill())) > 0.0) {
                realTarget.reduceCurrentHp(lethalDmg, effector, this.getSkill(), true, true, false, false, false, false, false);
            }
            damage = info.damage;
        } else {
            info = Formulas.calcSkillPDamage(effector, realTarget, this.getSkill(), this.getValue(), false, this.getSkill().isSSPossible());
            if (info != null) {
                realTarget.reduceCurrentHp(info.damage, effector, this.getSkill(), true, true, false, true, false, false, true, true, info.crit || info.blow, info.miss, info.shld);
                if (!info.miss || info.damage >= 1.0) {
                    double lethalDmg = Formulas.calcLethalDamage(effector, realTarget, this.getSkill());
                    if (lethalDmg > 0.0) {
                        realTarget.reduceCurrentHp(lethalDmg, effector, this.getSkill(), true, true, false, false, false, false, false);
                    } else if (!reflected) {
                        realTarget.doCounterAttack(this.getSkill(), effector, false);
                    }
                }
                damage = info.damage;
            }
        }
        if (this._absorbPercent > 0.0 && !effector.isHealBlocked()) {
            double addToHp;
            double hp = 0.0;
            if (damage > targetCP || !realTarget.isPlayer()) {
                hp = (damage - targetCP) * (this._absorbPercent / 100.0);
            }
            if (hp > targetHp) {
                hp = targetHp;
            }
            if ((addToHp = Math.max(0.0, Math.min(hp, effector.getStat().calc(Stats.HP_LIMIT, null, null) * (double)effector.getMaxHp() / 100.0 - effector.getCurrentHp()))) > 0.0) {
                effector.setCurrentHp(effector.getCurrentHp() + addToHp, false);
            }
        }
    }
}

