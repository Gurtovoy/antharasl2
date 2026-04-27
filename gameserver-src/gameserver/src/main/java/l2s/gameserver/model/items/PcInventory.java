/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dao.JdbcEntityState
 *  org.apache.commons.lang3.ArrayUtils
 */
package l2s.gameserver.model.items;

import java.util.Collection;
import java.util.Collections;
import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.LockType;
import l2s.gameserver.model.items.listeners.AccessoryListener;
import l2s.gameserver.model.items.listeners.ArmorSetListener;
import l2s.gameserver.model.items.listeners.BowListener;
import l2s.gameserver.model.items.listeners.ItemAugmentationListener;
import l2s.gameserver.model.items.listeners.ItemEnchantOptionsListener;
import l2s.gameserver.model.items.listeners.ItemSkillsListener;
import l2s.gameserver.model.items.listeners.RodListener;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExAdenaInvenCount;
import l2s.gameserver.network.l2.s2c.ExBR_AgathionEnergyInfoPacket;
import l2s.gameserver.network.l2.s2c.ExUserInfoEquipSlot;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.taskmanager.DelayedItemsManager;
import l2s.gameserver.templates.item.EtcItemTemplate;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.utils.ItemFunctions;
import org.apache.commons.lang3.ArrayUtils;

public class PcInventory
extends Inventory {
    private final Player _owner;
    private LockType _lockType = LockType.NONE;
    private int[] _lockItems = ArrayUtils.EMPTY_INT_ARRAY;
    private int questItemsSize = 0;

    public PcInventory(Player owner) {
        super(owner.getObjectId());
        this._owner = owner;
        this.addListener(ItemSkillsListener.getInstance());
        this.addListener(ItemAugmentationListener.getInstance());
        this.addListener(ItemEnchantOptionsListener.getInstance());
        this.addListener(ArmorSetListener.getInstance());
        this.addListener(BowListener.getInstance());
        this.addListener(AccessoryListener.getInstance());
        this.addListener(RodListener.getInstance());
    }

    @Override
    public Player getActor() {
        return this._owner;
    }

    @Override
    protected ItemInstance.ItemLocation getBaseLocation() {
        return ItemInstance.ItemLocation.INVENTORY;
    }

    @Override
    protected ItemInstance.ItemLocation getEquipLocation() {
        return ItemInstance.ItemLocation.PAPERDOLL;
    }

    public ItemInstance addAdena(long amount) {
        return this.addItem(57, amount);
    }

    public boolean reduceAdena(long adena) {
        return this.destroyItemByItemId(57, adena);
    }

    public int getPaperdollVariation1Id(int slot) {
        ItemInstance item = this._paperdoll[slot];
        if (item != null && item.isAugmented()) {
            return item.getVariation1Id();
        }
        return 0;
    }

    public int getPaperdollVariation2Id(int slot) {
        ItemInstance item = this._paperdoll[slot];
        if (item != null && item.isAugmented()) {
            return item.getVariation2Id();
        }
        return 0;
    }

    @Override
    public int getPaperdollVisualId(int slot) {
        Player player = this.getActor();
        int itemId = super.getPaperdollVisualId(slot);
        if (player.isInTrainingCamp() && (slot == 7 || slot == 14)) {
            itemId = 135;
        }
        return itemId;
    }

    @Override
    protected void onRefreshWeight() {
        this.getActor().refreshOverloaded();
    }

    public void validateItems() {
        for (ItemInstance item : this._paperdoll) {
            if (item == null || ItemFunctions.checkIfCanEquip(this.getActor(), item) == null && item.getTemplate().testCondition(this.getActor(), item, false)) continue;
            this.unEquipItem(item);
            this.getActor().sendDisarmMessage(item);
        }
    }

    public void refreshEquip() {
        Player actor = this.getActor();
        int flags = 0;
        for (ItemInstance item : this.getItems()) {
            flags |= item.onRefreshEquip(actor, false);
        }
        if ((flags & 1) != 0) {
            actor.updateStats();
        }
        if ((flags & 3) == 3) {
            actor.sendSkillList();
        }
    }

    public void refreshEquip(ItemInstance item) {
        if (this.containsItem(item)) {
            item.onRefreshEquip(this.getActor());
        }
    }

    public void sort(int[][] order) {
        boolean needSort = false;
        for (int[] element : order) {
            ItemInstance item = this.getItemByObjectId(element[0]);
            if (item == null || item.getLocation() != ItemInstance.ItemLocation.INVENTORY || item.getLocData() == element[1]) continue;
            item.setLocData(element[1]);
            item.setJdbcState(JdbcEntityState.UPDATED);
            needSort = true;
        }
        if (needSort) {
            Collections.sort(this._items, Inventory.ItemOrderComparator.getInstance());
        }
    }

    public ItemInstance findArrowForBow(ItemTemplate bow) {
        ItemInstance res = null;
        for (ItemInstance temp : this.getItems()) {
            if (temp.getItemType() != EtcItemTemplate.EtcItemType.ARROW && temp.getItemType() != EtcItemTemplate.EtcItemType.ARROW_QUIVER || bow.getGrade().extOrdinal() != temp.getGrade().extOrdinal()) continue;
            if (temp.getLocation() == ItemInstance.ItemLocation.PAPERDOLL && temp.getEquipSlot() == 8) {
                return temp;
            }
            if (res != null && temp.getItemId() >= res.getItemId()) continue;
            res = temp;
        }
        return res;
    }

    public ItemInstance findArrowForCrossbow(ItemTemplate crossbow) {
        ItemInstance res = null;
        for (ItemInstance temp : this.getItems()) {
            if (temp.getItemType() != EtcItemTemplate.EtcItemType.BOLT && temp.getItemType() != EtcItemTemplate.EtcItemType.BOLT_QUIVER || crossbow.getGrade().extOrdinal() != temp.getGrade().extOrdinal()) continue;
            if (temp.getLocation() == ItemInstance.ItemLocation.PAPERDOLL && temp.getEquipSlot() == 8) {
                return temp;
            }
            if (res != null && temp.getItemId() >= res.getItemId()) continue;
            res = temp;
        }
        return res;
    }

    public void lockItems(LockType lock, int[] items) {
        if (this._lockType != LockType.NONE) {
            return;
        }
        this._lockType = lock;
        this._lockItems = items;
        this.getActor().sendItemList(false);
    }

    public void unlock() {
        if (this._lockType == LockType.NONE) {
            return;
        }
        this._lockType = LockType.NONE;
        this._lockItems = ArrayUtils.EMPTY_INT_ARRAY;
        this.getActor().sendItemList(false);
    }

    public boolean isLockedItem(ItemInstance item) {
        switch (this._lockType) {
            case INCLUDE: {
                return ArrayUtils.contains((int[])this._lockItems, (int)item.getItemId());
            }
            case EXCLUDE: {
                return !ArrayUtils.contains((int[])this._lockItems, (int)item.getItemId());
            }
        }
        return false;
    }

    public LockType getLockType() {
        return this._lockType;
    }

    public int[] getLockItems() {
        return this._lockItems;
    }

    @Override
    protected void onRestoreItem(ItemInstance item) {
        super.onRestoreItem(item);
        if (item.getTemplate().isRune()) {
            item.onEquip(-1, this.getActor());
        }
        for (QuestState state : this._owner.getAllQuestsStates()) {
            state.getQuest().notifyUpdateItem(item, state);
        }
    }

    @Override
    protected void onAddItem(ItemInstance item) {
        Player p = this.getActor();
        super.onAddItem(item);
        if (item.getItemId() == 999999999) {
            p.broadcastUserInfo(true);
        }
        if (item.getTemplate().isRune()) {
            item.onEquip(-1, this.getActor());
        }
        if (item.getTemplate().isArrow() || item.getTemplate().isBolt() || item.getTemplate().isQuiver()) {
            this.getActor().checkAndEquipArrows();
        }
        for (QuestState state : this._owner.getAllQuestsStates()) {
            state.getQuest().notifyUpdateItem(item, state);
        }
        if (item.getTemplate().isQuest()) {
            this.refreshItemsSize();
        }
    }

    @Override
    protected void onModifyItem(ItemInstance item) {
        super.onModifyItem(item);
        for (QuestState state : this._owner.getAllQuestsStates()) {
            state.getQuest().notifyUpdateItem(item, state);
        }
        if (item.getTemplate().isQuest()) {
            this.refreshItemsSize();
        }
    }

    @Override
    protected void onRemoveItem(ItemInstance item) {
        PetInstance pet;
        super.onRemoveItem(item);
        Player owner = this.getActor();
        owner.removeItemFromShortCut(item.getObjectId());
        if (item.getItemId() == 999999999) {
            owner.broadcastUserInfo(true);
        }
        if (item.getTemplate().isRune()) {
            item.onUnequip(-1, this.getActor());
        }
        if (owner.getMountControlItemObjId() == item.getObjectId()) {
            owner.setMount(null);
        }
        if (owner.getPetControlItem() == item && (pet = owner.getPet()) != null) {
            pet.unSummon(false);
        }
        for (QuestState state : this._owner.getAllQuestsStates()) {
            state.getQuest().notifyUpdateItem(item, state);
        }
        if (item.getTemplate().isQuest()) {
            this.refreshItemsSize();
        }
    }

    @Override
    protected boolean onEquip(int slot, ItemInstance item) {
        if (!super.onEquip(slot, item)) {
            return false;
        }
        if (item.isShadowItem()) {
            item.startManaConsumeTask(new ManaConsumeTask(item));
        }
        return true;
    }

    @Override
    protected boolean onReequip(int slot, ItemInstance newItem, ItemInstance oldItem) {
        boolean equipped = super.onReequip(slot, newItem, oldItem);
        if (oldItem.isShadowItem()) {
            oldItem.stopManaConsumeTask();
        }
        if (equipped) {
            if (newItem.isShadowItem()) {
                newItem.startManaConsumeTask(new ManaConsumeTask(newItem));
            }
            return true;
        }
        return false;
    }

    @Override
    protected void onUnequip(int slot, ItemInstance item) {
        super.onUnequip(slot, item);
        if (item.isShadowItem()) {
            item.stopManaConsumeTask();
        }
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
            Collections.sort(this._items, Inventory.ItemOrderComparator.getInstance());
            items = _itemsDAO.getItemsByOwnerIdAndLoc(ownerId, this.getEquipLocation());
            for (ItemInstance item : items) {
                this._items.add(item);
                this.onRestoreItem(item);
                if (item.getEquipSlot() >= 38 || !PcInventory.checkPaperdollItem(item, item.getEquipSlot()) || this.getPaperdollItem(item.getEquipSlot()) != null) {
                    item.setLocation(this.getBaseLocation());
                    item.setLocData(0);
                    item.setEquipped(false);
                    item.setJdbcState(JdbcEntityState.UPDATED);
                    continue;
                }
                this.setPaperdollItem(item.getEquipSlot(), item);
            }
        }
        finally {
            this.writeUnlock();
        }
        DelayedItemsManager.getInstance().loadDelayed(this.getActor(), false);
        this.refreshWeight();
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
    public void sendAddItem(ItemInstance item) {
        Player actor = this.getActor();
        actor.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addNewItem(actor, item));
        if (item.getItemId() == 57) {
            actor.sendPacket((IBroadcastPacket)new ExAdenaInvenCount(actor));
        }
        if (item.getTemplate().getAgathionMaxEnergy() > 0) {
            actor.sendPacket((IBroadcastPacket)new ExBR_AgathionEnergyInfoPacket(1, item));
        }
    }

    @Override
    public void sendModifyItem(ItemInstance ... items) {
        Player actor = this.getActor();
        InventoryUpdatePacket iu = new InventoryUpdatePacket();
        for (ItemInstance item : items) {
            iu.addModifiedItem(actor, item);
        }
        actor.sendPacket((IBroadcastPacket)iu);
        for (ItemInstance item : items) {
            if (item.getItemId() == 57) {
                actor.sendPacket((IBroadcastPacket)new ExAdenaInvenCount(actor));
            }
            if (item.getTemplate().getAgathionMaxEnergy() <= 0) continue;
            actor.sendPacket((IBroadcastPacket)new ExBR_AgathionEnergyInfoPacket(1, item));
        }
    }

    @Override
    public void sendRemoveItem(ItemInstance item) {
        Player actor = this.getActor();
        actor.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addRemovedItem(actor, item));
        if (item.getItemId() == 57) {
            actor.sendPacket((IBroadcastPacket)new ExAdenaInvenCount(actor));
        }
    }

    @Override
    public void sendEquipInfo(int slot) {
        this.getActor().broadcastUserInfo(true);
        this.getActor().sendPacket((IBroadcastPacket)new ExUserInfoEquipSlot(this.getActor(), slot));
    }

    @Override
    protected void onItemVisualTimeEnd(ItemInstance item) {
        if (item.isEquipped()) {
            this.sendEquipInfo(item.getEquipSlot());
        }
        this.sendModifyItem(item);
    }

    @Override
    protected void onTemporalItemTimeEnd(ItemInstance item) {
        this.getActor().sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HAS_EXPIRED).addItemName(item.getItemId()));
    }

    public void startTimers() {
    }

    public void stopTimers() {
        for (ItemInstance item : this.getItems()) {
            item.stopManaConsumeTask();
        }
    }

    @Override
    public int getSize() {
        return super.getSize() - this.getQuestSize();
    }

    private void refreshItemsSize() {
        int size = 0;
        for (ItemInstance item : this.getItems()) {
            if (!item.getTemplate().isQuest()) continue;
            ++size;
        }
        this.questItemsSize = size;
    }

    public int getAllSize() {
        return super.getSize();
    }

    public int getQuestSize() {
        return this.questItemsSize;
    }

    protected class ManaConsumeTask
    implements Runnable {
        private ItemInstance item;

        ManaConsumeTask(ItemInstance item) {
            this.item = item;
        }

        @Override
        public void run() {
            Player player = PcInventory.this.getActor();
            if (!this.item.isEquipped()) {
                return;
            }
            int mana = this.item.getShadowLifeTime();
            if (mana > 0) {
                this.item.setLifeTime(this.item.getLifeTime() - 1);
                mana = this.item.getShadowLifeTime();
            }
            if (mana <= 0) {
                PcInventory.this.destroyItem(this.item);
            }
            SystemMessage sm = null;
            if (mana == 10) {
                sm = new SystemMessage(1979);
            } else if (mana == 5) {
                sm = new SystemMessage(1980);
            } else if (mana == 1) {
                sm = new SystemMessage(1981);
            } else if (mana <= 0) {
                sm = new SystemMessage(1982);
            }
            if (sm != null) {
                sm.addItemName(this.item.getItemId());
                player.sendPacket((IBroadcastPacket)sm);
            }
        }
    }
}

