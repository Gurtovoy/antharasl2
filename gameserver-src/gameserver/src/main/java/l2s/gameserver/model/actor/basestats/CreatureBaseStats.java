/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.actor.basestats;

import l2s.gameserver.model.Creature;
import l2s.gameserver.templates.item.WeaponTemplate;

public class CreatureBaseStats {
    protected final Creature _owner;

    public CreatureBaseStats(Creature owner) {
        this._owner = owner;
    }

    public Creature getOwner() {
        return this._owner;
    }

    public int getINT() {
        return this.getOwner().getTemplate().getBaseINT();
    }

    public int getSTR() {
        return this.getOwner().getTemplate().getBaseSTR();
    }

    public int getCON() {
        return this.getOwner().getTemplate().getBaseCON();
    }

    public int getMEN() {
        return this.getOwner().getTemplate().getBaseMEN();
    }

    public int getDEX() {
        return this.getOwner().getTemplate().getBaseDEX();
    }

    public int getWIT() {
        return this.getOwner().getTemplate().getBaseWIT();
    }

    public double getHpMax() {
        return this.getOwner().getTemplate().getBaseHpMax(this.getOwner().getLevel());
    }

    public double getMpMax() {
        return this.getOwner().getTemplate().getBaseMpMax(this.getOwner().getLevel());
    }

    public double getCpMax() {
        return this.getOwner().getTemplate().getBaseCpMax(this.getOwner().getLevel());
    }

    public double getHpReg() {
        return this.getOwner().getTemplate().getBaseHpReg(this.getOwner().getLevel());
    }

    public double getMpReg() {
        return this.getOwner().getTemplate().getBaseMpReg(this.getOwner().getLevel());
    }

    public double getCpReg() {
        return this.getOwner().getTemplate().getBaseCpReg(this.getOwner().getLevel());
    }

    public double getPAtk() {
        return this.getOwner().getTemplate().getBasePAtk();
    }

    public double getMAtk() {
        return this.getOwner().getTemplate().getBaseMAtk();
    }

    public double getPDef() {
        return this.getOwner().getTemplate().getBasePDef();
    }

    public double getMDef() {
        return this.getOwner().getTemplate().getBaseMDef();
    }

    public double getPAtkSpd() {
        return this.getOwner().getTemplate().getBasePAtkSpd();
    }

    public double getMAtkSpd() {
        return this.getOwner().getTemplate().getBaseMAtkSpd();
    }

    public double getShldDef() {
        return this.getOwner().getTemplate().getBaseShldDef();
    }

    public int getAtkRange() {
        return this.getOwner().getTemplate().getBaseAtkRange();
    }

    public int getAttackRadius() {
        return this.getOwner().getTemplate().getBaseAttackRadius();
    }

    public int getAttackAngle() {
        return this.getOwner().getTemplate().getBaseAttackAngle();
    }

    public double getShldRate() {
        return this.getOwner().getTemplate().getBaseShldRate();
    }

    public double getPCritRate() {
        return this.getOwner().getTemplate().getBasePCritRate();
    }

    public double getMCritRate() {
        return this.getOwner().getTemplate().getBaseMCritRate();
    }

    public double getRunSpd() {
        return this.getOwner().getTemplate().getBaseRunSpd();
    }

    public double getWalkSpd() {
        return this.getOwner().getTemplate().getBaseWalkSpd();
    }

    public double getWaterRunSpd() {
        return this.getOwner().getTemplate().getBaseWaterRunSpd();
    }

    public double getWaterWalkSpd() {
        return this.getOwner().getTemplate().getBaseWaterWalkSpd();
    }

    public double getFlyRunSpd() {
        return this.getRunSpd();
    }

    public double getFlyWalkSpd() {
        return this.getWalkSpd();
    }

    public double getRideRunSpd() {
        return this.getRunSpd();
    }

    public double getRideWalkSpd() {
        return this.getWalkSpd();
    }

    public int[] getAttributeAttack() {
        return this.getOwner().getTemplate().getBaseAttributeAttack();
    }

    public int[] getAttributeDefence() {
        return this.getOwner().getTemplate().getBaseAttributeDefence();
    }

    public double getCollisionRadius() {
        if (this.getOwner().isVisualTransformed() && this.getOwner().getVisualTransform().getCollisionRadius() > 0.0) {
            return this.getOwner().getVisualTransform().getCollisionRadius();
        }
        return this.getOwner().getTemplate().getCollisionRadius();
    }

    public double getCollisionHeight() {
        if (this.getOwner().isVisualTransformed() && this.getOwner().getVisualTransform().getCollisionHeight() > 0.0) {
            return this.getOwner().getVisualTransform().getCollisionHeight();
        }
        return this.getOwner().getTemplate().getCollisionHeight();
    }

    public WeaponTemplate.WeaponType getAttackType() {
        if (this.getOwner().getActiveWeaponTemplate() != null) {
            return this.getOwner().getActiveWeaponTemplate().getItemType();
        }
        return this.getOwner().getTemplate().getBaseAttackType();
    }

    public int getPhysicalAbnormalResist() {
        return this.getOwner().getTemplate().getPhysicalAbnormalResist();
    }

    public int getMagicAbnormalResist() {
        return this.getOwner().getTemplate().getMagicAbnormalResist();
    }

    public int getRandDam() {
        return this.getOwner().getTemplate().getBaseRandDam();
    }
}

