/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.item.data;

import l2s.gameserver.templates.item.data.ItemData;

public class ChancedItemData
extends ItemData {
    private final double _chance;

    public ChancedItemData(int id, long count, double chance) {
        super(id, count);
        this._chance = chance;
    }

    public double getChance() {
        return this._chance;
    }
}

