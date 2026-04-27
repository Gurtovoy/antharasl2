/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExMagicAttackInfo
extends L2GameServerPacket {
    public static final int CRITICAL = 1;
    public static final int CRITICAL_HEAL = 2;
    public static final int OVERHIT = 3;
    public static final int EVADED = 4;
    public static final int BLOCKED = 5;
    public static final int RESISTED = 6;
    public static final int IMMUNE = 7;
    private final int _attackerId;
    private final int _targetId;
    private final int _info;

    public ExMagicAttackInfo(int attackerId, int targetId, int info) {
        this._attackerId = attackerId;
        this._targetId = targetId;
        this._info = info;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._attackerId);
        this.writeD(this._targetId);
        this.writeD(this._info);
    }
}

