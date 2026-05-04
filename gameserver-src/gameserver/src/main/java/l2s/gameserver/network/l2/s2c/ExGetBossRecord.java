package l2s.gameserver.network.l2.s2c;

import java.util.List;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExGetBossRecord
extends L2GameServerPacket {
    private List<BossRecordInfo> _bossRecordInfo;
    private int _ranking;
    private int _totalPoints;

    public ExGetBossRecord(int ranking, int totalScore, List<BossRecordInfo> bossRecordInfo) {
        this._ranking = ranking;
        this._totalPoints = totalScore;
        this._bossRecordInfo = bossRecordInfo;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._ranking);
        this.writeD(this._totalPoints);
        this.writeD(this._bossRecordInfo.size());
        for (BossRecordInfo w : this._bossRecordInfo) {
            this.writeD(w._bossId);
            this.writeD(w._points);
            this.writeD(w._unk1);
        }
    }

    public static class BossRecordInfo {
        public int _bossId;
        public int _points;
        public int _unk1;

        public BossRecordInfo(int bossId, int points, int unk1) {
            this._bossId = bossId;
            this._points = points;
            this._unk1 = unk1;
        }
    }
}

