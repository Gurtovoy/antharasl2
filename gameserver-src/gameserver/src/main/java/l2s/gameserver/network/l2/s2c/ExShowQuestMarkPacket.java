package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowQuestMarkPacket
extends L2GameServerPacket {
    private final int _questId;
    private final int _cond;

    public ExShowQuestMarkPacket(int questId, int cond) {
        this._questId = questId;
        this._cond = cond;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._questId);
        this.writeD(this._cond);
    }
}

