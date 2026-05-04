/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PetItemListPacket
extends L2GameServerPacket {
    private ItemInstance[] items;

    public PetItemListPacket(PetInstance cha) {
        this.items = cha.getInventory().getItems();
    }

    @Override
    protected final void writeImpl() {
        this.writeH(this.items.length);
        for (ItemInstance item : this.items) {
            this.writeItemInfo(item);
        }
    }
}

