package l2s.gameserver.templates.cubic;

import l2s.commons.math.random.RndSelector;
import l2s.gameserver.templates.cubic.CubicSkillInfo;
import l2s.gameserver.templates.cubic.CubicTargetType;
import l2s.gameserver.templates.cubic.CubicUseUpType;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.napile.primitive.pair.IntObjectPair;

public class CubicTemplate {
    private final int _id;
    private final int _level;
    private final int _slot;
    private final int _duration;
    private final int _delay;
    private final int _maxCount;
    private final CubicUseUpType _useUp;
    private final double _power;
    private final CubicTargetType _targetType;
    private final RndSelector<CubicSkillInfo> _skills = new RndSelector(true);
    private final IntObjectMap<CubicSkillInfo> _timeSkills = new HashIntObjectMap();

    public CubicTemplate(int id, int level, int slot, int duration, int delay, int maxCount, CubicUseUpType useUp, double power, CubicTargetType targetType) {
        this._id = id;
        this._level = level;
        this._slot = slot;
        this._duration = duration;
        this._delay = delay;
        this._maxCount = maxCount;
        this._useUp = useUp;
        this._power = power;
        this._targetType = targetType;
    }

    public void putSkill(CubicSkillInfo skill, int chance) {
        this._skills.add(skill, chance);
    }

    public CubicSkillInfo getRandomSkill() {
        return (CubicSkillInfo)this._skills.chance();
    }

    public void putTimeSkill(CubicSkillInfo skill) {
        this._timeSkills.put(skill.getDelay(), skill);
    }

    public CubicSkillInfo getTimeSkill(int lifeTime) {
        CubicSkillInfo skill = null;
        for (IntObjectPair pair : this._timeSkills.entrySet()) {
            if (lifeTime % pair.getKey() != 0 || skill != null && skill.getDelay() <= pair.getKey()) continue;
            skill = (CubicSkillInfo)pair.getValue();
        }
        return skill;
    }

    public int getDuration() {
        return this._duration;
    }

    public int getDelay() {
        return this._delay;
    }

    public int getId() {
        return this._id;
    }

    public int getLevel() {
        return this._level;
    }

    public int getSlot() {
        return this._slot;
    }

    public int getMaxCount() {
        return this._maxCount;
    }

    public CubicUseUpType getUseUp() {
        return this._useUp;
    }

    public double getPower() {
        return this._power;
    }

    public CubicTargetType getTargetType() {
        return this._targetType;
    }
}

