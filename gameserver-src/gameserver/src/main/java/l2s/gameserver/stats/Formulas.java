/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats;

import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.GameTimeController;
import l2s.gameserver.data.xml.holder.HitCondBonusHolder;
import l2s.gameserver.data.xml.holder.KarmaIncreaseDataHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.base.BaseStats;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.base.HitCondBonusType;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.BasicProperty;
import l2s.gameserver.skills.BasicPropertyResist;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillTrait;
import l2s.gameserver.skills.SkillTraitType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.utils.PositionUtils;

public class Formulas {
    private static final double CRAFTING_MASTERY_CHANCE = 1.5;

    public static AttackInfo calcAutoAttackDamage(Creature attacker, Creature target, double pAtkMod, boolean range, boolean useShot, boolean canCrit) {
        boolean isPvE;
        double pAtk;
        AttackInfo info = new AttackInfo();
        info.damage = pAtk = (double)attacker.getPAtk(target) * pAtkMod;
        info.defence = target.getPDef(attacker);
        info.crit = canCrit && Formulas.calcPCrit(attacker, target, null, false);
        info.shld = Formulas.calcShldUse(attacker, target);
        info.miss = false;
        info.blow = false;
        boolean isPvP = attacker.isPlayable() && target.isPlayable();
        boolean bl = isPvE = attacker.isPlayable() && target.isNpc();
        if (info.shld) {
            info.defence += (double)target.getShldDef();
        }
        if (info.crit) {
            double critDmg = info.damage;
            critDmg *= 2.0 * attacker.getStat().getMul(Stats.CRITICAL_DAMAGE, target, null);
            critDmg += attacker.getStat().getAdd(Stats.CRITICAL_DAMAGE, target, null);
            critDmg -= info.damage;
            critDmg = target.getStat().calc(Stats.P_CRIT_DAMAGE_RECEPTIVE, critDmg);
            critDmg = Math.max(0.0, critDmg);
            info.damage += critDmg;
        }
        info.damage = range ? (info.damage += Math.max(0.0, Config.LONG_RANGE_AUTO_ATTACK_P_ATK_MOD - 1.0) * pAtk) : (info.damage += Math.max(0.0, Config.SHORT_RANGE_AUTO_ATTACK_P_ATK_MOD - 1.0) * pAtk);
        if (attacker.isDistortedSpace()) {
            info.damage += pAtk * 0.2;
        } else {
            switch (PositionUtils.getDirectionTo(target, attacker)) {
                case BEHIND: {
                    info.damage += pAtk * 0.2;
                    break;
                }
                case SIDE: {
                    info.damage += pAtk * 0.1;
                }
            }
        }
        info.damage *= 1.0 + (Rnd.get() * (double)attacker.getRandomDamage() * 2.0 - (double)attacker.getRandomDamage()) / 100.0;
        if (useShot) {
            info.damage *= (100.0 + attacker.getChargedSoulshotPower()) / 100.0;
        }
        info.damage *= 70.0 / info.defence;
        info.damage *= Formulas.calcAttackTraitBonus(attacker, target);
        info.damage *= Formulas.calcAttributeBonus(attacker, target, null);
        info.damage = attacker.getStat().calc(Stats.INFLICTS_P_DAMAGE_POWER, info.damage, target, null);
        info.damage = target.getStat().calc(Stats.RECEIVE_P_DAMAGE_POWER, info.damage, attacker, null);
        if (info.shld && Rnd.chance((int)Config.EXCELLENT_SHIELD_BLOCK_CHANCE)) {
            info.damage = Config.EXCELLENT_SHIELD_BLOCK_RECEIVED_DAMAGE;
            return info;
        }
        if (isPvP) {
            info.damage *= attacker.getStat().calc(Stats.PVP_PHYS_DMG_BONUS, 1.0);
            info.damage /= target.getStat().calc(Stats.PVP_PHYS_DEFENCE_BONUS, 1.0);
        } else if (isPvE) {
            info.damage *= attacker.getStat().calc(Stats.PVE_PHYS_DMG_BONUS, 1.0);
            info.damage /= target.getStat().calc(Stats.PVE_PHYS_DEFENCE_BONUS, 1.0);
        }
        info.damage = info.crit ? (info.damage *= Formulas.getPCritDamageMode(attacker, true)) : (info.damage *= Formulas.getPDamModifier(attacker));
        return info;
    }

    public static AttackInfo calcSkillPDamage(Creature attacker, Creature target, Skill skill, boolean blow, boolean useShot) {
        return Formulas.calcSkillPDamage(attacker, target, skill, skill.getPower(target), blow, useShot);
    }

