/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExChangeMPCost
extends L2GameServerPacket {
    private final int _type;
    private final double _value;

    public ExChangeMPCost(Skill.SkillMagicType type, double value) {
        this._type = type.ordinal();
        this._value = value;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._type);
        this.writeF(this._value);
    }
}

