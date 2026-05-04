package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExListMpccWaiting
extends L2GameServerPacket {
    private static final int ITEMS_PER_PAGE = 10;
    private int _page;
    private List<MatchingRoom> _list;

    public ExListMpccWaiting(Player player, int page, int location, boolean allLevels) {
        int first = (page - 1) * 10;
        int firstNot = page * 10;
        List<MatchingRoom> temp = MatchingRoomManager.getInstance().getMatchingRooms(MatchingRoom.CC_MATCHING, location, allLevels, player);
        this._page = page;
        this._list = new ArrayList<MatchingRoom>(10);
        for (int i = 0; i < temp.size(); ++i) {
            if (i < first || i >= firstNot) continue;
            this._list.add(temp.get(i));
        }
    }

    @Override
    public void writeImpl() {
        this.writeD(this._page);
        this.writeD(this._list.size());
        for (MatchingRoom room : this._list) {
            this.writeD(room.getId());
            Player leader = room.getLeader();
            this.writeS(leader == null ? "" : leader.getName());
            this.writeD(room.getPlayers().size());
            this.writeD(room.getMinLevel());
            this.writeD(room.getMaxLevel());
            this.writeD(1);
            this.writeD(room.getMaxMembersSize());
            this.writeS(room.getTopic());
        }
        this.writeD(0);
        this.writeD(0);
    }
}

