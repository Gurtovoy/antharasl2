/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.item.support;

import l2s.gameserver.templates.item.data.ItemData;

public class SynthesisData {
    private final int _item1Id;
    private final int _item2Id;
    private final double _chance;
    private final ItemData _successItemData;
    private final ItemData _failItemData;
    private final int _resultEffecttype;
    private final int[] _locationIds;

    public SynthesisData(int item1Id, int item2Id, double chance, ItemData successItemData, ItemData failItemData, int resultEffecttype, int[] locationIds) {
        this._item1Id = item1Id;
        this._item2Id = item2Id;
        this._chance = chance;
        this._successItemData = successItemData;
        this._failItemData = failItemData;
        this._resultEffecttype = resultEffecttype;
        this._locationIds = locationIds;
    }

    public int getItem1Id() {
        return this._item1Id;
    }

    public int getItem2Id() {
        return this._item2Id;
    }

    public double getChance() {
        return this._chance;
    }

    public ItemData getSuccessItemData() {
        return this._successItemData;
    }

    public ItemData getFailItemData() {
        return this._failItemData;
    }

    public int getResultEffecttype() {
        return this._resultEffecttype;
    }

    public int[] getLocationIds() {
        return this._locationIds;
    }
}

