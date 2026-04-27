/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.Config;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.StatsSet;

public class Drain
extends Skill {
    private double _absorbAbs;

    public Drain(StatsSet set) {
        super(set);
        this._absorbAbs = set.getDouble("absorbAbs", 0.0);
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        double addToHp;
        boolean corpseSkill;
        if (!this.canAbsorb(target, activeChar)) {
            return;
        }
        if (this.getPower() <= 0.0 && this._absorbAbs <= 0.0) {
            return;
        }
        Creature realTarget = reflected ? activeChar : target;
        boolean bl = corpseSkill = this.getTargetType() == Skill.SkillTargetType.TARGET_CORPSE || this.getTargetType() == Skill.SkillTargetType.TARGET_AREA_AIM_CORPSE;
        if (realTarget.isDead() && !corpseSkill) {
            return;
        }
        double targetHp = realTarget.getCurrentHp();
        double hp = 0.0;
        if (!corpseSkill) {
            Formulas.AttackInfo info;
            double damage = 0.0;
            if (this.isMagic()) {
                double lethalDmg;
                info = Formulas.calcMagicDam(activeChar, realTarget, this, this.isSSPossible(), !this.isDeathlink());
                realTarget.reduceCurrentHp(info.damage, activeChar, this, true, true, false, true, false, false, true, true, info.crit, info.miss, info.shld);
                if (info.damage >= 1.0 && (lethalDmg = Formulas.calcLethalDamage(activeChar, realTarget, this)) > 0.0) {
                    realTarget.reduceCurrentHp(lethalDmg, activeChar, this, true, true, false, false, false, false, false);
                }
                damage = info.damage;
            } else {
                info = Formulas.calcSkillPDamage(activeChar, realTarget, this, false, this.isSSPossible());
                if (info != null) {
                    realTarget.reduceCurrentHp(info.damage, activeChar, this, true, true, false, true, false, false, true, true, info.crit || info.blow, info.miss, info.shld);
                    if (!info.miss || info.damage >= 1.0) {
                        double lethalDmg = Formulas.calcLethalDamage(activeChar, realTarget, this);
                        if (lethalDmg > 0.0) {
                            realTarget.reduceCurrentHp(lethalDmg, activeChar, this, true, true, false, false, false, false, false);
                        } else if (!reflected) {
                            realTarget.doCounterAttack(this, activeChar, false);
                        }
                    }
                    damage = info.damage;
                }
            }
            double targetCP = realTarget.getCurrentCp();
            if (damage > targetCP || !realTarget.isPlayer()) {
                hp = (damage - targetCP) * this.getAbsorbPart();
            }
        }
        if (this._absorbAbs == 0.0 && this.getAbsorbPart() == 0.0) {
            return;
        }
        if ((hp += this._absorbAbs) > targetHp && !corpseSkill) {
            hp = targetHp;
        }
        if ((addToHp = Math.max(0.0, Math.min(hp, activeChar.getStat().calc(Stats.HP_LIMIT, null, null) * (double)activeChar.getMaxHp() / 100.0 - activeChar.getCurrentHp()))) > 0.0 && !activeChar.isHealBlocked()) {
            activeChar.setCurrentHp(activeChar.getCurrentHp() + addToHp, false);
        }
    }

    private boolean canAbsorb(Creature attacked, Creature attacker) {
        if (attacked.isPlayable() || !Config.DISABLE_VAMPIRIC_VS_MOB_ON_PVP) {
            return true;
        }
        return attacker.getPvpFlag() == 0;
    }
}

