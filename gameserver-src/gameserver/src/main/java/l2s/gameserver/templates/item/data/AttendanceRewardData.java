/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.item.data;

import l2s.gameserver.templates.item.data.ItemData;

public class AttendanceRewardData
extends ItemData {
    private final boolean _unknown;
    private final boolean _best;

    public AttendanceRewardData(int id, long count, boolean unknown, boolean best) {
        super(id, count);
        this._unknown = unknown;
        this._best = best;
    }

    public boolean isUnknown() {
        return this._unknown;
    }

    public boolean isBest() {
        return this._best;
    }
}

