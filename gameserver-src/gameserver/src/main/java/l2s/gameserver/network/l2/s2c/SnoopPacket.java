/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class SnoopPacket
extends L2GameServerPacket {
    private int _convoID;
    private String _name;
    private int _type;
    private int _fStringId;
    private String _speaker;
    private String _msg;
    private String[] _params;

    public SnoopPacket(int id, String name, int type, String speaker, String msg, int fStringId, String ... params) {
        this._convoID = id;
        this._name = name;
        this._type = type;
        this._speaker = speaker;
        this._fStringId = fStringId;
        this._params = params;
    }

    public SnoopPacket(int id, String name, int type, String speaker, String msg) {
        this._convoID = id;
        this._name = name;
        this._type = type;
        this._speaker = speaker;
        this._msg = msg;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._convoID);
        this.writeS(this._name);
        this.writeD(0);
        this.writeD(this._type);
        this.writeS(this._speaker);
        this.writeS(this._msg);
    }
}

