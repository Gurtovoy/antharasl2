package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.EnchantItemHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPutEnchantScrollItemResult;
import l2s.gameserver.templates.item.support.EnchantScroll;
import l2s.gameserver.utils.Log;

public class RequestExAddEnchantScrollItem
extends L2GameClientPacket {
    private int _scrollObjectId;
    private int _itemObjectId;

    @Override
    protected boolean readImpl() {
        this._scrollObjectId = this.readD();
        this._itemObjectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (player.isActionsDisabled() || player.isInStoreMode() || player.isInTrade()) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            return;
        }
        PcInventory inventory = player.getInventory();
        ItemInstance itemToEnchant = inventory.getItemByObjectId(this._itemObjectId);
        ItemInstance scroll = inventory.getItemByObjectId(this._scrollObjectId);
        if (itemToEnchant == null || scroll == null) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            return;
        }
        Log.add(player.getName() + "|Trying to put enchant|" + itemToEnchant.getItemId() + "|+" + itemToEnchant.getEnchantLevel() + "|" + itemToEnchant.getObjectId(), "enchants");
        int scrollId = scroll.getItemId();
        int itemId = itemToEnchant.getItemId();
        EnchantScroll enchantScroll = EnchantItemHolder.getInstance().getEnchantScroll(scrollId);
        if (enchantScroll == null || !enchantScroll.getItems().contains(itemId) && !itemToEnchant.canBeEnchanted() || itemToEnchant.isStackable()) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
            return;
        }
        if (itemToEnchant.getLocation() != ItemInstance.ItemLocation.INVENTORY && itemToEnchant.getLocation() != ItemInstance.ItemLocation.PAPERDOLL) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            player.sendPacket((IBroadcastPacket)SystemMsg.INAPPROPRIATE_ENCHANT_CONDITIONS);
            return;
        }
        if (player.isInStoreMode()) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_ENCHANT_WHILE_OPERATING_A_PRIVATE_STORE_OR_PRIVATE_WORKSHOP);
            return;
        }
        if ((scroll = inventory.getItemByObjectId(scroll.getObjectId())) == null) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            return;
        }
        if (enchantScroll == null) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            return;
        }
        if (enchantScroll.getItems().size() > 0) {
            if (!enchantScroll.getItems().contains(itemId)) {
                player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
                player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                return;
            }
        } else {
            if (!enchantScroll.containsGrade(itemToEnchant.getGrade())) {
                player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
                player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                return;
            }
            int itemType = itemToEnchant.getTemplate().getType2();
            switch (enchantScroll.getType()) {
                case ARMOR: {
                    if (itemType != 0) break;
                    player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
                    player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                    return;
                }
                case WEAPON: {
                    if (itemType != 1 && itemType != 2) break;
                    player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
                    player.sendPacket((IBroadcastPacket)SystemMsg.DOES_NOT_FIT_STRENGTHENING_CONDITIONS_OF_THE_SCROLL);
                    return;
                }
            }
        }
        if (itemToEnchant.getEnchantLevel() < enchantScroll.getMinEnchant() || enchantScroll.getMaxEnchant() != -1 && itemToEnchant.getEnchantLevel() >= enchantScroll.getMaxEnchant()) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            player.sendPacket((IBroadcastPacket)SystemMsg.INAPPROPRIATE_ENCHANT_CONDITIONS);
            return;
        }
        if (itemToEnchant.getOwnerId() != player.getObjectId()) {
            player.sendPacket((IBroadcastPacket)ExPutEnchantScrollItemResult.FAIL);
            return;
        }
        player.sendPacket((IBroadcastPacket)new ExPutEnchantScrollItemResult(scroll.getObjectId()));
        player.setEnchantScroll(scroll);
    }
}

