/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class CharacterCreateFailPacket
extends L2GameServerPacket {
    public static final L2GameServerPacket REASON_CREATION_FAILED = new CharacterCreateFailPacket(0);
    public static final L2GameServerPacket REASON_TOO_MANY_CHARACTERS = new CharacterCreateFailPacket(1);
    public static final L2GameServerPacket REASON_NAME_ALREADY_EXISTS = new CharacterCreateFailPacket(2);
    public static final L2GameServerPacket REASON_16_ENG_CHARS = new CharacterCreateFailPacket(3);
    public static final L2GameServerPacket REASON_INCORRECT_NAME = new CharacterCreateFailPacket(4);
    public static final L2GameServerPacket REASON_CREATE_NOT_ALLOWED = new CharacterCreateFailPacket(5);
    public static final L2GameServerPacket REASON_CHOOSE_ANOTHER_SVR = new CharacterCreateFailPacket(6);
    private int _error;

    private CharacterCreateFailPacket(int errorCode) {
        this._error = errorCode;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._error);
    }
}

