package l2s.gameserver.model.items;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.Warehouse;

public class PcFreight
extends Warehouse {
    public PcFreight(Player player) {
        super(player.getObjectId());
    }

    public PcFreight(int objectId) {
        super(objectId);
    }

    @Override
    public ItemInstance.ItemLocation getItemLocation() {
        return ItemInstance.ItemLocation.FREIGHT;
    }
}