    public static AttackInfo calcSkillPDamage(Creature attacker, Creature target, Skill skill, double power, boolean blow, boolean useShot) {
        boolean isPvE;
        double pAtk;
        AttackInfo info = new AttackInfo();
        if (power == 0.0) {
            return info;
        }
        info.damage = pAtk = (double)attacker.getPAtk(target);
        info.defence = target.getPDef(attacker);
        info.blow = blow;
        info.crit = Formulas.calcPCrit(attacker, target, skill, info.blow);
        info.shld = !skill.getShieldIgnore() && Formulas.calcShldUse(attacker, target);
        info.miss = false;
        boolean isPvP = attacker.isPlayable() && target.isPlayable();
        boolean bl = isPvE = attacker.isPlayable() && target.isNpc();
        if (info.shld) {
            double shldDef = target.getShldDef();
            if (skill.getShieldIgnorePercent() > 0.0) {
                shldDef -= shldDef * skill.getShieldIgnorePercent() / 100.0;
            }
            info.defence += shldDef;
        }
        if (skill.getDefenceIgnorePercent() > 0.0) {
            info.defence *= 1.0 - skill.getDefenceIgnorePercent() / 100.0;
        }
        if (info.damage > 0.0 && skill.canBeEvaded() && Rnd.chance((double)(target.getStat().calc(Stats.P_SKILL_EVASION, 100.0, attacker, skill) - 100.0))) {
            info.miss = true;
            info.damage = 0.0;
            return info;
        }
        info.damage *= attacker.getLevelBonus();
        double skillPowerMod = 1.0;
        if (skill.getNumCharges() > 0) {
            skillPowerMod *= attacker.getStat().calc(Stats.CHARGED_P_SKILL_POWER, 1.0);
        }
        info.damage = info.damage + attacker.getStat().calc(Stats.P_SKILL_POWER, (attacker.isServitor() ? Config.SERVITOR_P_SKILL_POWER_MODIFIER : 1.0) * power) * skillPowerMod;
        info.damage += attacker.getStat().calc(Stats.P_SKILL_POWER_STATIC);
        if (!skill.isChargeBoost()) {
            info.damage *= 1.0 + (Rnd.get() * (double)attacker.getRandomDamage() * 2.0 - (double)attacker.getRandomDamage()) / 100.0;
        }
        if (info.blow) {
            double critDmg = info.damage;
            critDmg *= attacker.getStat().getMul(Stats.CRITICAL_DAMAGE, target, skill) * 0.666;
            critDmg += 6.0 * attacker.getStat().getAdd(Stats.CRITICAL_DAMAGE, target, skill);
            critDmg -= info.damage;
            critDmg -= (critDmg - target.getStat().calc(Stats.P_CRIT_DAMAGE_RECEPTIVE, critDmg)) / 2.0;
            critDmg = Math.max(0.0, critDmg);
            info.damage += critDmg;
        }
        if (skill.isChargeBoost()) {
            int force = attacker.getIncreasedForce();
            if (force > 3) {
                force = 3;
            }
            info.damage *= 1.0 + 0.1 * (double)force;
        }
        if (info.crit) {
            if (info.blow) {
                info.damage *= 2.0;
            } else {
                double critDmg = info.damage;
                critDmg *= 2.0 * attacker.getStat().getMul(Stats.SKILL_CRITICAL_DAMAGE, target, skill);
                critDmg += attacker.getStat().getAdd(Stats.SKILL_CRITICAL_DAMAGE, target, null);
                info.damage += (critDmg -= info.damage);
            }
        }
        if (attacker.isDistortedSpace()) {
            info.damage += pAtk * 0.2;
        } else {
            switch (PositionUtils.getDirectionTo(target, attacker)) {
                case BEHIND: {
                    info.damage += pAtk * 0.2;
                    break;
                }
                case SIDE: {
                    info.damage += pAtk * 0.1;
                }
            }
        }
        if (useShot) {
            info.damage *= (100.0 + attacker.getChargedSoulshotPower()) / 100.0;
        }
        info.damage *= 70.0 / info.defence;
        info.damage *= Formulas.calcWeaponTraitBonus(attacker, target);
        info.damage *= Formulas.calcGeneralTraitBonus(attacker, target, skill.getTraitType(), true);
        info.damage *= Formulas.calcAttributeBonus(attacker, target, skill);
        info.damage = attacker.getStat().calc(Stats.INFLICTS_P_DAMAGE_POWER, info.damage, target, skill);
        info.damage = target.getStat().calc(Stats.RECEIVE_P_DAMAGE_POWER, info.damage, attacker, skill);
        if (info.shld && Rnd.chance((int)Config.EXCELLENT_SHIELD_BLOCK_CHANCE)) {
            info.damage = Config.EXCELLENT_SHIELD_BLOCK_RECEIVED_DAMAGE;
            return info;
        }
        if (isPvP) {
            info.damage *= attacker.getStat().calc(Stats.PVP_PHYS_SKILL_DMG_BONUS, 1.0);
            info.damage /= target.getStat().calc(Stats.PVP_PHYS_SKILL_DEFENCE_BONUS, 1.0);
        } else if (isPvE) {
            info.damage *= attacker.getStat().calc(Stats.PVE_PHYS_SKILL_DMG_BONUS, 1.0);
            info.damage /= target.getStat().calc(Stats.PVE_PHYS_SKILL_DEFENCE_BONUS, 1.0);
        }
        if (info.crit) {
            info.damage *= Formulas.getPCritDamageMode(attacker, false);
        }
        if (info.blow) {
            info.damage *= Config.ALT_BLOW_DAMAGE_MOD;
        }
        if (!info.crit && !info.blow) {
            info.damage *= Formulas.getPDamModifier(attacker);
        }
        if (info.damage > 0.0 && skill.isDeathlink()) {
            info.damage = info.damage * (1.8 * ((skill.isPhysic() ? 2.0 : 1.0) - attacker.getCurrentHpRatio()));
        }
        if (!(!info.blow || attacker.getSkillCast(SkillCastingType.NORMAL).isCriticalBlow() && attacker.getSkillCast(SkillCastingType.NORMAL).getSkillEntry().getTemplate().equals(skill) || attacker.getSkillCast(SkillCastingType.NORMAL_SECOND).isCriticalBlow() && attacker.getSkillCast(SkillCastingType.NORMAL_SECOND).getSkillEntry().getTemplate().equals(skill))) {
            return null;
        }
        if (info.damage > 0.0) {
            WeaponTemplate weaponItem = attacker.getActiveWeaponTemplate();
            if (skill.getIncreaseOnPole() > 0.0 && weaponItem != null && weaponItem.getItemType() == WeaponTemplate.WeaponType.POLE) {
                info.damage *= skill.getIncreaseOnPole();
            }
            if (skill.getDecreaseOnNoPole() > 0.0 && weaponItem != null && weaponItem.getItemType() != WeaponTemplate.WeaponType.POLE) {
                info.damage *= skill.getDecreaseOnNoPole();
            }
            if (Formulas.calcStunBreak(info.crit, true, false)) {
                target.getAbnormalList().stop(AbnormalType.STUN);
                target.getAbnormalList().stop(AbnormalType.TURN_FLEE);
            }
            if (Formulas.calcCastBreak(target, info.crit)) {
                target.abortCast(false, true);
            }
            for (Abnormal abnormal : target.getAbnormalList()) {
                double d = info.crit ? abnormal.getSkill().getOnCritCancelChance() : abnormal.getSkill().getOnAttackCancelChance();
                double chance = d;
                if (!(chance > 0.0) || !Rnd.chance((double)chance)) continue;
                abnormal.exit();
            }
        }
        return info;
    }

    public static double calcLethalDamage(Creature attacker, Creature target, Skill skill) {
        if (skill == null) {
            return 0.0;
        }
        if (target.isLethalImmune()) {
            return 0.0;
        }
        double deathRcpt = 0.01 * target.getStat().calc(Stats.DEATH_VULNERABILITY, attacker, skill);
        double lethal1Chance = skill.getLethal1(attacker) * deathRcpt;
        double lethal2Chance = skill.getLethal2(attacker) * deathRcpt;
        double damage = 0.0;
        if (Rnd.chance((double)lethal2Chance)) {
            if (target.isPlayer()) {
                damage = target.getCurrentHp() + target.getCurrentCp() - 1.1;
                target.sendPacket((IBroadcastPacket)SystemMsg.LETHAL_STRIKE);
            } else {
                damage = target.getCurrentHp() - 1.0;
            }
            attacker.sendPacket((IBroadcastPacket)SystemMsg.YOUR_LETHAL_STRIKE_WAS_SUCCESSFUL);
        } else if (Rnd.chance((double)lethal1Chance)) {
            if (target.isPlayer()) {
                damage = target.getCurrentCp();
                target.sendPacket((IBroadcastPacket)SystemMsg.YOUR_CP_WAS_DRAINED_BECAUSE_YOU_WERE_HIT_WITH_A_CP_SIPHON_SKILL);
            } else {
                damage = target.getCurrentHp() / 2.0;
            }
            attacker.sendPacket((IBroadcastPacket)SystemMsg.CP_SIPHON);
        }
        return damage;
    }

