/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExTacticalSign
extends L2GameServerPacket {
    public static final int STAR = 1;
    public static final int HEART = 2;
    public static final int MOON = 3;
    public static final int CROSS = 4;
    private int _targetId;
    private int _signId;

    public ExTacticalSign(int target, int sign) {
        this._targetId = target;
        this._signId = sign;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._targetId);
        this.writeD(this._signId);
    }
}

