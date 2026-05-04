package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ChangeMoveTypePacket
extends L2GameServerPacket {
    public static int WALK = 0;
    public static int RUN = 1;
    private int _chaId;
    private boolean _running;

    public ChangeMoveTypePacket(Creature cha) {
        this._chaId = cha.getObjectId();
        this._running = cha.isRunning();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._chaId);
        this.writeD(this._running ? 1 : 0);
        this.writeD(0);
    }
}

