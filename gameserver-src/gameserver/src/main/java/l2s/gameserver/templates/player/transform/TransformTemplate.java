/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntDoubleMap
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntDoubleHashMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  gnu.trove.set.TIntSet
 *  gnu.trove.set.hash.TIntHashSet
 */
package l2s.gameserver.templates.player.transform;

import gnu.trove.map.TIntDoubleMap;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntDoubleHashMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.BaseStats;
import l2s.gameserver.model.base.TransformType;
import l2s.gameserver.model.items.LockType;
import l2s.gameserver.templates.BaseStatsBonus;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.player.HpMpCpData;
import l2s.gameserver.templates.player.PCTemplate;

public class TransformTemplate
extends PCTemplate {
    private final int _id;
    private final TransformType _type;
    private final boolean _canSwim;
    private final int _spawnHeight;
    private final boolean _normalAttackable;
    private final TIntObjectMap<BaseStatsBonus> _baseStatsBonuses = new TIntObjectHashMap();
    private final TIntDoubleMap _levelBonusData = new TIntDoubleHashMap();
    private final TIntObjectMap<HpMpCpData> _hpMpCpData = new TIntObjectHashMap();
    private final TIntSet _actions = new TIntHashSet();
    private final List<SkillLearn> _skills = new ArrayList<SkillLearn>();
    private final List<SkillLearn> _additionalSkills = new ArrayList<SkillLearn>();
    private LockType _itemCheckType = LockType.NONE;
    private final TIntSet _itemCheckIDs = new TIntHashSet();

    public TransformTemplate(StatsSet set) {
        super(set);
        this._id = set.getInteger("id");
        this._type = (TransformType)set.getEnum("type", TransformType.class, TransformType.COMBAT);
        this._canSwim = set.getBool("can_swim", false);
        this._spawnHeight = set.getInteger("spawn_height", 0);
        this._normalAttackable = set.getBool("normal_attackable", true);
    }

    @Override
    public int getId() {
        return this._id;
    }

    public TransformType getType() {
        return this._type;
    }

    public boolean isCanSwim() {
        return this._canSwim;
    }

    public int getSpawnHeight() {
        return this._spawnHeight;
    }

    public boolean isNormalAttackable() {
        return this._normalAttackable;
    }

    @Override
    public double getBaseHpMax(int level) {
        HpMpCpData data = (HpMpCpData)this._hpMpCpData.get(level);
        if (data != null) {
            return data.getHP();
        }
        return 0.0;
    }

    @Override
    public double getBaseMpMax(int level) {
        HpMpCpData data = (HpMpCpData)this._hpMpCpData.get(level);
        if (data != null) {
            return data.getMP();
        }
        return 0.0;
    }

    @Override
    public double getBaseCpMax(int level) {
        HpMpCpData data = (HpMpCpData)this._hpMpCpData.get(level);
        if (data != null) {
            return data.getCP();
        }
        return 0.0;
    }

    public void addBaseStatsBonus(int value, BaseStatsBonus bonus) {
        this._baseStatsBonuses.put(value, bonus);
    }

    public double getBaseStatBonus(int value, BaseStats stat) {
        BaseStatsBonus bonus = (BaseStatsBonus)this._baseStatsBonuses.get(value);
        if (bonus != null) {
            return bonus.get(stat);
        }
        return 0.0;
    }

    public void addLevelBonus(int level, double bonus) {
        this._levelBonusData.put(level, bonus);
    }

    public double getLevelBonus(int level) {
        return this._levelBonusData.get(level);
    }

    public void addHpMpCpData(int level, HpMpCpData data) {
        this._hpMpCpData.put(level, data);
    }

    public void addAction(int action) {
        this._actions.add(action);
    }

    public int[] getActions() {
        int[] actions = this._actions.toArray();
        Arrays.sort(actions);
        return actions;
    }

    public boolean haveAction(int id) {
        return this._actions.contains(id);
    }

    public void setItemCheck(LockType type, int[] items) {
        this._itemCheckType = type;
        this._itemCheckIDs.addAll(items);
    }

    public LockType getItemCheckType() {
        return this._itemCheckType;
    }

    public int[] getItemCheckIDs() {
        return this._itemCheckIDs.toArray();
    }

    public void addSkill(SkillLearn skill) {
        this._skills.add(skill);
    }

    public SkillLearn[] getSkills() {
        return this._skills.toArray(new SkillLearn[this._skills.size()]);
    }

    public void addAddtionalSkill(SkillLearn skill) {
        this._additionalSkills.add(skill);
    }

    public SkillLearn getAdditionalSkill(int skillId, int skillLevel) {
        for (SkillLearn skill : this._additionalSkills) {
            if (skill.getId() != skillId || skill.getLevel() != skillLevel) continue;
            return skill;
        }
        return null;
    }

    public SkillLearn[] getAddtionalSkills() {
        return this._additionalSkills.toArray(new SkillLearn[this._additionalSkills.size()]);
    }

    public static StatsSet getEmptyStatsSet() {
        StatsSet set = new StatsSet();
        set.set("baseINT", 0);
        set.set("baseSTR", 0);
        set.set("baseCON", 0);
        set.set("baseMEN", 0);
        set.set("baseDEX", 0);
        set.set("baseWIT", 0);
        set.set("basePAtk", 0);
        set.set("baseMAtk", 0);
        set.set("basePDef", 0);
        set.set("baseMDef", 0);
        set.set("basePAtkSpd", 0);
        set.set("baseMAtkSpd", 0);
        set.set("baseShldDef", 0);
        set.set("baseAtkRange", 0);
        set.set("damage_range", "0;0;0;0");
        set.set("baseShldRate", 0);
        set.set("basePCritRate", 0);
        set.set("baseMCritRate", 0);
        set.set("baseRunSpd", 0);
        set.set("baseWalkSpd", 0);
        set.set("baseWaterRunSpd", 0);
        set.set("baseWaterWalkSpd", 0);
        set.set("collision_radius", 0);
        set.set("collision_height", 0);
        set.set("baseAttackType", "NONE");
        set.set("baseChestDef", 0);
        set.set("baseLegsDef", 0);
        set.set("baseHelmetDef", 0);
        set.set("baseBootsDef", 0);
        set.set("baseGlovesDef", 0);
        set.set("basePendantDef", 0);
        set.set("baseCloakDef", 0);
        set.set("baseREarDef", 0);
        set.set("baseLEarDef", 0);
        set.set("baseRRingDef", 0);
        set.set("baseLRingDef", 0);
        set.set("baseNecklaceDef", 0);
        set.set("baseRandDam", 0);
        set.set("baseFlyRunSpd", 0);
        set.set("baseFlyWalkSpd", 0);
        set.set("baseRideRunSpd", 0);
        set.set("baseRideWalkSpd", 0);
        return set;
    }
}

