/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBR_AgathionEnergyInfoPacket
extends L2GameServerPacket {
    private int _size;
    private ItemInstance[] _itemList = null;

    public ExBR_AgathionEnergyInfoPacket(int size, ItemInstance ... item) {
        this._itemList = item;
        this._size = size;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._size);
        for (ItemInstance item : this._itemList) {
            this.writeD(item.getObjectId());
            this.writeD(item.getItemId());
            this.writeQ(0x200000L);
            this.writeD(item.getAgathionEnergy());
            this.writeD(item.getTemplate().getAgathionMaxEnergy());
        }
    }
}

