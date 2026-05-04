package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExMpccRoomInfo
extends L2GameServerPacket {
    private int _index;
    private int _memberSize;
    private int _minLevel;
    private int _maxLevel;
    private int _lootType;
    private int _locationId;
    private String _topic;

    public ExMpccRoomInfo(MatchingRoom matching) {
        this._index = matching.getId();
        this._locationId = matching.getLocationId();
        this._topic = matching.getTopic();
        this._minLevel = matching.getMinLevel();
        this._maxLevel = matching.getMaxLevel();
        this._memberSize = matching.getMaxMembersSize();
        this._lootType = matching.getLootType();
    }

    @Override
    public void writeImpl() {
        this.writeD(this._index);
        this.writeD(this._memberSize);
        this.writeD(this._minLevel);
        this.writeD(this._maxLevel);
        this.writeD(this._lootType);
        this.writeD(this._locationId);
        this.writeS(this._topic);
    }
}

