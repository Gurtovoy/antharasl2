package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PartySmallWindowDeletePacket
extends L2GameServerPacket {
    private final int _objId;
    private final String _name;

    public PartySmallWindowDeletePacket(Player member) {
        this._objId = member.getObjectId();
        this._name = member.getName();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objId);
        this.writeS(this._name);
    }
}

