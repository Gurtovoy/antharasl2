package l2s.gameserver.model.actor.basestats;

import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.basestats.PlayableBaseStats;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.npc.NpcTemplate;

public class PlayerBaseStats
extends PlayableBaseStats {
    public PlayerBaseStats(Player owner) {
        super(owner);
    }

    @Override
    public Player getOwner() {
        return (Player)this._owner;
    }

    @Override
    public int getINT() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseINT() > 0) {
            return this.getOwner().getTransform().getBaseINT();
        }
        return super.getINT();
    }

    @Override
    public int getSTR() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseSTR() > 0) {
            return this.getOwner().getTransform().getBaseSTR();
        }
        return super.getSTR();
    }

    @Override
    public int getCON() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseCON() > 0) {
            return this.getOwner().getTransform().getBaseCON();
        }
        return super.getCON();
    }

    @Override
    public int getMEN() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseMEN() > 0) {
            return this.getOwner().getTransform().getBaseMEN();
        }
        return super.getMEN();
    }

    @Override
    public int getDEX() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseDEX() > 0) {
            return this.getOwner().getTransform().getBaseDEX();
        }
        return super.getDEX();
    }

    @Override
    public int getWIT() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseWIT() > 0) {
            return this.getOwner().getTransform().getBaseWIT();
        }
        return super.getWIT();
    }

    @Override
    public double getHpMax() {
        double maxHp = this.getOwner().isMounted() && this.getOwner().getMount().getMaxHpOnRide() > 0 ? (double)this.getOwner().getMount().getMaxHpOnRide() : (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseHpMax(this.getOwner().getLevel()) > 0.0 ? this.getOwner().getTransform().getBaseHpMax(this.getOwner().getLevel()) : this.getOwner().getClassId().getBaseHp(this.getOwner().getLevel()));
        return maxHp;
    }

    @Override
    public double getMpMax() {
        double maxMp = this.getOwner().isMounted() && this.getOwner().getMount().getMaxMpOnRide() > 0 ? (double)this.getOwner().getMount().getMaxMpOnRide() : (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseMpMax(this.getOwner().getLevel()) > 0.0 ? this.getOwner().getTransform().getBaseMpMax(this.getOwner().getLevel()) : this.getOwner().getClassId().getBaseMp(this.getOwner().getLevel()));
        return maxMp;
    }

    @Override
    public double getCpMax() {
        double maxCp = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseCpMax(this.getOwner().getLevel()) > 0.0 ? this.getOwner().getTransform().getBaseCpMax(this.getOwner().getLevel()) : this.getOwner().getClassId().getBaseCp(this.getOwner().getLevel());
        return maxCp;
    }

    @Override
    public double getHpReg() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseHpReg(this.getOwner().getLevel()) > 0.0) {
            return this.getOwner().getTransform().getBaseHpReg(this.getOwner().getLevel());
        }
        return super.getHpReg();
    }

    @Override
    public double getMpReg() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseMpReg(this.getOwner().getLevel()) > 0.0) {
            return this.getOwner().getTransform().getBaseMpReg(this.getOwner().getLevel());
        }
        return super.getMpReg();
    }

    @Override
    public double getCpReg() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseCpReg(this.getOwner().getLevel()) > 0.0) {
            return this.getOwner().getTransform().getBaseCpReg(this.getOwner().getLevel());
        }
        return super.getCpReg();
    }

    @Override
    public double getPAtk() {
        double pAtk = this.getOwner().isMounted() && this.getOwner().getMount().getPAtkOnRide() > 0.0 ? this.getOwner().getMount().getPAtkOnRide() : (this.getOwner().isTransformed() && this.getOwner().getTransform().getBasePAtk() > 0.0 ? this.getOwner().getTransform().getBasePAtk() : super.getPAtk());
        WeaponTemplate weaponTemplate = this.getOwner().getActiveWeaponTemplate();
        if (weaponTemplate != null) {
            pAtk = Math.max(pAtk, (double)weaponTemplate.getPAtk());
        }
        return pAtk;
    }

    @Override
    public double getMAtk() {
        double mAtk = this.getOwner().isMounted() && this.getOwner().getMount().getMAtkOnRide() > 0.0 ? this.getOwner().getMount().getMAtkOnRide() : (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseMAtk() > 0.0 ? this.getOwner().getTransform().getBaseMAtk() : super.getMAtk());
        WeaponTemplate weaponTemplate = this.getOwner().getActiveWeaponTemplate();
        if (weaponTemplate != null) {
            mAtk = Math.max(mAtk, (double)weaponTemplate.getMAtk());
        }
        return mAtk;
    }

    @Override
    public double getPDef() {
        double result = 0.0;
        double chestPDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseChestDef() > 0 ? (double)this.getOwner().getTransform().getBaseChestDef() : (double)this.getOwner().getTemplate().getBaseChestDef();
        double legsPDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseLegsDef() > 0 ? (double)this.getOwner().getTransform().getBaseLegsDef() : (double)this.getOwner().getTemplate().getBaseLegsDef();
        ItemInstance tempItem = this.getOwner().getInventory().getPaperdollItem(10);
        if (tempItem != null) {
            if (tempItem.getBodyPart() == 32768L) {
                chestPDef = Math.max(chestPDef + legsPDef, (double)tempItem.getTemplate().getPDef());
                legsPDef = 0.0;
            } else {
                chestPDef = Math.max(chestPDef, (double)tempItem.getTemplate().getPDef());
            }
        }
        result += chestPDef;
        if ((tempItem == null || tempItem.getBodyPart() != 32768L) && (tempItem = this.getOwner().getInventory().getPaperdollItem(11)) != null) {
            legsPDef = Math.max(legsPDef, (double)tempItem.getTemplate().getPDef());
        }
        result += legsPDef;
        double helmetPDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseHelmetDef() > 0 ? (double)this.getOwner().getTransform().getBaseHelmetDef() : (double)this.getOwner().getTemplate().getBaseHelmetDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(6);
        if (tempItem != null) {
            helmetPDef = Math.max(helmetPDef, (double)tempItem.getTemplate().getPDef());
        }
        result += helmetPDef;
        double glovesPDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseGlovesDef() > 0 ? (double)this.getOwner().getTransform().getBaseGlovesDef() : (double)this.getOwner().getTemplate().getBaseGlovesDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(9);
        if (tempItem != null) {
            glovesPDef = Math.max(glovesPDef, (double)tempItem.getTemplate().getPDef());
        }
        result += glovesPDef;
        double bootsPDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseBootsDef() > 0 ? (double)this.getOwner().getTransform().getBaseBootsDef() : (double)this.getOwner().getTemplate().getBaseBootsDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(12);
        if (tempItem != null) {
            bootsPDef = Math.max(bootsPDef, (double)tempItem.getTemplate().getPDef());
        }
        result += bootsPDef;
        double pendantPDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBasePendantDef() > 0 ? (double)this.getOwner().getTransform().getBasePendantDef() : (double)this.getOwner().getTemplate().getBasePendantDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(0);
        if (tempItem != null) {
            pendantPDef = Math.max(pendantPDef, (double)tempItem.getTemplate().getPDef());
        }
        result += pendantPDef;
        double cloakPDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseCloakDef() > 0 ? (double)this.getOwner().getTransform().getBaseCloakDef() : (double)this.getOwner().getTemplate().getBaseCloakDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(13);
        if (tempItem != null) {
            cloakPDef = Math.max(cloakPDef, (double)tempItem.getTemplate().getPDef());
        }
        return result += cloakPDef;
    }

    @Override
    public double getMDef() {
        double result = 0.0;
        double lEarMDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseLEarDef() > 0 ? (double)this.getOwner().getTransform().getBaseLEarDef() : (double)this.getOwner().getTemplate().getBaseLEarDef();
        ItemInstance tempItem = this.getOwner().getInventory().getPaperdollItem(2);
        if (tempItem != null) {
            lEarMDef = Math.max(lEarMDef, (double)tempItem.getTemplate().getMDef());
        }
        result += lEarMDef;
        double rEarMDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseREarDef() > 0 ? (double)this.getOwner().getTransform().getBaseREarDef() : (double)this.getOwner().getTemplate().getBaseREarDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(1);
        if (tempItem != null) {
            rEarMDef = Math.max(rEarMDef, (double)tempItem.getTemplate().getMDef());
        }
        result += rEarMDef;
        double necklaceMDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseNecklaceDef() > 0 ? (double)this.getOwner().getTransform().getBaseNecklaceDef() : (double)this.getOwner().getTemplate().getBaseNecklaceDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(3);
        if (tempItem != null) {
            necklaceMDef = Math.max(necklaceMDef, (double)tempItem.getTemplate().getMDef());
        }
        result += necklaceMDef;
        double lRingMDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseLRingDef() > 0 ? (double)this.getOwner().getTransform().getBaseLRingDef() : (double)this.getOwner().getTemplate().getBaseLRingDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(5);
        if (tempItem != null) {
            lRingMDef = Math.max(lRingMDef, (double)tempItem.getTemplate().getMDef());
        }
        result += lRingMDef;
        double rRingMDef = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseRRingDef() > 0 ? (double)this.getOwner().getTransform().getBaseRRingDef() : (double)this.getOwner().getTemplate().getBaseRRingDef();
        tempItem = this.getOwner().getInventory().getPaperdollItem(4);
        if (tempItem != null) {
            rRingMDef = Math.max(rRingMDef, (double)tempItem.getTemplate().getMDef());
        }
        return result += rRingMDef;
    }

    @Override
    public double getPAtkSpd() {
        double pAtkSpd = this.getOwner().isMounted() && this.getOwner().getMount().getAtkSpdOnRide() > 0 ? this.getOwner().getStat().calc(Stats.BASE_P_ATK_SPD, this.getOwner().getMount().getAtkSpdOnRide(), null, null) : (this.getOwner().isTransformed() && this.getOwner().getTransform().getBasePAtkSpd() > 0.0 ? this.getOwner().getStat().calc(Stats.BASE_P_ATK_SPD, this.getOwner().getTransform().getBasePAtkSpd(), null, null) : super.getPAtkSpd());
        return pAtkSpd;
    }

    @Override
    public double getMAtkSpd() {
        double mAtkSpd = this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseMAtkSpd() > 0.0 ? this.getOwner().getTransform().getBaseMAtkSpd() : super.getMAtkSpd();
        return mAtkSpd;
    }

    @Override
    public double getShldDef() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseShldDef() > 0.0) {
            return this.getOwner().getTransform().getBaseShldDef();
        }
        return super.getShldDef();
    }

    @Override
    public int getAtkRange() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseAtkRange() > 0) {
            return this.getOwner().getTransform().getBaseAtkRange();
        }
        WeaponTemplate weaponTemplate = this.getOwner().getActiveWeaponTemplate();
        if (weaponTemplate != null) {
            return weaponTemplate.getAttackRange();
        }
        return super.getAtkRange();
    }

    @Override
    public int getAttackRadius() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseAtkRange() > 0) {
            return this.getOwner().getTransform().getBaseAttackRadius();
        }
        WeaponTemplate weaponTemplate = this.getOwner().getActiveWeaponTemplate();
        if (weaponTemplate != null) {
            return weaponTemplate.getAttackRadius();
        }
        return super.getAttackRadius();
    }

    @Override
    public int getAttackAngle() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseAtkRange() > 0) {
            return this.getOwner().getTransform().getBaseAttackAngle();
        }
        WeaponTemplate weaponTemplate = this.getOwner().getActiveWeaponTemplate();
        if (weaponTemplate != null) {
            return weaponTemplate.getAttackAngle();
        }
        return super.getAttackAngle();
    }

    @Override
    public double getShldRate() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseShldRate() > 0.0) {
            return this.getOwner().getTransform().getBaseShldRate();
        }
        return 0.0;
    }

    @Override
    public double getPCritRate() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBasePCritRate() > 0.0) {
            return this.getOwner().getTransform().getBasePCritRate();
        }
        return super.getPCritRate();
    }

    @Override
    public double getMCritRate() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseMCritRate() > 0.0) {
            return this.getOwner().getTransform().getBaseMCritRate();
        }
        return super.getMCritRate();
    }

    @Override
    public double getRunSpd() {
        if (this.getOwner().isMounted() && this.getOwner().getMount().getRunSpdOnRide() > 0) {
            return this.getOwner().getMount().getRunSpdOnRide();
        }
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseRunSpd() > 0.0) {
            return this.getOwner().getTransform().getBaseRunSpd();
        }
        return super.getRunSpd();
    }

    @Override
    public double getWalkSpd() {
        if (this.getOwner().isMounted() && this.getOwner().getMount().getWalkSpdOnRide() > 0) {
            return this.getOwner().getMount().getWalkSpdOnRide();
        }
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseWalkSpd() > 0.0) {
            return this.getOwner().getTransform().getBaseWalkSpd();
        }
        return super.getWalkSpd();
    }

    @Override
    public double getWaterRunSpd() {
        if (this.getOwner().isMounted() && this.getOwner().getMount().getWaterRunSpdOnRide() > 0) {
            return this.getOwner().getMount().getWaterRunSpdOnRide();
        }
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseWaterRunSpd() > 0.0) {
            return this.getOwner().getTransform().getBaseWaterRunSpd();
        }
        return super.getWaterRunSpd();
    }

    @Override
    public double getWaterWalkSpd() {
        if (this.getOwner().isMounted() && this.getOwner().getMount().getWaterWalkSpdOnRide() > 0) {
            return this.getOwner().getMount().getWaterWalkSpdOnRide();
        }
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseWaterWalkSpd() > 0.0) {
            return this.getOwner().getTransform().getBaseWaterWalkSpd();
        }
        return super.getWaterWalkSpd();
    }

    @Override
    public double getFlyRunSpd() {
        if (this.getOwner().isMounted() && this.getOwner().getMount().getWaterRunSpdOnRide() > 0) {
            return this.getOwner().getMount().getWaterRunSpdOnRide();
        }
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseFlyRunSpd() > 0.0) {
            return this.getOwner().getTransform().getBaseFlyRunSpd();
        }
        return this.getOwner().getTemplate().getBaseFlyRunSpd();
    }

    @Override
    public double getFlyWalkSpd() {
        if (this.getOwner().isMounted() && this.getOwner().getMount().getFlyWalkSpdOnRide() > 0) {
            return this.getOwner().getMount().getFlyWalkSpdOnRide();
        }
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseFlyWalkSpd() > 0.0) {
            return this.getOwner().getTransform().getBaseFlyWalkSpd();
        }
        return this.getOwner().getTemplate().getBaseFlyWalkSpd();
    }

    @Override
    public double getRideRunSpd() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseRideRunSpd() > 0.0) {
            return this.getOwner().getTransform().getBaseRideRunSpd();
        }
        return this.getOwner().getTemplate().getBaseRideRunSpd();
    }

    @Override
    public double getRideWalkSpd() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseRideWalkSpd() > 0.0) {
            return this.getOwner().getTransform().getBaseRideWalkSpd();
        }
        return this.getOwner().getTemplate().getBaseRideWalkSpd();
    }

    @Override
    public double getCollisionRadius() {
        NpcTemplate mountNpcTemplate;
        int mountTemplate;
        if (this.getOwner().isMounted() && (mountTemplate = this.getOwner().getMountNpcId()) != 0 && (mountNpcTemplate = NpcHolder.getInstance().getTemplate(mountTemplate)) != null) {
            return mountNpcTemplate.getCollisionRadius();
        }
        if (this.getOwner().isVisualTransformed() && this.getOwner().getVisualTransform().getCollisionRadius() > 0.0) {
            return this.getOwner().getVisualTransform().getCollisionRadius();
        }
        return this.getOwner().getBaseTemplate().getCollisionRadius();
    }

    @Override
    public double getCollisionHeight() {
        NpcTemplate mountNpcTemplate;
        int mountTemplate;
        if (this.getOwner().isMounted() && (mountTemplate = this.getOwner().getMountNpcId()) != 0 && (mountNpcTemplate = NpcHolder.getInstance().getTemplate(mountTemplate)) != null) {
            return mountNpcTemplate.getCollisionHeight();
        }
        if (this.getOwner().isVisualTransformed() && this.getOwner().getVisualTransform().getCollisionHeight() > 0.0) {
            return this.getOwner().getVisualTransform().getCollisionHeight();
        }
        return this.getOwner().getBaseTemplate().getCollisionHeight();
    }

    @Override
    public WeaponTemplate.WeaponType getAttackType() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseAttackType() != WeaponTemplate.WeaponType.NONE) {
            return this.getOwner().getTransform().getBaseAttackType();
        }
        return super.getAttackType();
    }

    @Override
    public int getRandDam() {
        if (this.getOwner().isTransformed() && this.getOwner().getTransform().getBaseRandDam() > 0) {
            return this.getOwner().getTransform().getBaseRandDam();
        }
        return super.getRandDam();
    }

    public double getBreathBonus() {
        return this.getOwner().getTemplate().getBaseBreathBonus();
    }

    public double getSafeFallHeight() {
        return this.getOwner().getTemplate().getBaseSafeFallHeight();
    }
}

