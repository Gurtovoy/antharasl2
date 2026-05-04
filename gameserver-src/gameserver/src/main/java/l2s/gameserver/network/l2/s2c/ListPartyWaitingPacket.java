package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ListPartyWaitingPacket
extends L2GameServerPacket {
    private static final int ITEMS_PER_PAGE = 16;
    private final Collection<MatchingRoom> _rooms = new ArrayList<MatchingRoom>(16);
    private final int _page;

    public ListPartyWaitingPacket(int region, boolean allLevels, int page, Player activeChar) {
        this._page = page;
        List<MatchingRoom> temp = MatchingRoomManager.getInstance().getMatchingRooms(MatchingRoom.PARTY_MATCHING, region, allLevels, activeChar);
        int first = Math.max((page - 1) * 16, 0);
        int firstNot = Math.min(page * 16, temp.size());
        for (int i = first; i < firstNot; ++i) {
            this._rooms.add(temp.get(i));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._page);
        this.writeD(this._rooms.size());
        for (MatchingRoom room : this._rooms) {
            this.writeD(room.getId());
            this.writeS(room.getTopic());
            this.writeD(room.getLocationId());
            this.writeD(room.getMinLevel());
            this.writeD(room.getMaxLevel());
            this.writeD(room.getMaxMembersSize());
            this.writeS(room.getLeader() == null ? "None" : room.getLeader().getName());
            Collection<Player> players = room.getPlayers();
            this.writeD(players.size());
            for (Player player : players) {
                this.writeD(player.getClassId().getId());
                this.writeS(player.getName());
            }
        }
        this.writeD(0);
        this.writeD(0);
    }
}

