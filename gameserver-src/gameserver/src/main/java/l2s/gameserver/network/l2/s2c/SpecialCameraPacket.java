/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class SpecialCameraPacket
extends L2GameServerPacket {
    private int _id;
    private int _dist;
    private int _yaw;
    private int _pitch;
    private int _time;
    private int _duration;
    private final int _turn;
    private final int _rise;
    private final int _widescreen;
    private final int _unknown;

    public SpecialCameraPacket(int id, int dist, int yaw, int pitch, int time, int duration) {
        this._id = id;
        this._dist = dist;
        this._yaw = yaw;
        this._pitch = pitch;
        this._time = time;
        this._duration = duration;
        this._turn = 0;
        this._rise = 0;
        this._widescreen = 0;
        this._unknown = 0;
    }

    public SpecialCameraPacket(int id, int dist, int yaw, int pitch, int time, int duration, int turn, int rise, int widescreen, int unk) {
        this._id = id;
        this._dist = dist;
        this._yaw = yaw;
        this._pitch = pitch;
        this._time = time;
        this._duration = duration;
        this._turn = turn;
        this._rise = rise;
        this._widescreen = widescreen;
        this._unknown = unk;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._id);
        this.writeD(this._dist);
        this.writeD(this._yaw);
        this.writeD(this._pitch);
        this.writeD(this._time);
        this.writeD(this._duration);
        this.writeD(this._turn);
        this.writeD(this._rise);
        this.writeD(this._widescreen);
        this.writeD(this._unknown);
    }
}

