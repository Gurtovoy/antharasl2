package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class CharacterDeleteFailPacket
extends L2GameServerPacket {
    public static int REASON_DELETION_FAILED = 1;
    public static int REASON_YOU_MAY_NOT_DELETE_CLAN_MEMBER = 2;
    public static int REASON_CLAN_LEADERS_MAY_NOT_BE_DELETED = 3;
    int _error;

    public CharacterDeleteFailPacket(int error) {
        this._error = error;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._error);
    }
}

