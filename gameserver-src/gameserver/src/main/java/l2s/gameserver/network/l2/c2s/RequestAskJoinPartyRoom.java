/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.World;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExAskJoinPartyRoom;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestAskJoinPartyRoom
extends L2GameClientPacket {
    private String _name;

    @Override
    protected boolean readImpl() {
        this._name = this.readS(16);
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Player targetPlayer = World.getPlayer(this._name);
        if (targetPlayer == null || targetPlayer == player) {
            player.sendActionFailed();
            return;
        }
        if (player.isProcessingRequest()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.WAITING_FOR_ANOTHER_REPLY);
            return;
        }
        if (targetPlayer.isProcessingRequest()) {
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_ON_ANOTHER_TASK).addName(targetPlayer));
            return;
        }
        if (targetPlayer.isInTrainingCamp()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REQUEST_TO_A_CHARACTER_WHO_IS_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        if (targetPlayer.getMatchingRoom() != null) {
            return;
        }
        MatchingRoom room = player.getMatchingRoom();
        if (room == null || room.getType() != MatchingRoom.PARTY_MATCHING) {
            return;
        }
        if (room.getPlayers().size() >= room.getMaxMembersSize()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THE_PARTY_ROOM_IS_FULL);
            return;
        }
        new Request(Request.L2RequestType.PARTY_ROOM, player, targetPlayer).setTimeout(10000L);
        targetPlayer.sendPacket((IBroadcastPacket)new ExAskJoinPartyRoom(player.getName(), room.getTopic()));
        player.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S1_HAS_SENT_AN_INVITATION_TO_ROOM_S2).addName(player)).addString(room.getTopic()));
        targetPlayer.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S1_HAS_SENT_AN_INVITATION_TO_ROOM_S2).addName(player)).addString(room.getTopic()));
    }
}

