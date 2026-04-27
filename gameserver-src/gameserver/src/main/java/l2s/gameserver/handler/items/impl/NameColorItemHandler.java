/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.items.impl;

import l2s.gameserver.handler.items.impl.DefaultItemHandler;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExChangeNicknameNColor;

public class NameColorItemHandler
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
        player.sendPacket((IBroadcastPacket)new ExChangeNicknameNColor(item.getObjectId()));
        return true;
    }
}

