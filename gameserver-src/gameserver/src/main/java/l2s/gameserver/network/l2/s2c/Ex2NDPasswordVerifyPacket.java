/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class Ex2NDPasswordVerifyPacket
extends L2GameServerPacket {
    public static final int PASSWORD_OK = 0;
    public static final int PASSWORD_WRONG = 1;
    public static final int PASSWORD_BAN = 2;
    private int _wrongTentatives;
    private int _mode;

    public Ex2NDPasswordVerifyPacket(int mode, int wrongTentatives) {
        this._mode = mode;
        this._wrongTentatives = wrongTentatives;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._mode);
        this.writeD(this._wrongTentatives);
    }
}

