/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.handler.items.impl;

import java.util.List;
import l2s.commons.util.Rnd;
import l2s.gameserver.handler.items.impl.DefaultItemHandler;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.data.CapsuledItemData;
import l2s.gameserver.utils.ItemFunctions;

public class CapsuledItemHandler
extends DefaultItemHandler {
    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        Player player;
        if (playable.isPlayer()) {
            player = (Player)playable;
        } else if (playable.isPet()) {
            player = playable.getPlayer();
        } else {
            return false;
        }
        int itemId = item.getItemId();
        if (!CapsuledItemHandler.canBeExtracted(player, item)) {
            return false;
        }
        if (!CapsuledItemHandler.reduceItem(player, item)) {
            return false;
        }
        List<CapsuledItemData> capsuled_items = item.getTemplate().getCapsuledItems();
        for (CapsuledItemData ci : capsuled_items) {
            long maxCount;
            if (!Rnd.chance((double)ci.getChance())) continue;
            long minCount = ci.getMinCount();
            long count = minCount == (maxCount = ci.getMaxCount()) ? minCount : Rnd.get((long)minCount, (long)maxCount);
            ItemFunctions.addItem(player, ci.getId(), count, ci.getEnchantLevel(), true);
        }
        player.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(itemId, 1L));
        return true;
    }
}

