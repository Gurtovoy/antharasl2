/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.items;

import java.util.Collection;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PetInventoryUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.utils.ItemFunctions;

public class PetInventory
extends Inventory {
    private final PetInstance _actor;

    public PetInventory(PetInstance actor) {
        super(actor.getPlayer().getObjectId());
        this._actor = actor;
    }

    @Override
    public PetInstance getActor() {
        return this._actor;
    }

    public Player getOwner() {
        return this._actor.getPlayer();
    }

    @Override
    protected ItemInstance.ItemLocation getBaseLocation() {
        return ItemInstance.ItemLocation.PET_INVENTORY;
    }

    @Override
    protected ItemInstance.ItemLocation getEquipLocation() {
        return ItemInstance.ItemLocation.PET_PAPERDOLL;
    }

    @Override
    protected void onRefreshWeight() {
        this.getActor().sendPetInfo();
    }

    @Override
    public void sendAddItem(ItemInstance item) {
        this.getOwner().sendPacket((IBroadcastPacket)new PetInventoryUpdatePacket().addNewItem(item));
    }

    @Override
    public void sendModifyItem(ItemInstance ... items) {
        PetInventoryUpdatePacket piu = new PetInventoryUpdatePacket();
        for (ItemInstance item : items) {
            piu.addModifiedItem(item);
        }
        this.getOwner().sendPacket((IBroadcastPacket)piu);
    }

    @Override
    public void sendRemoveItem(ItemInstance item) {
        this.getOwner().sendPacket((IBroadcastPacket)new PetInventoryUpdatePacket().addRemovedItem(item));
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public void restore() {
        int ownerId = this.getOwnerId();
        this.writeLock();
        try {
            Collection<ItemInstance> items = _itemsDAO.getItemsByOwnerIdAndLoc(ownerId, this.getBaseLocation());
            for (ItemInstance item : items) {
                this._items.add(item);
                this.onRestoreItem(item);
            }
            items = _itemsDAO.getItemsByOwnerIdAndLoc(ownerId, this.getEquipLocation());
            for (ItemInstance item : items) {
                this._items.add(item);
                this.onRestoreItem(item);
                if (ItemFunctions.checkIfCanEquip(this.getActor(), item) != null) continue;
                this.setPaperdollItem(item.getEquipSlot(), item);
            }
        }
        finally {
            this.writeUnlock();
        }
        this.refreshWeight();
        this.checkItems();
    }

    @Override
    public void store() {
        this.writeLock();
        try {
            _itemsDAO.update(this._items);
        }
        finally {
            this.writeUnlock();
        }
    }

    @Override
    protected void onTemporalItemTimeEnd(ItemInstance item) {
        this.getOwner().sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HAS_EXPIRED).addItemName(item.getItemId()));
    }

    public void validateItems() {
        for (ItemInstance item : this._paperdoll) {
            if (item == null || ItemFunctions.checkIfCanEquip(this.getActor(), item) == null && item.getTemplate().testCondition(this.getActor(), item, false)) continue;
            this.unEquipItem(item);
        }
    }
}

