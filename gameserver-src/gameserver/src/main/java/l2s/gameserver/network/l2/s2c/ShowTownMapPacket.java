package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ShowTownMapPacket
extends L2GameServerPacket {
    String _texture;
    int _x;
    int _y;

    public ShowTownMapPacket(String texture, int x, int y) {
        this._texture = texture;
        this._x = x;
        this._y = y;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._texture);
        this.writeD(this._x);
        this.writeD(this._y);
    }
}

