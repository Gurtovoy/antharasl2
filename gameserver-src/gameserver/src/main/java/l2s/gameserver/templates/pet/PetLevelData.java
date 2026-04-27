/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.pet;

import l2s.gameserver.templates.StatsSet;

public class PetLevelData {
    private final int _maxMeal;
    private final long _exp;
    private final int _expType;
    private final int _battleMealConsume;
    private final int _normalMealConsume;
    private final double _pAtk;
    private final double _pDef;
    private final double _mAtk;
    private final double _mDef;
    private final double _hp;
    private final double _mp;
    private final double _hpRegen;
    private final double _mpRegen;
    private final int[] _food;
    private final int _hungryLimit;
    private final int _soulshotCount;
    private final int _spiritshotCount;
    private final int _maxLoad;
    private final int _battleMealConsumeOnRide;
    private final int _normalMealConsumeOnRide;
    private final int _walkSpdOnRide;
    private final int _runSpdOnRide;
    private final int _waterWalkSpdOnRide;
    private final int _waterRunSpdOnRide;
    private final int _flyWalkSpdOnRide;
    private final int _flyRunSpdOnRide;
    private final int _atkSpdOnRide;
    private final double _pAtkOnRide;
    private final double _mAtkOnRide;
    private final int _maxHpOnRide;
    private final int _maxMpOnRide;

    public PetLevelData(StatsSet set) {
        this._maxMeal = set.getInteger("max_meal");
        this._exp = set.getLong("exp");
        this._expType = set.getInteger("exp_type");
        this._battleMealConsume = set.getInteger("battle_meal_consume");
        this._normalMealConsume = set.getInteger("normal_meal_consume");
        this._hungryLimit = set.getInteger("hungry_limit");
        this._soulshotCount = set.getInteger("soulshot_count");
        this._spiritshotCount = set.getInteger("spiritshot_count");
        this._pAtk = set.getDouble("p_atk");
        this._pDef = set.getDouble("p_def");
        this._mAtk = set.getDouble("m_atk");
        this._mDef = set.getDouble("m_def");
        this._hp = set.getDouble("hp");
        this._mp = set.getDouble("mp");
        this._hpRegen = set.getDouble("hp_regen");
        this._mpRegen = set.getDouble("mp_regen");
        this._food = set.getIntegerArray("food", new int[0]);
        this._maxLoad = set.getInteger("max_load");
        this._battleMealConsumeOnRide = set.getInteger("battle_meal_consume_on_ride", 0);
        this._normalMealConsumeOnRide = set.getInteger("normal_meal_consume_on_ride", 0);
        this._walkSpdOnRide = set.getInteger("walk_speed_on_ride", 0);
        this._runSpdOnRide = set.getInteger("run_speed_on_ride", 0);
        this._waterWalkSpdOnRide = set.getInteger("water_walk_speed_on_ride", 0);
        this._waterRunSpdOnRide = set.getInteger("water_run_speed_on_ride", 0);
        this._flyWalkSpdOnRide = set.getInteger("fly_walk_speed_on_ride", 0);
        this._flyRunSpdOnRide = set.getInteger("fly_run_speed_on_ride", 0);
        this._atkSpdOnRide = set.getInteger("attack_speed_on_ride", 0);
        this._pAtkOnRide = set.getDouble("p_attack_on_ride", 0.0);
        this._mAtkOnRide = set.getDouble("m_attack_on_ride", 0.0);
        this._maxHpOnRide = set.getInteger("max_hp_on_ride", 0);
        this._maxMpOnRide = set.getInteger("max_mp_on_ride", 0);
    }

    public int getMaxMeal() {
        return this._maxMeal;
    }

    public long getExp() {
        return this._exp;
    }

    public int getExpType() {
        return this._expType;
    }

    public int getBattleMealConsume() {
        return this._battleMealConsume;
    }

    public int getNormalMealConsume() {
        return this._normalMealConsume;
    }

    public double getPAtk() {
        return this._pAtk;
    }

    public double getPDef() {
        return this._pDef;
    }

    public double getMAtk() {
        return this._mAtk;
    }

    public double getMDef() {
        return this._mDef;
    }

    public double getHP() {
        return this._hp;
    }

    public double getMP() {
        return this._mp;
    }

    public double getHPRegen() {
        return this._hpRegen;
    }

    public double getMPRegen() {
        return this._mpRegen;
    }

    public int[] getFood() {
        return this._food;
    }

    public int getHungryLimit() {
        return this._hungryLimit;
    }

    public int getSoulshotCount() {
        return this._soulshotCount;
    }

    public int getSpiritshotCount() {
        return this._spiritshotCount;
    }

    public int getMaxLoad() {
        return this._maxLoad;
    }

    public int getBattleMealConsumeOnRide() {
        return this._battleMealConsumeOnRide;
    }

    public int getNormalMealConsumeOnRide() {
        return this._normalMealConsumeOnRide;
    }

    public int getWalkSpdOnRide() {
        return this._walkSpdOnRide;
    }

    public int getRunSpdOnRide() {
        return this._runSpdOnRide;
    }

    public int getWaterWalkSpdOnRide() {
        return this._waterWalkSpdOnRide;
    }

    public int getWaterRunSpdOnRide() {
        return this._waterRunSpdOnRide;
    }

    public int getFlyWalkSpdOnRide() {
        return this._flyWalkSpdOnRide;
    }

    public int getFlyRunSpdOnRide() {
        return this._flyRunSpdOnRide;
    }

    public int getAtkSpdOnRide() {
        return this._atkSpdOnRide;
    }

    public double getPAtkOnRide() {
        return this._pAtkOnRide;
    }

    public double getMAtkOnRide() {
        return this._mAtkOnRide;
    }

    public int getMaxHpOnRide() {
        return this._maxHpOnRide;
    }

    public int getMaxMpOnRide() {
        return this._maxMpOnRide;
    }
}

