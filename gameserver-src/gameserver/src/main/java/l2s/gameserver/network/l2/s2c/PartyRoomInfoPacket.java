package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PartyRoomInfoPacket
extends L2GameServerPacket {
    private int _id;
    private int _minLevel;
    private int _maxLevel;
    private int _lootDist;
    private int _maxMembers;
    private int _location;
    private String _title;

    public PartyRoomInfoPacket(MatchingRoom room) {
        this._id = room.getId();
        this._minLevel = room.getMinLevel();
        this._maxLevel = room.getMaxLevel();
        this._lootDist = room.getLootType();
        this._maxMembers = room.getMaxMembersSize();
        this._location = room.getLocationId();
        this._title = room.getTopic();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._id);
        this.writeD(this._maxMembers);
        this.writeD(this._minLevel);
        this.writeD(this._maxLevel);
        this.writeD(this._lootDist);
        this.writeD(this._location);
        this.writeS(this._title);
    }
}

