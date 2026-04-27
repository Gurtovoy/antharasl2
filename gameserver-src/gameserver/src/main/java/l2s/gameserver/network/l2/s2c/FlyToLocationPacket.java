/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class FlyToLocationPacket
extends L2GameServerPacket {
    private final int _chaObjId;
    private final FlyType _type;
    private final ILocation _loc;
    private final ILocation _destLoc;
    private final int _flySpeed;
    private final int _flyDelay;
    private final int _animationSpeed;

    public FlyToLocationPacket(Creature cha, ILocation destLoc, FlyType type, int flySpeed, int flyDelay, int animationSpeed) {
        this._destLoc = destLoc;
        this._type = type;
        this._chaObjId = cha.getObjectId();
        this._loc = cha;
        this._flySpeed = flySpeed;
        this._flyDelay = flyDelay;
        this._animationSpeed = animationSpeed;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._chaObjId);
        this.writeD(this._destLoc.getX());
        this.writeD(this._destLoc.getY());
        this.writeD(this._destLoc.getZ());
        this.writeD(this._loc.getX());
        this.writeD(this._loc.getY());
        this.writeD(this._loc.getZ());
        this.writeD(this._type.ordinal());
        this.writeD(this._flySpeed);
        this.writeD(this._flyDelay);
        this.writeD(this._animationSpeed);
    }

    public static enum FlyType {
        THROW_UP,
        THROW_HORIZONTAL,
        DUMMY,
        CHARGE,
        PUSH_HORIZONTAL,
        JUMP_EFFECTED,
        NONE,
        PUSH_DOWN_HORIZONTAL,
        WARP_BACK,
        WARP_FORWARD;

    }
}

