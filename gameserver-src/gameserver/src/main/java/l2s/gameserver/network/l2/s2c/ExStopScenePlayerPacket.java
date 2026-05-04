package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExStopScenePlayerPacket
extends L2GameServerPacket {
    private final int _movieId;

    public ExStopScenePlayerPacket(int movieId) {
        this._movieId = movieId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._movieId);
    }
}

