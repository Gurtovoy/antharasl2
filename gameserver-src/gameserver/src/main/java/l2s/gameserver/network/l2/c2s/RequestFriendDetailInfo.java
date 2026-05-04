/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Friend;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExFriendDetailInfo;

public class RequestFriendDetailInfo
extends L2GameClientPacket {
    private String _name;

    @Override
    protected boolean readImpl() {
        this._name = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Friend friend = activeChar.getFriendList().get(this._name);
        if (friend == null) {
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExFriendDetailInfo(activeChar, friend));
    }
}

