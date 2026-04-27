/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.items.impl;

import l2s.gameserver.data.xml.holder.AppearanceStoneHolder;
import l2s.gameserver.handler.items.impl.DefaultItemHandler;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExChoose_Shape_Shifting_Item;
import l2s.gameserver.templates.item.support.AppearanceStone;

public class AppearanceStoneHandler
extends DefaultItemHandler {
    @Override
    public boolean useItem(Playable playable, ItemInstance item, boolean ctrl) {
        if (playable == null || !playable.isPlayer()) {
            return false;
        }
        Player player = (Player)playable;
        if (player.getEnchantScroll() != null) {
            return false;
        }
        if (player.getAppearanceStone() != null) {
            player.sendPacket((IBroadcastPacket)SystemMsg.WEAPON_APPEARANCE_MODIFICATION_OR_RESTORATION_IS_IN_PROGRESS_PLEASE_TRY_AGAIN_AFTER_COMPLETING_THIS_TASK);
            return false;
        }
        AppearanceStone stone = AppearanceStoneHolder.getInstance().getAppearanceStone(item.getItemId());
        if (stone == null) {
            return false;
        }
        player.setAppearanceStone(item);
        player.sendPacket((IBroadcastPacket)SystemMsg.PLEASE_SELECT_AN_ITEM_TO_CHANGE);
        player.sendPacket((IBroadcastPacket)new ExChoose_Shape_Shifting_Item(stone));
        return true;
    }
}

