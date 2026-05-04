/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.instancemanager;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;
import l2s.gameserver.instancemanager.MapRegionManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.templates.mapregion.RestartArea;
import l2s.gameserver.templates.mapregion.RestartPoint;
import org.apache.commons.lang3.ArrayUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CTreeIntObjectMap;

public class MatchingRoomManager {
    private static final MatchingRoomManager _instance = new MatchingRoomManager();
    private RoomsHolder[] _holder = new RoomsHolder[2];
    private Set<Player> _players = new CopyOnWriteArraySet<Player>();

    public static MatchingRoomManager getInstance() {
        return _instance;
    }

    public MatchingRoomManager() {
        this._holder[MatchingRoom.PARTY_MATCHING] = new RoomsHolder();
        this._holder[MatchingRoom.CC_MATCHING] = new RoomsHolder();
    }

    public void addToWaitingList(Player player) {
        this._players.add(player);
    }

    public void removeFromWaitingList(Player player) {
        this._players.remove(player);
    }

    public List<Player> getWaitingList(int minLevel, int maxLevel, int[] classes) {
        ArrayList<Player> res = new ArrayList<Player>();
        for (Player $member : this._players) {
            if ($member.getLevel() < minLevel || $member.getLevel() > maxLevel || classes.length != 0 && !ArrayUtils.contains((int[])classes, (int)$member.getClassId().getId())) continue;
            res.add($member);
        }
        return res;
    }

    public List<MatchingRoom> getMatchingRooms(int type, int region, boolean allLevels, Player activeChar) {
        ArrayList<MatchingRoom> res = new ArrayList<MatchingRoom>();
        for (MatchingRoom room : this._holder[type]._rooms.valueCollection()) {
            if (region > 0 && room.getLocationId() != region || region == -2 && room.getLocationId() != MatchingRoomManager.getInstance().getLocation(activeChar) || !allLevels && (room.getMinLevel() > activeChar.getLevel() || room.getMaxLevel() < activeChar.getLevel())) continue;
            res.add(room);
        }
        return res;
    }

    public int addMatchingRoom(MatchingRoom r) {
        return this._holder[r.getType()].addRoom(r);
    }

    public void removeMatchingRoom(MatchingRoom r) {
        this._holder[r.getType()]._rooms.remove(r.getId());
    }

    public MatchingRoom getMatchingRoom(int type, int id) {
        return (MatchingRoom)this._holder[type]._rooms.get(id);
    }

    public int getLocation(Player player) {
        if (player == null) {
            return 0;
        }
        RestartArea ra = MapRegionManager.getInstance().getRegionData(RestartArea.class, player);
        if (ra != null) {
            RestartPoint rp = ra.getRestartPoint().get(player.getRace());
            return rp.getBbs();
        }
        return 0;
    }

    private class RoomsHolder {
        private int _id = 1;
        private IntObjectMap<MatchingRoom> _rooms = new CTreeIntObjectMap();

        private RoomsHolder() {
        }

        public int addRoom(MatchingRoom r) {
            int val = this._id++;
            this._rooms.put(val, r);
            return val;
        }
    }
}

