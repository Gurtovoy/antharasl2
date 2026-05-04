package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExNeedToChangeName
extends L2GameServerPacket {
    public static final int TYPE_PLAYER = 0;
    public static final int TYPE_PLEDGE = 1;
    public static final int NONE_REASON = 0;
    public static final int NAME_ALREADY_IN_USE_OR_INCORRECT_REASON = 1;
    private int _type;
    private int _reason;
    private String _origName;

    public ExNeedToChangeName(int type, int reason, String origName) {
        this._type = type;
        this._reason = reason;
        this._origName = origName;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._type);
        this.writeD(this._reason);
        this.writeS(this._origName);
    }
}

