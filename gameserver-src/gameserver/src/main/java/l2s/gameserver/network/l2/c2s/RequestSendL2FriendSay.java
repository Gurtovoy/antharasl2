/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.L2FriendSayPacket;
import l2s.gameserver.utils.Log;

public class RequestSendL2FriendSay
extends L2GameClientPacket {
    private String _message;
    private String _reciever;

    @Override
    protected boolean readImpl() {
        this._message = this.readS(2048);
        this._reciever = this.readS(16);
        return true;
    }

    @Override
    protected void runImpl() {
        Player targetPlayer;
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.getNoChannel() != 0L) {
            if (activeChar.getNoChannelRemained() > 0L || activeChar.getNoChannel() < 0L) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.CHATTING_IS_CURRENTLY_PROHIBITED_IF_YOU_TRY_TO_CHAT_BEFORE_THE_PROHIBITION_IS_REMOVED_THE_PROHIBITION_TIME_WILL_INCREASE_EVEN_FURTHER);
                return;
            }
            activeChar.updateNoChannel(0L);
        }
        if ((targetPlayer = World.getPlayer(this._reciever)) == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_ONLINE);
            return;
        }
        if (targetPlayer.isBlockAll()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PERSON_IS_IN_MESSAGE_REFUSAL_MODE);
            return;
        }
        if (!activeChar.getFriendList().contains(targetPlayer.getObjectId())) {
            return;
        }
        if (activeChar.canTalkWith(targetPlayer)) {
            targetPlayer.sendPacket((IBroadcastPacket)new L2FriendSayPacket(activeChar.getName(), this._reciever, this._message));
            Log.LogChat("FRIENDTELL", activeChar.getName(), this._reciever, this._message);
        }
    }
}

