/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.data.xml.holder.InstantZoneHolder;
import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExListPartyMatchingWaitingRoom
extends L2GameServerPacket {
    private static final int ITEMS_PER_PAGE = 64;
    private final List<PartyMatchingWaitingInfo> _waitingList = new ArrayList<PartyMatchingWaitingInfo>(64);
    private final int _fullSize;

    public ExListPartyMatchingWaitingRoom(Player searcher, int minLevel, int maxLevel, int page, int[] classes) {
        List<Player> temp = MatchingRoomManager.getInstance().getWaitingList(minLevel, maxLevel, classes);
        this._fullSize = temp.size();
        int first = Math.max((page - 1) * 64, 0);
        int firstNot = Math.min(page * 64, this._fullSize);
        for (int i = first; i < firstNot; ++i) {
            this._waitingList.add(new PartyMatchingWaitingInfo(temp.get(i)));
        }
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._fullSize);
        this.writeD(this._waitingList.size());
        for (PartyMatchingWaitingInfo waitingInfo : this._waitingList) {
            this.writeS(waitingInfo.name);
            this.writeD(waitingInfo.classId);
            this.writeD(waitingInfo.level);
            this.writeD(waitingInfo.locationId);
            this.writeD(waitingInfo.instanceReuses.size());
            for (int i : waitingInfo.instanceReuses) {
                this.writeD(i);
            }
        }
    }

    static class PartyMatchingWaitingInfo {
        public final int classId;
        public final int level;
        public final int locationId;
        public final String name;
        public final List<Integer> instanceReuses;

        public PartyMatchingWaitingInfo(Player member) {
            this.name = member.getName();
            this.classId = member.getClassId().getId();
            this.level = member.getLevel();
            this.locationId = MatchingRoomManager.getInstance().getLocation(member);
            this.instanceReuses = InstantZoneHolder.getInstance().getLockedInstancesList(member);
        }
    }
}

