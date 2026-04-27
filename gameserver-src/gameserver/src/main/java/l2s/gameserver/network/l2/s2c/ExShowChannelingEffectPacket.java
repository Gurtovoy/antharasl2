/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowChannelingEffectPacket
extends L2GameServerPacket {
    private final int _casterObjectId;
    private final int _targetObjectId;
    private final int _state;

    public ExShowChannelingEffectPacket(Creature caster, Creature target, int state) {
        this._casterObjectId = caster.getObjectId();
        this._targetObjectId = target.getObjectId();
        this._state = state;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._casterObjectId);
        this.writeD(this._targetObjectId);
        this.writeD(this._state);
    }
}