    private static double getMSimpleDamageMode(Creature attacker) {
        if (!attacker.isPlayer()) {
            return Config.ALT_M_SIMPLE_DAMAGE_MOD;
        }
        return Config.ALT_M_SIMPLE_DAMAGE_MOD;
    }

    public static double getMCritDamageMode(Creature attacker) {
        if (!attacker.isPlayer()) {
            return Config.ALT_M_CRIT_DAMAGE_MOD;
        }
        return Config.ALT_M_CRIT_DAMAGE_MOD;
    }

    private static double getPDamModifier(Creature attacker) {
        if (!attacker.isPlayer()) {
            return Config.ALT_P_DAMAGE_MOD;
        }
        return Config.ALT_P_DAMAGE_MOD;
    }

    private static double getPCritDamageMode(Creature attacker, boolean notSkill) {
        if (!attacker.isPlayer()) {
            return Config.ALT_P_CRIT_DAMAGE_MOD;
        }
        return Config.ALT_P_CRIT_DAMAGE_MOD;
    }

    private static double getPCritChanceMode(Creature attacker) {
        if (!attacker.isPlayer()) {
            return Config.ALT_P_CRIT_CHANCE_MOD;
        }
        return Config.ALT_P_CRIT_CHANCE_MOD;
    }

    private static double getMCritChanceMode(Creature attacker) {
        if (!attacker.isPlayer()) {
            return Config.ALT_M_CRIT_CHANCE_MOD;
        }
        return Config.ALT_M_CRIT_CHANCE_MOD;
    }

    public static AttackInfo calcMagicDam(Creature attacker, Creature target, Skill skill, boolean useShot, boolean canMiss) {
        return Formulas.calcMagicDam(attacker, target, skill, skill.getPower(target), useShot, canMiss);
    }

