/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.model.matching.PartyMatchingRoom;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestPartyMatchList
extends L2GameClientPacket {
    private int _lootDist;
    private int _maxMembers;
    private int _minLevel;
    private int _maxLevel;
    private int _roomId;
    private String _roomTitle;

    @Override
    protected boolean readImpl() {
        this._roomId = this.readD();
        this._maxMembers = this.readD();
        this._minLevel = this.readD();
        this._maxLevel = this.readD();
        this._lootDist = this.readD();
        this._roomTitle = this.readS(64);
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Party party = player.getParty();
        if (party != null && party.getPartyLeader() != player) {
            return;
        }
        MatchingRoom room = player.getMatchingRoom();
        if (room == null) {
            room = new PartyMatchingRoom(player, this._minLevel, this._maxLevel, this._maxMembers, this._lootDist, this._roomTitle);
            if (party != null) {
                for (Player member : party.getPartyMembers()) {
                    if (member == null || member == player) continue;
                    room.addMemberForce(member);
                }
            }
        } else if (room.getId() == this._roomId && room.getType() == MatchingRoom.PARTY_MATCHING && room.getLeader() == player) {
            room.setMinLevel(this._minLevel);
            room.setMaxLevel(this._maxLevel);
            room.setMaxMemberSize(this._maxMembers);
            room.setTopic(this._roomTitle);
            room.setLootType(this._lootDist);
            room.broadCast(room.infoRoomPacket());
        }
    }
}

