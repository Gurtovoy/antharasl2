/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class Ex2NDPasswordCheckPacket
extends L2GameServerPacket {
    public static final int PASSWORD_NEW = 0;
    public static final int PASSWORD_PROMPT = 1;
    public static final int PASSWORD_OK = 2;
    private int _windowType;

    public Ex2NDPasswordCheckPacket(int windowType) {
        this._windowType = windowType;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._windowType);
        this.writeD(0);
    }
}

