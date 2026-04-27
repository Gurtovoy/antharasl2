/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExIsCharNameCreatable
extends L2GameServerPacket {
    public static final L2GameServerPacket SUCCESS = new ExIsCharNameCreatable(-1);
    public static final L2GameServerPacket UNABLE_TO_CREATE_A_CHARACTER = new ExIsCharNameCreatable(0);
    public static final L2GameServerPacket TOO_MANY_CHARACTERS = new ExIsCharNameCreatable(1);
    public static final L2GameServerPacket NAME_ALREADY_EXISTS = new ExIsCharNameCreatable(2);
    public static final L2GameServerPacket ENTER_CHAR_NAME__MAX_16_CHARS = new ExIsCharNameCreatable(3);
    public static final L2GameServerPacket WRONG_NAME = new ExIsCharNameCreatable(4);
    public static final L2GameServerPacket WRONG_SERVER = new ExIsCharNameCreatable(5);
    public static final L2GameServerPacket DONT_CREATE_CHARS_ON_THIS_SERVER = new ExIsCharNameCreatable(6);
    public static final L2GameServerPacket DONT_USE_ENG_CHARS = new ExIsCharNameCreatable(7);
    public int _errorCode;

    public ExIsCharNameCreatable(int errorCode) {
        this._errorCode = errorCode;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._errorCode);
    }
}

