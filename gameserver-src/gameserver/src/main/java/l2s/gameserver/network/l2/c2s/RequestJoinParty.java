/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.World;
import l2s.gameserver.model.entity.events.impl.PvPEvent;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.AskJoinPartyPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestJoinParty
extends L2GameClientPacket {
    private String _name;
    private int _itemDistribution;

    @Override
    protected boolean readImpl() {
        this._name = this.readS(Config.CNAME_MAXLEN);
        this._itemDistribution = this.readD();
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
        if (activeChar.isPartyBlocked()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_BEEN_REPORTED_AS_AN_ILLEGAL_PROGRAM_USER_SO_PARTICIPATING_IN_A_PARTY_IS_NOT_ALLOWED);
            return;
        }
        Player target = World.getPlayer(this._name);
        if (target == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_ONLINE);
            return;
        }
        if (target == activeChar) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            activeChar.sendActionFailed();
            return;
        }
        for (PvPEvent event : activeChar.getEvents(PvPEvent.class)) {
            if (event.canJoinParty(activeChar, target)) continue;
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
            activeChar.sendActionFailed();
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
        IBroadcastPacket problem = target.canJoinParty(activeChar);
        if (problem != null) {
            activeChar.sendPacket(problem);
            return;
        }
        if (activeChar.isInParty()) {
            if (activeChar.getParty().getMemberCount() >= Party.MAX_SIZE) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_PARTY_IS_FULL);
                return;
            }
            if (Config.PARTY_LEADER_ONLY_CAN_INVITE && !activeChar.getParty().isLeader(activeChar)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.ONLY_THE_LEADER_CAN_GIVE_OUT_INVITATIONS);
                return;
            }
        }
        new Request(Request.L2RequestType.PARTY, activeChar, target).setTimeout(10000L).set("itemDistribution", this._itemDistribution);
        target.sendPacket((IBroadcastPacket)new AskJoinPartyPacket(activeChar.getName(), this._itemDistribution));
        activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_HAS_BEEN_INVITED_TO_THE_PARTY).addName(target));
    }
}

