/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.instances.FenceInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExColosseumFenceInfoPacket
extends L2GameServerPacket {
    private final int _objId;
    private final int _x;
    private final int _y;
    private final int _z;
    private final int _width;
    private final int _length;
    private final int _state;

    public ExColosseumFenceInfoPacket(int objId, int x, int y, int z, int width, int length, int state) {
        this._objId = objId;
        this._x = x;
        this._y = y;
        this._z = z;
        this._width = width;
        this._length = length;
        this._state = state;
    }

    public ExColosseumFenceInfoPacket(FenceInstance fence) {
        this(fence.getObjectId(), fence.getX(), fence.getY(), fence.getZ(), fence.getWidth(), fence.getLength(), fence.getState().getClientId());
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objId);
        this.writeD(this._state);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
        this.writeD(this._width);
        this.writeD(this._length);
    }
}

