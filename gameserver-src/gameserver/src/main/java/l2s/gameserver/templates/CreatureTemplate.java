package l2s.gameserver.templates;

import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.WeaponTemplate;

public class CreatureTemplate {
    private static int[] EMPTY_ATTRIBUTES = new int[6];
    private final StatsSet _statsSet;
    private final int _baseINT;
    private final int _baseSTR;
    private final int _baseCON;
    private final int _baseMEN;
    private final int _baseDEX;
    private final int _baseWIT;
    private final int _baseAtkRange;
    private final int _baseAttackRadius;
    private final int _baseAttackAngle;
    private final int _baseRandDam;
    private double _baseHpMax;
    private final double _baseCpMax;
    private final double _baseMpMax;
    private final double _baseHpReg;
    private final double _baseMpReg;
    private final double _baseCpReg;
    private double _basePAtk;
    private double _baseMAtk;
    private double _basePDef;
    private double _baseMDef;
    private final double _basePAtkSpd;
    private final double _baseMAtkSpd;
    private final double _baseShldDef;
    private final double _baseShldRate;
    private final double _basePCritRate;
    private final double _baseMCritRate;
    private final double _baseRunSpd;
    private final double _baseWalkSpd;
    private final double _baseWaterRunSpd;
    private final double _baseWaterWalkSpd;
    private final double _baseFlyRunSpd;
    private final double _baseFlyWalkSpd;
    private final int[] _baseAttributeAttack;
    private final int[] _baseAttributeDefence;
    private final double _collisionRadius;
    private final double _collisionHeight;
    private final WeaponTemplate.WeaponType _baseAttackType;
    private final int _physicalAbnormalResist;
    private final int _magicAbnormalResist;

    public CreatureTemplate(StatsSet set) {
        this._statsSet = set;
        this._baseINT = set.getInteger("baseINT", 1);
        this._baseSTR = set.getInteger("baseSTR", 1);
        this._baseCON = set.getInteger("baseCON", 1);
        this._baseMEN = set.getInteger("baseMEN", 1);
        this._baseDEX = set.getInteger("baseDEX", 1);
        this._baseWIT = set.getInteger("baseWIT", 1);
        this._baseHpMax = set.getDouble("baseHpMax", 0.0);
        this._baseCpMax = set.getDouble("baseCpMax", 0.0);
        this._baseMpMax = set.getDouble("baseMpMax", 0.0);
        this._baseHpReg = set.getDouble("baseHpReg", 1.0);
        this._baseCpReg = set.getDouble("baseCpReg", 1.0);
        this._baseMpReg = set.getDouble("baseMpReg", 1.0);
        this._basePAtk = set.getDouble("basePAtk", 0.0);
        this._baseMAtk = set.getDouble("baseMAtk", 0.0);
        this._basePDef = set.getDouble("basePDef", 0.0);
        this._baseMDef = set.getDouble("baseMDef", 0.0);
        this._basePAtkSpd = set.getDouble("basePAtkSpd", 0.0);
        this._baseMAtkSpd = set.getDouble("baseMAtkSpd", 333.0);
        this._baseShldDef = set.getDouble("baseShldDef", 0.0);
        this._baseAtkRange = set.getInteger("baseAtkRange", 0);
        String[] damageRange = set.getString("damage_range", "").split(";");
        if (damageRange.length >= 4) {
            this._baseAttackRadius = Integer.parseInt(damageRange[2]);
            this._baseAttackAngle = Integer.parseInt(damageRange[3]);
        } else {
            this._baseAttackRadius = 26;
            this._baseAttackAngle = 120;
        }
        this._baseRandDam = set.getInteger("baseRandDam", 0);
        this._baseShldRate = set.getDouble("baseShldRate", 0.0);
        this._basePCritRate = set.getDouble("basePCritRate", 0.0);
        this._baseMCritRate = set.getDouble("baseMCritRate", 0.0);
        this._baseRunSpd = set.getDouble("baseRunSpd", 0.0);
        this._baseWalkSpd = set.getDouble("baseWalkSpd", 0.0);
        this._baseWaterRunSpd = set.getDouble("baseWaterRunSpd", 50.0);
        this._baseWaterWalkSpd = set.getDouble("baseWaterWalkSpd", 50.0);
        this._baseFlyRunSpd = set.getDouble("baseFlyRunSpd", 0.0);
        this._baseFlyWalkSpd = set.getDouble("baseFlyWalkSpd", 0.0);
        this._baseAttributeAttack = set.getIntegerArray("baseAttributeAttack", EMPTY_ATTRIBUTES);
        this._baseAttributeDefence = set.getIntegerArray("baseAttributeDefence", EMPTY_ATTRIBUTES);
        this._collisionRadius = set.getDoubleArray("collision_radius", new double[]{5.0})[0];
        this._collisionHeight = set.getDoubleArray("collision_height", new double[]{5.0})[0];
        this._baseAttackType = WeaponTemplate.WeaponType.valueOf(set.getString("baseAttackType", "FIST").toUpperCase());
        this._physicalAbnormalResist = set.getInteger("physical_abnormal_resist", 10);
        this._magicAbnormalResist = set.getInteger("magic_abnormal_resist", 10);
    }

