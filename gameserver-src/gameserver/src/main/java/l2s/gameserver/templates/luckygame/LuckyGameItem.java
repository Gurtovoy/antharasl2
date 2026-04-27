/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.luckygame;

import l2s.gameserver.templates.item.data.RewardItemData;

public class LuckyGameItem
extends RewardItemData {
    public final boolean _fantastic;

    private LuckyGameItem(int itemId, long minCount, long maxCount, double chance, boolean fantastic) {
        super(itemId, minCount, maxCount, chance);
        this._fantastic = fantastic;
    }

    public LuckyGameItem(int itemId, long minCount, long maxCount, double chance) {
        this(itemId, minCount, maxCount, chance, false);
    }

    public LuckyGameItem(int itemId, long count, boolean fantastic) {
        this(itemId, count, 0L, 0.0, fantastic);
    }

    public LuckyGameItem(int itemId, long count) {
        this(itemId, count, 0L, 0.0, false);
    }

    public boolean isFantastic() {
        return this._fantastic;
    }
}

