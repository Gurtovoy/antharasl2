package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.templates.item.data.ItemData;

public final class SkillLearn
implements Comparable<SkillLearn> {
    private final int _id;
    private final int _level;
    private final int _hashCode;
    private final int _minLevel;
    private final int _cost;
    private final int _itemId;
    private final long _itemCount;
    private final Race _race;
    private final boolean _autoGet;
    private final ClassLevel _classLevel;
    private final List<ItemData> _additionalRequiredItems = new ArrayList<ItemData>();
    private final List<ItemData> _allRequiredItems = new ArrayList<ItemData>();
    private final List<Condition> _conditions = new ArrayList<Condition>();

    public SkillLearn(int id, int lvl, int minLvl, int cost, int itemId, long itemCount, boolean autoGet, Race race, ClassLevel classLevel) {
        this._id = id;
        this._level = lvl;
        this._hashCode = SkillHolder.getInstance().getHashCode(this._id, this._level);
        this._minLevel = minLvl;
        this._cost = cost;
        this._itemId = itemId;
        this._itemCount = itemCount;
        if (itemId > 0 && itemCount > 0L) {
            this._allRequiredItems.add(new ItemData(itemId, itemCount));
        }
        this._autoGet = autoGet;
        this._race = race;
        this._classLevel = classLevel;
    }

    public SkillLearn(int id, int lvl, int minLvl, int cost, int itemId, long itemCount, boolean autoGet, Race race) {
        this(id, lvl, minLvl, cost, itemId, itemCount, autoGet, race, ClassLevel.NONE);
    }

    public int getId() {
        return this._id;
    }

    public int getLevel() {
        return this._level;
    }

    public int getMinLevel() {
        return this._minLevel;
    }

    public int getCost() {
        return this._cost;
    }

    public int getItemId() {
        return this._itemId;
    }

    public long getItemCount() {
        return this._itemCount;
    }

    public boolean isAutoGet() {
        return this._autoGet;
    }

    public Race getRace() {
        return this._race;
    }

    public boolean isFreeAutoGet(AcquireType type) {
        return this.isAutoGet() && this.getCost() == 0 && !this.haveRequiredItemsForLearn(type);
    }

    public boolean isOfRace(Race race) {
        return this._race == null || this._race == race;
    }

    public ClassLevel getClassLevel() {
        return this._classLevel;
    }

    public void addAdditionalRequiredItem(int id, long count) {
        if (id > 0 && count > 0L) {
            ItemData item = new ItemData(id, count);
            this._additionalRequiredItems.add(item);
            this._allRequiredItems.add(item);
        }
    }

    public void addAdditionalRequiredItems(List<ItemData> items) {
        this._additionalRequiredItems.addAll(items);
        this._allRequiredItems.addAll(items);
    }

    public List<ItemData> getAdditionalRequiredItems() {
        return this._additionalRequiredItems;
    }

    public List<ItemData> getRequiredItemsForLearn(AcquireType type) {
        if (Config.DISABLED_SPELLBOOKS_FOR_ACQUIRE_TYPES.contains(type)) {
            return this._additionalRequiredItems;
        }
        return this._allRequiredItems;
    }

    public boolean haveRequiredItemsForLearn(AcquireType type) {
        return !this.getRequiredItemsForLearn(type).isEmpty();
    }

    public void addCondition(Condition condition) {
        this._conditions.add(condition);
    }

    public boolean testCondition(Player player) {
        if (this._conditions.isEmpty()) {
            return true;
        }
        Env env = new Env();
        env.character = player;
        for (Condition condition : this._conditions) {
            if (condition.test(env)) continue;
            return false;
        }
        return true;
    }

    public int hashCode() {
        return this._hashCode;
    }

    @Override
    public int compareTo(SkillLearn o) {
        if (this.getId() == o.getId()) {
            return this.getLevel() - o.getLevel();
        }
        return this.getId() - o.getId();
    }
}

