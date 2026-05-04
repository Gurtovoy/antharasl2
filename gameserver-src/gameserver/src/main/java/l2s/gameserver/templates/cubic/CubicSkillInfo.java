package l2s.gameserver.templates.cubic;

import gnu.trove.map.hash.TIntIntHashMap;
import java.util.Iterator;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Skill;
import l2s.gameserver.templates.cubic.CubicReuseType;
import l2s.gameserver.templates.cubic.CubicTargetType;
import org.dom4j.Element;

public class CubicSkillInfo {
    private final Skill _skill;
    private final int _chance;
    private final CubicTargetType _targetType;
    private final boolean _canAttackDoor;
    private final TIntIntHashMap _chances = new TIntIntHashMap();
    private final int _delay;
    private final CubicReuseType _reuse;

    public CubicSkillInfo(Skill skill, int chance, CubicTargetType targetType, boolean canAttackDoor, int delay, CubicReuseType reuse) {
        this._skill = skill;
        this._chance = chance;
        this._targetType = targetType;
        this._canAttackDoor = canAttackDoor;
        this._delay = delay;
        this._reuse = reuse;
    }

    public Skill getSkill() {
        return this._skill;
    }

    public int getChance() {
        return this._chance;
    }

    public CubicTargetType getTargetType() {
        return this._targetType;
    }

    public boolean isCanAttackDoor() {
        return this._canAttackDoor;
    }

    public void addChance(int value, int chance) {
        this._chances.put(value, chance);
    }

    public int getChance(int a) {
        return this._chances.get(a);
    }

    public TIntIntHashMap getChances() {
        return this._chances;
    }

    public int getDelay() {
        return this._delay;
    }

    public CubicReuseType getReuseType() {
        return this._reuse;
    }

    public static CubicSkillInfo parse(Element element) {
        int id = Integer.parseInt(element.attributeValue("id"));
        int level = Integer.parseInt(element.attributeValue("level"));
        int useChance = element.attributeValue("use_chance") == null ? 100 : Integer.parseInt(element.attributeValue("use_chance"));
        CubicTargetType targetType = element.attributeValue("target_type") == null ? CubicTargetType.TARGET : CubicTargetType.valueOf(element.attributeValue("target_type").toUpperCase());
        boolean canAttackDoor = element.attributeValue("can_attack_door") == null ? false : Boolean.parseBoolean(element.attributeValue("can_attack_door"));
        int delay = element.attributeValue("delay") == null ? -1 : Integer.parseInt(element.attributeValue("delay"));
        CubicReuseType reuse = element.attributeValue("reuse") == null ? CubicReuseType.DEFAULT : CubicReuseType.valueOf(element.attributeValue("reuse").toUpperCase());
        Skill skill = SkillHolder.getInstance().getSkill(id, level);
        if (skill == null) {
            return null;
        }
        CubicSkillInfo skillInfo = new CubicSkillInfo(skill, useChance, targetType, canAttackDoor, delay, reuse);
        Iterator chanceIterator = element.elementIterator();
        while (chanceIterator.hasNext()) {
            Element chanceElement = (Element)chanceIterator.next();
            int min_hp_percent = Integer.parseInt(chanceElement.attributeValue("min_hp_percent"));
            int max_hp_percent = Integer.parseInt(chanceElement.attributeValue("max_hp_percent"));
            int value = Integer.parseInt(chanceElement.attributeValue("value"));
            for (int i = min_hp_percent; i <= max_hp_percent; ++i) {
                skillInfo.addChance(i, value);
            }
        }
        return skillInfo;
    }
}

