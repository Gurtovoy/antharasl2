package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExStartScenePlayer
extends L2GameServerPacket {
    private final int _sceneId;

    public ExStartScenePlayer(int sceneId) {
        this._sceneId = sceneId;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._sceneId);
        this.writeD(-1);
    }
}

