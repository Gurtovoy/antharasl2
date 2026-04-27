/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.item.data;

import l2s.gameserver.templates.item.data.RewardItemData;

public class CapsuledItemData
extends RewardItemData {
    private final int _enchantLevel;

    public CapsuledItemData(int id, long minCount, long maxCount, double chance, int enchantLevel) {
        super(id, minCount, maxCount, chance);
        this._enchantLevel = enchantLevel;
    }

    public int getEnchantLevel() {
        return this._enchantLevel;
    }
}