    public StatsSet getStatsSet() {
        return this._statsSet;
    }

    public int getId() {
        return 0;
    }

    public int getBaseINT() {
        return this._baseINT;
    }

    public int getBaseSTR() {
        return this._baseSTR;
    }

    public int getBaseCON() {
        return this._baseCON;
    }

    public int getBaseMEN() {
        return this._baseMEN;
    }

    public int getBaseDEX() {
        return this._baseDEX;
    }

    public int getBaseWIT() {
        return this._baseWIT;
    }

    public double getBaseHpMax(int level) {
        return this._baseHpMax;
    }

    public double getBaseMpMax(int level) {
        return this._baseMpMax;
    }

    public double getBaseCpMax(int level) {
        return this._baseCpMax;
    }

    public double getBaseHpReg(int level) {
        return this._baseHpReg;
    }

    public double getBaseMpReg(int level) {
        return this._baseMpReg;
    }

    public double getBaseCpReg(int level) {
        return this._baseCpReg;
    }

    public double getBasePAtk() {
        return this._basePAtk;
    }

    public double getBaseMAtk() {
        return this._baseMAtk;
    }

    public double getBasePDef() {
        return this._basePDef;
    }

    public double getBaseMDef() {
        return this._baseMDef;
    }

    public double getBasePAtkSpd() {
        return this._basePAtkSpd;
    }

    public double getBaseMAtkSpd() {
        return this._baseMAtkSpd;
    }

    public double getBaseShldDef() {
        return this._baseShldDef;
    }

    public int getBaseAtkRange() {
        return this._baseAtkRange;
    }

    public int getBaseAttackRadius() {
        return this._baseAttackRadius;
    }

    public int getBaseAttackAngle() {
        return this._baseAttackAngle;
    }

    public int getBaseRandDam() {
        return this._baseRandDam;
    }

    public double getBaseShldRate() {
        return this._baseShldRate;
    }

    public double getBasePCritRate() {
        return this._basePCritRate;
    }

    public double getBaseMCritRate() {
        return this._baseMCritRate;
    }

    public double getBaseRunSpd() {
        return this._baseRunSpd;
    }

    public double getBaseWalkSpd() {
        return this._baseWalkSpd;
    }

    public double getBaseWaterRunSpd() {
        return this._baseWaterRunSpd;
    }

    public double getBaseWaterWalkSpd() {
        return this._baseWaterWalkSpd;
    }

    public double getBaseFlyRunSpd() {
        return this._baseFlyRunSpd;
    }

    public double getBaseFlyWalkSpd() {
        return this._baseFlyWalkSpd;
    }

    public int[] getBaseAttributeAttack() {
        return this._baseAttributeAttack;
    }

    public int[] getBaseAttributeDefence() {
        return this._baseAttributeDefence;
    }

    public double getCollisionRadius() {
        return this._collisionRadius;
    }

    public double getCollisionHeight() {
        return this._collisionHeight;
    }

    public WeaponTemplate.WeaponType getBaseAttackType() {
        return this._baseAttackType;
    }

    public int getPhysicalAbnormalResist() {
        return this._physicalAbnormalResist;
    }

    public int getMagicAbnormalResist() {
        return this._magicAbnormalResist;
    }

    public static StatsSet getEmptyStatsSet() {
        return new StatsSet();
    }

    public void setHpMax(double baseHpMax) {
        this._baseHpMax = baseHpMax;
    }

    public void setPDef(double basePDef) {
        this._basePDef = basePDef;
    }

    public void setMDef(double baseMDef) {
        this._baseMDef = baseMDef;
    }

    public void setPAtk(double basePAtk) {
        this._basePAtk = basePAtk;
    }

    public void setMAtk(double baseMAtk) {
        this._baseMAtk = baseMAtk;
    }
}

