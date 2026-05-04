/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item.support;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.item.ExItemType;
import l2s.gameserver.templates.item.ItemGrade;

public class AppearanceStone {
    private final int _itemId;
    private final ShapeTargetType[] _targetTypes;
    private final ShapeTargetType _clientTargetType;
    private final ShapeType _type;
    private final ItemGrade[] _grades;
    private final long _cost;
    private final int _extractItemId;
    private final ExItemType[] _itemTypes;
    private final int _period;
    private final List<SkillEntry> _skills = new ArrayList<SkillEntry>();

    public AppearanceStone(int itemId, ShapeTargetType[] targetTypes, ShapeType type, ItemGrade[] grades, long cost, int extractItemId, ExItemType[] itemTypes, int period) {
        this._itemId = itemId;
        this._targetTypes = targetTypes;
        this._type = type;
        this._grades = grades;
        this._cost = cost;
        this._extractItemId = extractItemId;
        this._itemTypes = itemTypes;
        this._period = period;
        this._clientTargetType = this._targetTypes.length > 1 ? ShapeTargetType.ALL : this._targetTypes[0];
    }

    public int getItemId() {
        return this._itemId;
    }

    public ShapeTargetType[] getTargetTypes() {
        return this._targetTypes;
    }

    public ShapeTargetType getClientTargetType() {
        return this._clientTargetType;
    }

    public ShapeType getType() {
        return this._type;
    }

    public ItemGrade[] getGrades() {
        return this._grades;
    }

    public long getCost() {
        return this._cost;
    }

    public int getExtractItemId() {
        return this._extractItemId;
    }

    public ExItemType[] getItemTypes() {
        return this._itemTypes;
    }

    public int getPeriod() {
        return this._period;
    }

    public void addSkill(int id, int level) {
        SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, id, level);
        if (skillEntry != null) {
            this._skills.add(skillEntry);
        }
    }

    public List<SkillEntry> getSkills() {
        return this._skills;
    }

    public static enum ShapeTargetType {
        NONE,
        WEAPON,
        ARMOR,
        ACCESSORY,
        ALL;

    }

    public static enum ShapeType {
        NONE,
        NORMAL,
        BLESSED,
        FIXED,
        RESTORE;

    }
}

