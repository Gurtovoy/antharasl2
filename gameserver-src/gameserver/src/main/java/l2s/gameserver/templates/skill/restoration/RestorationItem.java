/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.templates.skill.restoration;

import l2s.commons.util.Rnd;

public final class RestorationItem {
    private final int _id;
    private final int _minCount;
    private final int _maxCount;
    private final int _enchantLevel;

    public RestorationItem(int id, int minCount, int maxCount, int enchantLevel) {
        this._id = id;
        this._minCount = minCount;
        this._maxCount = maxCount;
        this._enchantLevel = enchantLevel;
    }

    public int getId() {
        return this._id;
    }

    public int getMinCount() {
        return this._minCount;
    }

    public int getMaxCount() {
        return this._maxCount;
    }

    public int getRandomCount() {
        return Rnd.get((int)this._minCount, (int)this._maxCount);
    }

    public int getEnchantLevel() {
        return this._enchantLevel;
    }
}