    public static AttackInfo calcMagicDam(Creature attacker, Creature target, Skill skill, double power, boolean useShot, boolean canMiss) {
        boolean isPvP = attacker.isPlayable() && target.isPlayable();
        boolean isPvE = attacker.isPlayable() && target.isNpc();
        boolean shield = !skill.getShieldIgnore() && Formulas.calcShldUse(attacker, target);
        double mAtk = attacker.getMAtk(target, skill);
        if (useShot) {
            mAtk *= (100.0 + attacker.getChargedSpiritshotPower()) / 100.0;
        }
        double mdef = target.getMDef(null, skill);
        if (shield) {
            double shldDef = target.getShldDef();
            if (skill.getShieldIgnorePercent() > 0.0) {
                shldDef -= shldDef * skill.getShieldIgnorePercent() / 100.0;
            }
            mdef += shldDef;
        }
        if (skill.getDefenceIgnorePercent() > 0.0) {
            mdef *= 1.0 - skill.getDefenceIgnorePercent() / 100.0;
        }
        mdef = Math.max(mdef, 1.0);
        AttackInfo info = new AttackInfo();
        if (power == 0.0) {
            return info;
        }
        info.damage = 91.0 * power * Math.sqrt(mAtk) / mdef;
        if (target.isTargetUnderDebuff()) {
            info.damage *= skill.getPercentDamageIfTargetDebuff();
        }
        if (canMiss && Formulas.calcMagicHitMiss(skill, attacker, target)) {
            info.miss = true;
            info.damage = 0.0;
            return info;
        }
        info.damage *= 1.0 + (Rnd.get() * (double)attacker.getRandomDamage() * 2.0 - (double)attacker.getRandomDamage()) / 100.0;
        info.damage = info.damage + Math.max(0.0, attacker.getStat().calc(Stats.M_SKILL_POWER, (attacker.isServitor() ? Config.SERVITOR_M_SKILL_POWER_MODIFIER : 1.0) * power));
        info.crit = Formulas.calcMCrit(attacker, target, skill);
        if (info.crit) {
            if (Config.ENABLE_CRIT_DMG_REDUCTION_ON_MAGIC) {
                double critDmg = info.damage;
                critDmg *= 1.0 + attacker.getStat().getMul(Stats.MAGIC_CRITICAL_DMG, target, skill);
                critDmg += attacker.getStat().getAdd(Stats.MAGIC_CRITICAL_DMG, target, skill);
                critDmg *= Formulas.getMCritDamageMode(attacker);
                double tempDamage = target.getStat().calc(Stats.M_CRIT_DAMAGE_RECEPTIVE, critDmg -= info.damage, attacker, skill);
                critDmg = Math.min(tempDamage, critDmg);
                critDmg = Math.max(0.0, critDmg);
                info.damage += critDmg;
            } else {
                info.damage *= 1.0 + attacker.getStat().getMul(Stats.MAGIC_CRITICAL_DMG, target, skill);
                info.damage += attacker.getStat().getAdd(Stats.MAGIC_CRITICAL_DMG, target, skill);
                info.damage *= Formulas.getMCritDamageMode(attacker);
            }
        } else {
            info.damage *= Formulas.getMSimpleDamageMode(attacker);
        }
        info.damage *= Formulas.calcGeneralTraitBonus(attacker, target, skill.getTraitType(), true);
        info.damage *= Formulas.calcAttributeBonus(attacker, target, skill);
        info.damage = attacker.getStat().calc(Stats.INFLICTS_M_DAMAGE_POWER, info.damage, target, skill);
        info.damage = target.getStat().calc(Stats.RECEIVE_M_DAMAGE_POWER, info.damage, attacker, skill);
        if (shield) {
            info.shld = true;
            if (Rnd.chance((int)Config.EXCELLENT_SHIELD_BLOCK_CHANCE)) {
                info.damage = Config.EXCELLENT_SHIELD_BLOCK_RECEIVED_DAMAGE;
                return info;
            }
        }
        int levelDiff = target.getLevel() - attacker.getLevel();
        if (info.damage > 0.0 && skill.isDeathlink()) {
            info.damage *= 1.8 * (1.0 - attacker.getCurrentHpRatio());
        }
        if (info.damage > 0.0 && skill.isBasedOnTargetDebuff()) {
            info.damage *= 1.0 + 0.05 * (double)target.getAbnormalList().size();
        }
        if (skill.getSkillType() == Skill.SkillType.MANADAM) {
            info.damage = Math.max(1.0, info.damage / 4.0);
        } else if (info.damage > 0.0) {
            if (isPvP) {
                info.damage *= attacker.getStat().calc(Stats.PVP_MAGIC_SKILL_DMG_BONUS, 1.0);
                info.damage /= target.getStat().calc(Stats.PVP_MAGIC_SKILL_DEFENCE_BONUS, 1.0);
            } else if (isPvE) {
                info.damage *= attacker.getStat().calc(Stats.PVE_MAGIC_SKILL_DMG_BONUS, 1.0);
                info.damage /= target.getStat().calc(Stats.PVE_MAGIC_SKILL_DEFENCE_BONUS, 1.0);
            }
        }
        double magic_rcpt = target.getStat().calc(Stats.MAGIC_RESIST, attacker, skill) - attacker.getStat().calc(Stats.MAGIC_POWER, target, skill);
        double failChance = 4.0 * Math.max(1.0, (double)levelDiff) * (1.0 + magic_rcpt / 100.0);
        if (Rnd.chance((double)failChance)) {
            SystemMessagePacket msg;
            if (levelDiff > 9) {
                info.damage = 0.0;
                msg = (SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_RESISTED_C2S_MAGIC).addName(target)).addName(attacker);
                attacker.sendPacket((IBroadcastPacket)msg);
                target.sendPacket((IBroadcastPacket)msg);
                attacker.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(attacker.getObjectId(), target.getObjectId(), 6));
                target.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(attacker.getObjectId(), target.getObjectId(), 6));
            } else {
                info.damage /= 2.0;
                msg = (SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.DAMAGE_IS_DECREASED_BECAUSE_C1_RESISTED_C2S_MAGIC).addName(target)).addName(attacker);
                attacker.sendPacket((IBroadcastPacket)msg);
                target.sendPacket((IBroadcastPacket)msg);
            }
        }
        if (Formulas.calcCastBreak(target, info.crit)) {
            target.abortCast(false, true);
        }
        if (Formulas.calcStunBreak(info.crit, true, true) && info.damage > 0.0) {
            target.getAbnormalList().stop(AbnormalType.STUN);
        }
        for (Abnormal abnormal : target.getAbnormalList()) {
            double d = info.crit ? abnormal.getSkill().getOnCritCancelChance() : abnormal.getSkill().getOnAttackCancelChance();
            double chance = d;
            if (!(chance > 0.0) || !Rnd.chance((double)chance)) continue;
            abnormal.exit();
        }
        return info;
    }

    public static boolean calcStunBreak(boolean crit, boolean isSkill, boolean isMagic) {
        if (!Config.ENABLE_STUN_BREAK_ON_ATTACK) {
            return false;
        }
        if (isSkill) {
            if (isMagic) {
                return Rnd.chance((double)(crit ? Config.CRIT_STUN_BREAK_CHANCE_ON_MAGICAL_SKILL : Config.NORMAL_STUN_BREAK_CHANCE_ON_MAGICAL_SKILL));
            }
            return Rnd.chance((double)(crit ? Config.CRIT_STUN_BREAK_CHANCE_ON_PHYSICAL_SKILL : Config.NORMAL_STUN_BREAK_CHANCE_ON_PHYSICAL_SKILL));
        }
        return Rnd.chance((double)(crit ? Config.CRIT_STUN_BREAK_CHANCE_ON_REGULAR_HIT : Config.NORMAL_STUN_BREAK_CHANCE_ON_REGULAR_HIT));
    }

    public static boolean calcBlow(Creature activeChar, Creature target, Skill skill) {
        double vulnMod = target.getStat().calc(Stats.BLOW_RESIST, activeChar, skill);
        double profMod = activeChar.getStat().calc(Stats.BLOW_POWER, target, skill);
        if (vulnMod == Double.POSITIVE_INFINITY || profMod == Double.NEGATIVE_INFINITY) {
            return false;
        }
        if (vulnMod == Double.NEGATIVE_INFINITY || profMod == Double.POSITIVE_INFINITY) {
            return true;
        }
        WeaponTemplate weapon = activeChar.getActiveWeaponTemplate();
        double base_weapon_crit = weapon == null ? 4.0 : (double)weapon.getCritical();
        double crit_height_bonus = 1.0;
        if (Config.ENABLE_CRIT_HEIGHT_BONUS) {
            crit_height_bonus = 0.008 * (double)Math.min(25, Math.max(-25, target.getZ() - activeChar.getZ())) + 1.1;
        }
        double buffs_mult = activeChar.getStat().calc(Stats.FATALBLOW_RATE, target, skill);
        double skill_mod = skill.isBehind() ? Config.BLOW_SKILL_CHANCE_MOD_ON_BEHIND : Config.BLOW_SKILL_CHANCE_MOD_ON_FRONT;
        double chance = base_weapon_crit * buffs_mult * crit_height_bonus * skill_mod;
        double modDiff = profMod - vulnMod;
        if (modDiff != 1.0) {
            chance *= 1.0 + (80.0 + modDiff) / 200.0;
        }
        if (!target.isInCombat()) {
            chance *= 1.1;
        }
        if (activeChar.isDistortedSpace()) {
            chance *= 1.3;
        } else {
            switch (PositionUtils.getDirectionTo(target, activeChar)) {
                case BEHIND: {
                    chance *= 1.3;
                    break;
                }
                case SIDE: {
                    chance *= 1.1;
                    break;
                }
                case FRONT: {
                    if (!skill.isBehind()) break;
                    chance = 3.0;
                }
            }
        }
        chance = Math.min(skill.isBehind() ? Config.MAX_BLOW_RATE_ON_BEHIND : Config.MAX_BLOW_RATE_ON_FRONT_AND_SIDE, chance);
        return Rnd.chance((double)chance);
    }

    public static boolean calcPCrit(Creature attacker, Creature target, Skill skill, boolean blow) {
        boolean debugTarget;
        if (skill != null) {
            boolean debugTarget2;
            double statModifier;
            boolean dexDep = attacker.getStat().calc(Stats.P_SKILL_CRIT_RATE_DEX_DEPENDENCE) > 0.0;
            double skillCritRate = skill.getCriticalRate();
            double skillCritChanceMod = attacker.getStat().calc(Stats.P_SKILL_CRITICAL_RATE, 1.0, target, skill);
            double pCritChanceMode = Formulas.getPCritChanceMode(attacker);
            double critRate = skillCritRate * skillCritChanceMod * pCritChanceMode * 10.0;
            double blowCritModifier = Config.ALT_BLOW_CRIT_RATE_MODIFIER;
            double finalRate = critRate;
            if (dexDep) {
                statModifier = BaseStats.DEX.calcBonus(attacker);
                statModifier = blow ? (statModifier *= Config.BLOW_SKILL_DEX_CHANCE_MOD) : (statModifier *= Config.NORMAL_SKILL_DEX_CHANCE_MOD);
            } else {
                statModifier = BaseStats.STR.calcBonus(attacker);
            }
            finalRate *= statModifier;
            if (blow) {
                finalRate *= blowCritModifier;
            }
            boolean result = finalRate > (double)Rnd.get((int)1000);
            boolean debugCaster = attacker.getPlayer() != null && attacker.getPlayer().isDebug();
            boolean bl = debugTarget2 = target.getPlayer() != null && target.getPlayer().isDebug();
            if (debugCaster || debugTarget2) {
                StringBuilder stat = new StringBuilder(100);
                stat.append("'" + attacker.getName() + "' p. skill crit chance debug: ");
                stat.append(skill.getName());
                stat.append("\ndexDep: ");
                stat.append(dexDep);
                stat.append("\nskillCritRate: ");
                stat.append(String.format("%1.3f", skillCritRate));
                stat.append("\nskillCritChanceMod: ");
                stat.append(String.format("%1.3f", skillCritChanceMod));
                stat.append("\npCritChanceMode: ");
                stat.append(String.format("%1.3f", pCritChanceMode));
                stat.append("\ncritRate: ");
                stat.append(String.format("%1.3f", critRate));
                stat.append("\nblowCritModifier: ");
                stat.append(String.format("%1.3f", blowCritModifier));
                stat.append("\nstatModifier: ");
                stat.append(String.format("%1.3f", statModifier));
                stat.append("\nfinalRate: ");
                stat.append(String.format("%1.3f", finalRate));
                if (result) {
                    stat.append("\nResult: success");
                } else {
                    stat.append("\nResult: failed");
                }
                if (debugCaster) {
                    attacker.getPlayer().sendMessage(stat.toString());
                }
                if (debugTarget2) {
                    target.getPlayer().sendMessage(stat.toString());
                }
            }
            return result;
        }
        double pCriticalHit = attacker.getPCriticalHit(target);
        double pCritChanceReceptive = target.getStat().calc(Stats.P_CRIT_CHANCE_RECEPTIVE, attacker, skill) * 0.01;
        double pCritChanceMode = Formulas.getPCritChanceMode(attacker);
        double critRate = pCriticalHit * pCritChanceReceptive * pCritChanceMode;
        double criticalHeightBonus = Formulas.calcCriticalHeightBonus(attacker, target);
        double directionRate = 1.0;
        if (attacker.isDistortedSpace()) {
            directionRate *= 1.4;
        } else {
            switch (PositionUtils.getDirectionTo(target, attacker)) {
                case BEHIND: {
                    directionRate *= 1.4;
                    break;
                }
                case SIDE: {
                    directionRate *= 1.2;
                }
            }
        }
        double levelDiffChanceAdd = 0.0;
        if (attacker.getLevel() >= 78 || target.getLevel() >= 78) {
            levelDiffChanceAdd = Math.sqrt(attacker.getLevel()) * (double)(attacker.getLevel() - target.getLevel()) * 0.125;
        }
        double finalRate = (critRate + levelDiffChanceAdd) * directionRate / 10.0;
        finalRate = Math.min(Math.max(finalRate, 3.0), 97.0);
        boolean result = Rnd.chance((double)finalRate);
        boolean debugCaster = attacker.getPlayer() != null && attacker.getPlayer().isDebug();
        boolean bl = debugTarget = target.getPlayer() != null && target.getPlayer().isDebug();
        if (debugCaster || debugTarget) {
            StringBuilder stat = new StringBuilder(100);
            stat.append("'" + attacker.getName() + "' p. attack crit chance debug: ");
            stat.append("\npCriticalHit: ");
            stat.append(String.format("%1.3f", pCriticalHit));
            stat.append("\npCritChanceReceptive: ");
            stat.append(String.format("%1.3f", pCritChanceReceptive));
            stat.append("\npCritChanceMode: ");
            stat.append(String.format("%1.3f", pCritChanceMode));
            stat.append("\ncritRate: ");
            stat.append(String.format("%1.3f", critRate));
            stat.append("\ncriticalHeightBonus: ");
            stat.append(String.format("%1.3f", criticalHeightBonus));
            stat.append("\ndirectionRate: ");
            stat.append(String.format("%1.3f", directionRate));
            stat.append("\nlevelDiffChanceAdd: ");
            stat.append(String.format("%1.3f", levelDiffChanceAdd));
            stat.append("\nfinalRate: ");
            stat.append(String.format("%1.3f", finalRate));
            if (result) {
                stat.append("\nResult: success");
            } else {
                stat.append("\nResult: failed");
            }
            if (debugCaster) {
                attacker.getPlayer().sendMessage(stat.toString());
            }
            if (debugTarget) {
                target.getPlayer().sendMessage(stat.toString());
            }
        }
        return result;
    }

    public static double calcCriticalHeightBonus(Creature from, Creature target) {
        return (Math.min(Math.max(from.getZ() - target.getZ(), -25), 25) * 4 / 5 + 10) / 100 + 1;
    }

    public static boolean calcMCrit(Creature attacker, Creature target, Skill skill) {
        boolean debugTarget;
        double critRate;
        double mCriticalHit = attacker.getMCriticalHit(target, skill);
        double skillCriticalRateMod = skill.getCriticalRateMod();
        double mCritChanceMode = Formulas.getMCritChanceMode(attacker);
        if (target == null || !skill.isDebuff()) {
            double critRate2 = mCriticalHit * skillCriticalRateMod * mCritChanceMode;
            return Math.min(critRate2, 320.0) > (double)Rnd.get((int)1000);
        }
        double mCritChanceReceptive = target.getStat().calc(Stats.M_CRIT_CHANCE_RECEPTIVE, attacker, skill) * 0.01;
        double finalRate = critRate = mCriticalHit * skillCriticalRateMod * mCritChanceMode * mCritChanceReceptive;
        double levelDiffChanceAdd = 0.0;
        if (attacker.getLevel() >= 78 && target.getLevel() >= 78) {
            levelDiffChanceAdd = Math.sqrt(attacker.getLevel()) + (double)((attacker.getLevel() - target.getLevel()) / 25);
            finalRate += levelDiffChanceAdd;
            finalRate = Math.min(finalRate, 320.0);
        } else {
            finalRate = Math.min(finalRate, 200.0);
        }
        boolean result = finalRate > (double)Rnd.get((int)1000);
        boolean debugCaster = attacker.getPlayer() != null && attacker.getPlayer().isDebug();
        boolean bl = debugTarget = target.getPlayer() != null && target.getPlayer().isDebug();
        if (debugCaster || debugTarget) {
            StringBuilder stat = new StringBuilder(100);
            stat.append("'" + attacker.getName() + "' m. skill crit chance debug: ");
            stat.append(skill.getName());
            stat.append("\nmCriticalHit: ");
            stat.append(String.format("%1.3f", mCriticalHit));
            stat.append("\nskillCriticalRateMod: ");
            stat.append(String.format("%1.3f", skillCriticalRateMod));
            stat.append("\nmCritChanceReceptive: ");
            stat.append(String.format("%1.3f", mCritChanceReceptive));
            stat.append("\nmCritChanceMode: ");
            stat.append(String.format("%1.3f", mCritChanceMode));
            stat.append("\ncritRate: ");
            stat.append(String.format("%1.3f", critRate));
            stat.append("\nlevelDiffChanceAdd: ");
            stat.append(String.format("%1.3f", levelDiffChanceAdd));
            stat.append("\nfinalRate: ");
            stat.append(String.format("%1.3f", finalRate));
            if (result) {
                stat.append("\nResult: success");
            } else {
                stat.append("\nResult: failed");
            }
            if (debugCaster) {
                attacker.getPlayer().sendMessage(stat.toString());
            }
            if (debugTarget) {
                target.getPlayer().sendMessage(stat.toString());
            }
        }
        return result;
    }

    public static boolean calcCastBreak(Creature target, boolean crit) {
        if (target == null || target.isInvulnerable() || target.isRaid() || !target.isCastingNow()) {
            return false;
        }
        Skill skill = null;
        SkillEntry skillEntry = target.getSkillCast(SkillCastingType.NORMAL).getSkillEntry();
        if (skillEntry != null && ((skill = skillEntry.getTemplate()).isPhysic() || skill.getSkillType() == Skill.SkillType.TAKECASTLE)) {
            return false;
        }
        skillEntry = target.getSkillCast(SkillCastingType.NORMAL_SECOND).getSkillEntry();
        if (skillEntry != null && ((skill = skillEntry.getTemplate()).isPhysic() || skill.getSkillType() == Skill.SkillType.TAKECASTLE)) {
            return false;
        }
        return Rnd.chance((double)target.getStat().calc(Stats.CAST_INTERRUPT, crit ? 75.0 : 10.0, null, skill));
    }

    public static int calcPAtkSpd(double rate) {
        return (int)(500000.0 / rate);
    }

    public static int calcSkillCastSpd(Creature attacker, Skill skill, double skillTime) {
        if (skill.isMagic()) {
            return (int)(skillTime * 333.0 / (double)Math.max(attacker.getMAtkSpd(), 1));
        }
        if (skill.isPhysic()) {
            return (int)(skillTime * 333.0 / (double)Math.max(attacker.getPAtkSpd(), 1));
        }
        return (int)skillTime;
    }

    public static long calcSkillReuseDelay(Creature actor, Skill skill) {
        long reuseDelay = skill.getReuseDelay();
        if (actor.isMonster()) {
            reuseDelay = skill.getReuseForMonsters();
        }
        if (skill.isHandler() || skill.isItemSkill()) {
            return reuseDelay;
        }
        if (skill.isReuseDelayPermanent()) {
            return reuseDelay;
        }
        if (skill.isMusic()) {
            return (long)actor.getStat().calc(Stats.MUSIC_REUSE_RATE, reuseDelay, null, skill);
        }
        if (skill.isMagic()) {
            return (long)actor.getStat().calc(Stats.MAGIC_REUSE_RATE, reuseDelay, null, skill);
        }
        return (long)actor.getStat().calc(Stats.PHYSIC_REUSE_RATE, reuseDelay, null, skill);
    }

    private static double getConditionBonus(Creature attacker, Creature target) {
        double mod = 100.0;
        if (attacker.getZ() - target.getZ() > 50) {
            mod += HitCondBonusHolder.getInstance().getHitCondBonus(HitCondBonusType.HIGH);
        } else if (attacker.getZ() - target.getZ() < -50) {
            mod += HitCondBonusHolder.getInstance().getHitCondBonus(HitCondBonusType.LOW);
        }
        if (GameTimeController.getInstance().isNowNight()) {
            mod += HitCondBonusHolder.getInstance().getHitCondBonus(HitCondBonusType.DARK);
        }
        if (attacker.isDistortedSpace()) {
            mod += HitCondBonusHolder.getInstance().getHitCondBonus(HitCondBonusType.BACK);
        } else {
            PositionUtils.TargetDirection direction = PositionUtils.getDirectionTo(attacker, target);
            switch (direction) {
                case BEHIND: {
                    mod += HitCondBonusHolder.getInstance().getHitCondBonus(HitCondBonusType.BACK);
                    break;
                }
                case SIDE: {
                    mod += HitCondBonusHolder.getInstance().getHitCondBonus(HitCondBonusType.SIDE);
                    break;
                }
                default: {
                    mod += HitCondBonusHolder.getInstance().getHitCondBonus(HitCondBonusType.AHEAD);
                }
            }
        }
        return Math.max(mod / 100.0, 0.0);
    }

    public static boolean calcHitMiss(Creature attacker, Creature target) {
        int chance = (80 + 2 * (attacker.getPAccuracy() - target.getPEvasionRate(attacker))) * 10;
        chance = (int)((double)chance * Formulas.getConditionBonus(attacker, target));
        chance = (int)Math.max((double)chance, Config.PHYSICAL_MIN_CHANCE_TO_HIT * 10.0);
        return (chance = (int)Math.min((double)chance, Config.PHYSICAL_MAX_CHANCE_TO_HIT * 10.0)) < Rnd.get((int)1000);
    }

    private static boolean calcMagicHitMiss(Skill skill, Creature attacker, Creature target) {
        int chance = (98 + 2 * (attacker.getMAccuracy() + 3 - target.getMEvasionRate(attacker))) * 10;
        chance = (int)Math.max((double)chance, Config.MAGIC_MIN_CHANCE_TO_HIT * 10.0);
        return (chance = (int)Math.min((double)chance, Config.MAGIC_MAX_CHANCE_TO_HIT * 10.0)) < Rnd.get((int)1000);
    }

    public static boolean calcShldUse(Creature attacker, Creature target) {
        WeaponTemplate template = target.getSecondaryWeaponTemplate();
        if (template == null || template.getItemType() != WeaponTemplate.WeaponType.NONE) {
            return false;
        }
        int angle = (int)target.getStat().calc(Stats.SHIELD_ANGLE, attacker, null);
        if (angle < 360 && !PositionUtils.isFacing(target, attacker, angle)) {
            return false;
        }
        return Rnd.chance((int)((int)target.getStat().calc(Stats.SHIELD_RATE, attacker, null)));
    }

    public static boolean calcEffectsSuccess(Creature caster, Creature target, Skill skill, int activateRate) {
        boolean debugTarget;
        if (activateRate == -1) {
            return true;
        }
        int magicLevel = skill.getMagicLevel();
        if (magicLevel <= -1) {
            magicLevel = target.getLevel() + 3;
        }
        double targetBasicProperty = Formulas.getAbnormalResist(skill.getBasicProperty(), target);
        double baseMod = (double)((magicLevel - target.getLevel() + 3) * skill.getLevelBonusRate() + activateRate) + 30.0 - targetBasicProperty;
        double elementMod = Formulas.calcAttributeBonus(caster, target, skill);
        double traitMod = Formulas.calcGeneralTraitBonus(caster, target, skill.getTraitType(), false);
        double basicPropertyResist = Formulas.getBasicPropertyResistBonus(skill.getBasicProperty(), target);
        double buffDebuffMod = 1.0 + (skill.isDebuff() ? target.getStat().calc(Stats.RESIST_ABNORMAL_DEBUFF, 0.0) : target.getStat().calc(Stats.RESIST_ABNORMAL_BUFF, 0.0)) / 100.0;
        double rate = baseMod * elementMod * traitMod * buffDebuffMod;
        double finalRate = traitMod > 0.0 ? Math.min(skill.getMaxChance(), Math.max(rate, skill.getMinChance())) * basicPropertyResist : 0.0;
        boolean result = finalRate > (double)Rnd.get((int)100);
        boolean debugCaster = caster.getPlayer() != null && caster.getPlayer().isDebug();
        boolean bl = debugTarget = target.getPlayer() != null && target.getPlayer().isDebug();
        if (debugCaster || debugTarget) {
            StringBuilder stat = new StringBuilder(100);
            stat.append("'" + caster.getName() + "' effects chance debug: ");
            stat.append(skill.getName());
            stat.append("\nactivateRate: ");
            stat.append(activateRate);
            stat.append("\nbaseMod: ");
            stat.append(String.format("%1.3f", baseMod));
            stat.append("\nelementMod: ");
            stat.append(String.format("%1.3f", elementMod));
            stat.append("\ntraitMod: ");
            stat.append(String.format("%1.3f", traitMod));
            stat.append("\nbuffDebuffMod: ");
            stat.append(String.format("%1.3f", buffDebuffMod));
            stat.append("\nrate: ");
            stat.append(String.format("%1.3f", rate));
            stat.append("\nfinalRate: ");
            stat.append(String.format("%1.3f", finalRate));
            if (result) {
                stat.append("\nResult: success");
            } else {
                stat.append("\nResult: failed");
            }
            if (debugCaster) {
                caster.getPlayer().sendMessage(stat.toString());
            }
            if (debugTarget) {
                target.getPlayer().sendMessage(stat.toString());
            }
        }
        return result;
    }

    public static double calcDamageResists(Skill skill, Creature attacker, Creature defender, double value) {
        if (attacker == defender) {
            return value;
        }
        if (attacker.isBoss()) {
            value *= Config.RATE_EPIC_ATTACK;
        } else if (attacker.isRaid()) {
            value *= Config.RATE_RAID_ATTACK;
        }
        if (defender.isBoss()) {
            value /= Config.RATE_EPIC_DEFENSE;
        } else if (defender.isRaid()) {
            value /= Config.RATE_RAID_DEFENSE;
        }
        Player pAttacker = attacker.getPlayer();
        int diff = defender.getLevel() - (pAttacker != null ? pAttacker.getLevel() : attacker.getLevel());
        if (attacker.isPlayable() && defender.isMonster() && defender.getLevel() >= 78 && diff > 2) {
            value *= 0.7 / Math.pow(diff - 2, 0.25);
        }
        return value;
    }

    private static double getElementMod(double defense, double attack) {
        double diff = attack - defense;
        diff = diff > 0.0 ? 1.025 + Math.sqrt(Math.pow(Math.abs(diff), 3.0) / 2.0) * 1.0E-4 : (diff < 0.0 ? 0.975 - Math.sqrt(Math.pow(Math.abs(diff), 3.0) / 2.0) * 1.0E-4 : 1.0);
        diff = Math.max(diff, 0.75);
        diff = Math.min(diff, 1.25);
        return diff;
    }

    public static Element getAttackElement(Creature attacker, Creature target) {
        double max = Double.MIN_VALUE;
        Element result = Element.NONE;
        for (Element e : Element.VALUES) {
            double val = attacker.getStat().calc(e.getAttack(), 0.0);
            if (val <= 0.0) continue;
            if (target != null) {
                val -= target.getStat().calc(e.getDefence(), 0.0);
            }
            if (!(val > max)) continue;
            result = e;
            max = val;
        }
        return result;
    }

    public static int calculateKarmaLost(Player player, long exp) {
        if (Config.RATE_KARMA_LOST_STATIC != -1) {
            return Config.RATE_KARMA_LOST_STATIC;
        }
        double karmaLooseMul = KarmaIncreaseDataHolder.getInstance().getData(player.getLevel());
        if (exp > 0L) {
            exp = (long)((double)exp / (Config.KARMA_RATE_KARMA_LOST == -1 ? Config.RATE_XP_BY_LVL[player.getLevel()] : (double)Config.KARMA_RATE_KARMA_LOST));
        }
        return (int)((double)Math.abs(exp) / karmaLooseMul / 15.0);
    }

    public static boolean calcCancelSuccess(Creature attacker, Creature target, int dispelChance, Skill skill, Abnormal abnormal) {
        boolean debugTarget;
        int cancelLevel = skill.getMagicLevel() > 0 ? skill.getMagicLevel() : attacker.getLevel();
        int buffLevel = abnormal.getSkill().getMagicLevel() > 0 ? abnormal.getSkill().getMagicLevel() : target.getLevel();
        int abnormalTime = abnormal.getSkill().getAbnormalTime();
        double cancelPower = attacker.getStat().calc(Stats.CANCEL_POWER, 100.0, null, null);
        double cancelResist = target.getStat().calc(Stats.CANCEL_RESIST, 100.0, null, null);
        int chance = (int)((double)(dispelChance + (cancelLevel - buffLevel) * 2) + (double)(abnormalTime / 120) * 0.01 * cancelPower * 0.01 * cancelResist);
        chance = Math.max(Math.min(Config.CANCEL_SKILLS_HIGH_CHANCE_CAP, chance), Config.CANCEL_SKILLS_LOW_CHANCE_CAP);
        boolean result = Rnd.get((int)100) < chance;
        boolean debugCaster = attacker.getPlayer() != null && attacker.getPlayer().isDebug();
        boolean bl = debugTarget = target.getPlayer() != null && target.getPlayer().isDebug();
        if (debugCaster || debugTarget) {
            StringBuilder stat = new StringBuilder(100);
            stat.append("----------------------------------");
            stat.append("\n'" + attacker.getName() + "' buff cancel chance debug: ");
            stat.append(skill.getName());
            stat.append("\nDispel chance: ");
            stat.append(dispelChance);
            stat.append("\nCancel skill magic level: ");
            stat.append(cancelLevel);
            stat.append("\nBuff magic level: ");
            stat.append(buffLevel);
            stat.append("\nBuff abormal time: ");
            stat.append(abnormalTime);
            stat.append("\nCancel power: ");
            stat.append(String.format("%1.3f", cancelPower));
            stat.append("\nCancel resist: ");
            stat.append(String.format("%1.3f", cancelResist));
            stat.append("\nBuff cancel chance: ");
            stat.append(chance);
            if (result) {
                stat.append("\nResult: success");
            } else {
                stat.append("\nResult: failed");
            }
            stat.append("----------------------------------");
            if (debugCaster) {
                attacker.getPlayer().sendMessage(stat.toString());
            }
            if (debugTarget) {
                target.getPlayer().sendMessage(stat.toString());
            }
        }
        return result;
    }

    public static double getAbnormalResist(BasicProperty basicProperty, Creature target) {
        switch (basicProperty) {
            case PHYSICAL_ABNORMAL_RESIST: {
                return target.getPhysicalAbnormalResist();
            }
            case MAGIC_ABNORMAL_RESIST: {
                return target.getMagicAbnormalResist();
            }
        }
        return 0.0;
    }

    public static double calcAttributeBonus(Creature attacker, Creature target, Skill skill) {
        int defence_attribute;
        int attack_attribute;
        if (skill != null) {
            if (skill.getElement() == Element.NONE || skill.getElement() == Element.NONE_ARMOR) {
                attack_attribute = 0;
                defence_attribute = target.getDefence(Element.NONE_ARMOR);
            } else if (attacker.getAttackElement() == skill.getElement()) {
                attack_attribute = attacker.getAttack(attacker.getAttackElement()) + skill.getElementPower();
                defence_attribute = target.getDefence(attacker.getAttackElement());
            } else {
                attack_attribute = skill.getElementPower();
                defence_attribute = target.getDefence(skill.getElement());
            }
        } else {
            attack_attribute = attacker.getAttack(attacker.getAttackElement());
            defence_attribute = target.getDefence(attacker.getAttackElement());
        }
        int diff = attack_attribute - defence_attribute;
        if (diff > 0) {
            return Math.min(1.025 + Math.sqrt(Math.pow(diff, 3.0) / 2.0) * 1.0E-4, 1.25);
        }
        if (diff < 0) {
            return Math.max(0.975 - Math.sqrt(Math.pow(-diff, 3.0) / 2.0) * 1.0E-4, 0.75);
        }
        return 1.0;
    }

    public static double calcGeneralTraitBonus(Creature attacker, Creature target, SkillTrait trait, boolean ignoreResistance) {
        if (trait == SkillTrait.NONE) {
            return 1.0;
        }
        Stats defenceStat = trait.getDefence();
        double targetDefence = defenceStat == null ? 0.0 : target.getStat().calc(defenceStat) * trait.getDefenceMod();
        double targetDefenceModifier = (targetDefence + 100.0) / 100.0;
        Stats attackStat = trait.getAttack();
        double attackerAttackModifier = ((attackStat == null ? 0.0 : attacker.getStat().calc(attackStat) * trait.getAttackMod()) + 100.0) / 100.0;
        switch (trait.getType()) {
            case WEAKNESS: {
                if (attackerAttackModifier != 1.0 && targetDefenceModifier != 1.0) break;
                return 1.0;
            }
            case RESISTANCE: {
                if (!ignoreResistance) break;
                return 1.0;
            }
            default: {
                return 1.0;
            }
        }
        if (targetDefence == Double.POSITIVE_INFINITY) {
            return 0.0;
        }
        double result = attackerAttackModifier - targetDefenceModifier + 1.0;
        return Math.max(0.05, Math.min(2.0, result));
    }

    public static double calcWeaponTraitBonus(Creature attacker, Creature target) {
        SkillTrait type = attacker.getBaseStats().getAttackType().getTrait();
        Stats defenceStat = type.getDefence();
        if (defenceStat != null) {
            double targetDefenceModifier = (target.getStat().calc(defenceStat) * type.getDefenceMod() + 100.0) / 100.0;
            double result = targetDefenceModifier - 1.0;
            return 1.0 - result;
        }
        return 1.0;
    }

    public static double calcAttackTraitBonus(Creature attacker, Creature target) {
        double weaponTraitBonus = Formulas.calcWeaponTraitBonus(attacker, target);
        if (weaponTraitBonus == 0.0) {
            return 0.0;
        }
        double weaknessBonus = 1.0;
        for (SkillTrait traitType : SkillTrait.VALUES) {
            if (traitType.getType() != SkillTraitType.WEAKNESS || (weaknessBonus *= Formulas.calcGeneralTraitBonus(attacker, target, traitType, true)) != 0.0) continue;
            return 0.0;
        }
        return Math.max(0.05, Math.min(2.0, weaponTraitBonus * weaknessBonus));
    }

    public static double getBasicPropertyResistBonus(BasicProperty basicProperty, Creature target) {
        if (basicProperty == BasicProperty.NONE || !target.hasBasicPropertyResist()) {
            return 1.0;
        }
        BasicPropertyResist resist = target.getBasicPropertyResist(basicProperty);
        switch (resist.getResistLevel()) {
            case 0: {
                return 1.0;
            }
            case 1: {
                return 0.6;
            }
            case 2: {
                return 0.3;
            }
        }
        return 0.0;
    }

    public static int calculateTimeToHit(int totalAttackTime, WeaponTemplate.WeaponType attackType, boolean secondHit) {
        switch (attackType) {
            case BOW: 
            case CROSSBOW: {
                return (int)((double)totalAttackTime * 0.95);
            }
            case DUALDAGGER: 
            case DUAL: 
            case DUALFIST: {
                if (secondHit) {
                    return (int)((double)totalAttackTime * 0.6);
                }
                return (int)((double)totalAttackTime * 0.2726);
            }
            case SWORD: 
            case BLUNT: 
            case DAGGER: 
            case RAPIER: 
            case ETC: {
                return (int)((double)totalAttackTime * 0.644);
            }
        }
        return (int)((double)totalAttackTime * 0.735);
    }

    public static class AttackInfo {
        public double damage = 0.0;
        public double defence = 0.0;
        public boolean crit = false;
        public boolean shld = false;
        public boolean miss = false;
        public boolean blow = false;
    }
}

