/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPledgeBonusUpdate
extends L2GameServerPacket {
    private final BonusType _type;
    private final int _value;

    public ExPledgeBonusUpdate(BonusType type, int value) {
        this._type = type;
        this._value = value;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type.ordinal());
        this.writeD(this._value);
    }

    public static enum BonusType {
        ATTENDANCE,
        HUNTING;

    }
}

