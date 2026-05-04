/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.CommandChannel;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.World;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExAskJoinMPCCPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestExMPCCAskJoin
extends L2GameClientPacket {
    private String _name;

    @Override
    protected boolean readImpl() {
        this._name = this.readS(16);
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isOutOfControl()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isProcessingRequest()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WAITING_FOR_ANOTHER_REPLY);
            return;
        }
        if (!activeChar.isInParty()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_AUTHORITY_TO_INVITE_SOMEONE_TO_THE_COMMAND_CHANNEL);
            return;
        }
        Player target = World.getPlayer(this._name);
        if (target == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_CURRENTLY_ONLINE);
            return;
        }
        if (activeChar == target || !target.isInParty() || activeChar.getParty() == target.getParty()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_INVITED_THE_WRONG_TARGET);
            return;
        }
        if (target.isInParty() && !target.getParty().isLeader(target)) {
            target = target.getParty().getPartyLeader();
        }
        if (target == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_CURRENTLY_ONLINE);
            return;
        }
        if (target.getParty().isInCommandChannel()) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1S_PARTY_IS_ALREADY_A_MEMBER_OF_THE_COMMAND_CHANNEL).addName(target));
            return;
        }
        if (target.isBusy()) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_ON_ANOTHER_TASK).addName(target));
            return;
        }
        if (target.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REQUEST_TO_A_CHARACTER_WHO_IS_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        Party activeParty = activeChar.getParty();
        if (activeParty.isInCommandChannel()) {
            if (activeParty.getCommandChannel().getChannelLeader() != activeChar) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_AUTHORITY_TO_INVITE_SOMEONE_TO_THE_COMMAND_CHANNEL);
                return;
            }
            this.sendInvite(activeChar, target);
        } else if (CommandChannel.checkAuthority(activeChar)) {
            this.sendInvite(activeChar, target);
        }
    }

    private void sendInvite(Player requestor, Player target) {
        new Request(Request.L2RequestType.CHANNEL, requestor, target).setTimeout(10000L);
        target.sendPacket((IBroadcastPacket)new ExAskJoinMPCCPacket(requestor.getName()));
        requestor.sendMessage("You invited " + target.getName() + " to your Command Channel.");
    }
}

