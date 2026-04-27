/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExGetCrystalizingEstimation
extends L2GameServerPacket {
    private final int _crystalId;
    private final long _crystalCount;

    public ExGetCrystalizingEstimation(ItemInstance item) {
        this._crystalId = item.getGrade().getCrystalId();
        this._crystalCount = item.getCrystalCountOnCrystallize();
    }

    @Override
    protected final void writeImpl() {
        if (this._crystalId > 0 && this._crystalCount > 0L) {
            this.writeD(1);
            this.writeD(this._crystalId);
            this.writeQ(this._crystalCount);
            this.writeF(100.0);
        } else {
            this.writeD(0);
        }
    }
}

