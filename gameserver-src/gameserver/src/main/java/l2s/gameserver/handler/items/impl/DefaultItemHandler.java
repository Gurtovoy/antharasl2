/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.items.impl;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.utils.Log;

public class DefaultItemHandler
implements IItemHandler {
    @Override
    public void attachSkill(ItemTemplate itemTemplate, Skill skill) {
        itemTemplate.addAttachedSkill(SkillEntry.makeSkillEntry(SkillEntryType.ITEM, skill));
    }

    @Override
    public SystemMsg checkCondition(Playable playable, ItemInstance item) {
        return null;
    }

    @Override
    public boolean forceUseItem(Playable playable, ItemInstance item, boolean ctrl) {
        return false;
    }

    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        return false;
    }

    @Override
    public void dropItem(Player player, ItemInstance item, long count, Location loc) {
        if (item.isEquipped()) {
            player.getInventory().unEquipItem(item);
            player.sendUserInfo(true);
        }
        if ((item = player.getInventory().removeItemByObjectId(item.getObjectId(), count)) == null) {
            player.sendActionFailed();
            return;
        }
        Log.LogItem(player, "Drop", item);
        item.dropToTheGround((Playable)player, loc);
        player.disableDrop(1000);
        player.sendChanges();
    }

    @Override
    public boolean pickupItem(Playable playable, ItemInstance item) {
        return true;
    }

    @Override
    public void onRestoreItem(Playable playable, ItemInstance item) {
    }

    @Override
    public void onAddItem(Playable playable, ItemInstance item) {
    }

    @Override
    public void onRemoveItem(Playable playable, ItemInstance item) {
    }

    @Override
    public boolean isAutoUse() {
        return false;
    }

    public static void sendUseMessage(Playable playable, int itemId) {
        if (!playable.isPlayer()) {
            return;
        }
        playable.getPlayer().sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_USE_S1).addItemName(itemId));
    }

    public static void sendUseMessage(Playable playable, ItemInstance item) {
        DefaultItemHandler.sendUseMessage(playable, item.getItemId());
    }

    public static boolean reduceItem(Playable playable, ItemInstance item) {
        return playable.getInventory().destroyItem(item, 1L);
    }

    public static boolean canBeExtracted(Player player, ItemInstance item) {
        if (player.getWeightPenalty() >= 3 || player.getInventory().getSize() > player.getInventoryLimit() - 10) {
            player.sendPacket(new IBroadcastPacket[]{SystemMsg.YOUR_INVENTORY_IS_FULL, new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addItemName(item.getItemId())});
            return false;
        }
        return true;
    }
}

