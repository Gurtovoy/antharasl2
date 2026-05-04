package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAskJoinPartyRoom
extends L2GameServerPacket {
    private String _charName;
    private String _roomName;

    public ExAskJoinPartyRoom(String charName, String roomName) {
        this._charName = charName;
        this._roomName = roomName;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._charName);
        this.writeS(this._roomName);
    }
}

