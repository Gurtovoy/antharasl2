package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.CommandChannel;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestExMPCCAcceptJoin
extends L2GameClientPacket {
    private int _response;
    private int _unk;

    @Override
    protected boolean readImpl() {
        this._response = this._buf.hasRemaining() ? this.readD() : 0;
        this._unk = this._buf.hasRemaining() ? this.readD() : 0;
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Request request = activeChar.getRequest();
        if (request == null || !request.isTypeOf(Request.L2RequestType.CHANNEL)) {
            return;
        }
        if (!request.isInProgress()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isOutOfControl()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        Player requestor = request.getRequestor();
        if (requestor == null) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_ONLINE);
            activeChar.sendActionFailed();
            return;
        }
        if (requestor.getRequest() != request) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        if (this._response == 0) {
            request.cancel(new IBroadcastPacket[0]);
            requestor.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_HAS_DECLINED_THE_CHANNEL_INVITATION).addName(activeChar));
            return;
        }
        if (!requestor.isInParty() || !activeChar.isInParty() || activeChar.getParty().isInCommandChannel()) {
            request.cancel(new IBroadcastPacket[0]);
            requestor.sendPacket((IBroadcastPacket)SystemMsg.NO_USER_HAS_BEEN_INVITED_TO_THE_COMMAND_CHANNEL);
            return;
        }
        if (activeChar.isTeleporting()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_JOIN_A_COMMAND_CHANNEL_WHILE_TELEPORTING);
            requestor.sendPacket((IBroadcastPacket)SystemMsg.NO_USER_HAS_BEEN_INVITED_TO_THE_COMMAND_CHANNEL);
            return;
        }
        try {
            if (requestor.getParty().isInCommandChannel()) {
                requestor.getParty().getCommandChannel().addParty(activeChar.getParty());
            } else if (CommandChannel.checkAuthority(requestor)) {
                boolean haveSkill = requestor.getSkillLevel(391) > 0;
                boolean haveItem = false;
                if (!haveSkill && (haveItem = requestor.getInventory().destroyItemByItemId(8871, 1L))) {
                    requestor.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(8871, 1L));
                }
                if (!haveSkill && !haveItem) {
                    return;
                }
                CommandChannel channel = new CommandChannel(requestor);
                requestor.sendPacket((IBroadcastPacket)SystemMsg.THE_COMMAND_CHANNEL_HAS_BEEN_FORMED);
                channel.addParty(activeChar.getParty());
            }
        }
        finally {
            request.done(new IBroadcastPacket[0]);
        }
    }
}

