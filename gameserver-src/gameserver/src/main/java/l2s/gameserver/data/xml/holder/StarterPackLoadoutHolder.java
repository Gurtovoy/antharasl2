package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.commons.data.xml.AbstractHolder;

public final class StarterPackLoadoutHolder extends AbstractHolder {
    private static final StarterPackLoadoutHolder _instance = new StarterPackLoadoutHolder();
    private int _level = 10;
    private final List<Integer> _warriorWeapons = new ArrayList<Integer>();
    private final List<Integer> _mageWeapons = new ArrayList<Integer>();
    private final List<Integer> _lightArmor = new ArrayList<Integer>();
    private final List<Integer> _magicArmor = new ArrayList<Integer>();
    private final List<Integer> _accessories = new ArrayList<Integer>();
    private int _warriorConsumableId = 5789;
    private long _warriorConsumableCount = 10000L;
    private int _mageConsumableId = 5790;
    private long _mageConsumableCount = 3000L;
    private int _scrollId = 29011;
    private long _scrollCount = 20L;
    private long _scrollRebuffCooldownMs = 10000L;

    public static StarterPackLoadoutHolder getInstance() {
        return _instance;
    }

    public void setLevel(int level) {
        this._level = Math.max(1, level);
    }

    public int getLevel() {
        return this._level;
    }

    public List<Integer> getWarriorWeapons() {
        return Collections.unmodifiableList(this._warriorWeapons);
    }

    public List<Integer> getMageWeapons() {
        return Collections.unmodifiableList(this._mageWeapons);
    }

    public List<Integer> getLightArmor() {
        return Collections.unmodifiableList(this._lightArmor);
    }

    public List<Integer> getMagicArmor() {
        return Collections.unmodifiableList(this._magicArmor);
    }

    public List<Integer> getAccessories() {
        return Collections.unmodifiableList(this._accessories);
    }

    public void addWarriorWeapon(int itemId) {
        this._warriorWeapons.add(itemId);
    }

    public void addMageWeapon(int itemId) {
        this._mageWeapons.add(itemId);
    }

    public void addLightArmor(int itemId) {
        this._lightArmor.add(itemId);
    }

    public void addMagicArmor(int itemId) {
        this._magicArmor.add(itemId);
    }

    public void addAccessory(int itemId) {
        this._accessories.add(itemId);
    }

    public int getWarriorConsumableId() {
        return this._warriorConsumableId;
    }

    public void setWarriorConsumable(int itemId, long count) {
        this._warriorConsumableId = itemId;
        this._warriorConsumableCount = Math.max(0L, count);
    }

    public long getWarriorConsumableCount() {
        return this._warriorConsumableCount;
    }

    public int getMageConsumableId() {
        return this._mageConsumableId;
    }

    public void setMageConsumable(int itemId, long count) {
        this._mageConsumableId = itemId;
        this._mageConsumableCount = Math.max(0L, count);
    }

    public long getMageConsumableCount() {
        return this._mageConsumableCount;
    }

    public int getScrollId() {
        return this._scrollId;
    }

    public long getScrollCount() {
        return this._scrollCount;
    }

    public long getScrollRebuffCooldownMs() {
        return this._scrollRebuffCooldownMs;
    }

    public void setScroll(int itemId, long count, long rebuffCooldownMs) {
        this._scrollId = itemId;
        this._scrollCount = Math.max(0L, count);
        this._scrollRebuffCooldownMs = Math.max(0L, rebuffCooldownMs);
    }

    public int size() {
        return this._warriorWeapons.size() + this._mageWeapons.size() + this._lightArmor.size() + this._magicArmor.size() + this._accessories.size();
    }

    public void clear() {
        this._level = 10;
        this._warriorWeapons.clear();
        this._mageWeapons.clear();
        this._lightArmor.clear();
        this._magicArmor.clear();
        this._accessories.clear();
        this._warriorConsumableId = 5789;
        this._warriorConsumableCount = 10000L;
        this._mageConsumableId = 5790;
        this._mageConsumableCount = 3000L;
        this._scrollId = 29011;
        this._scrollCount = 20L;
        this._scrollRebuffCooldownMs = 10000L;
    }
}
