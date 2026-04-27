/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class EquipUpdate
extends L2GameServerPacket {
    private ItemInfo _item;

    public EquipUpdate(ItemInstance item, int change) {
        this._item = new ItemInfo(item);
        this._item.setLastChange(change);
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._item.getLastChange());
        this.writeD(this._item.getObjectId());
        this.writeD(this._item.getEquipSlot());
    }
}

