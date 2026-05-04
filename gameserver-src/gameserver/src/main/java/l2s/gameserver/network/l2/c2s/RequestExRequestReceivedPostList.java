/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExShowReceivedPostList;

public class RequestExRequestReceivedPostList
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player cha = ((GameClient)this.getClient()).getActiveChar();
        if (cha != null) {
            cha.sendPacket((IBroadcastPacket)new ExShowReceivedPostList(cha));
        }
    }
}

