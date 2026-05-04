package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.data.xml.holder.InstantZoneHolder;
import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPartyRoomMemberPacket
extends L2GameServerPacket {
    private int _type;
    private List<PartyRoomMemberInfo> _members = Collections.emptyList();

    public ExPartyRoomMemberPacket(MatchingRoom room, Player activeChar) {
        this._type = room.getMemberType(activeChar);
        this._members = new ArrayList<PartyRoomMemberInfo>(room.getPlayers().size());
        for (Player $member : room.getPlayers()) {
            this._members.add(new PartyRoomMemberInfo($member, room.getMemberType($member)));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._type);
        this.writeD(this._members.size());
        for (PartyRoomMemberInfo member_info : this._members) {
            this.writeD(member_info.objectId);
            this.writeS(member_info.name);
            this.writeD(member_info.classId);
            this.writeD(member_info.level);
            this.writeD(member_info.location);
            this.writeD(member_info.memberType);
            this.writeD(member_info.instanceReuses.size());
            for (int i : member_info.instanceReuses) {
                this.writeD(i);
            }
        }
    }

    static class PartyRoomMemberInfo {
        public final int objectId;
        public final int classId;
        public final int level;
        public final int location;
        public final int memberType;
        public final String name;
        public final List<Integer> instanceReuses;

        public PartyRoomMemberInfo(Player member, int type) {
            this.objectId = member.getObjectId();
            this.name = member.getName();
            this.classId = member.getClassId().ordinal();
            this.level = member.getLevel();
            this.location = MatchingRoomManager.getInstance().getLocation(member);
            this.memberType = type;
            this.instanceReuses = InstantZoneHolder.getInstance().getLockedInstancesList(member);
        }
    }
}

