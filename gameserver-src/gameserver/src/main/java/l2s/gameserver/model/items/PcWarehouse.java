/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.items;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.Warehouse;

public class PcWarehouse
extends Warehouse {
    public PcWarehouse(Player owner) {
        super(owner.getObjectId());
    }

    public PcWarehouse(int ownerId) {
        super(ownerId);
    }

    @Override
    public ItemInstance.ItemLocation getItemLocation() {
        return ItemInstance.ItemLocation.WAREHOUSE;
    }
}

