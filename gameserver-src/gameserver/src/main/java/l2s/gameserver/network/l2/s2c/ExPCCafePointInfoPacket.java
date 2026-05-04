package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPCCafePointInfoPacket
extends L2GameServerPacket {
    private int _mAddPoint;
    private int _mPeriodType;
    private int _pointType;
    private int _pcBangPoints;
    private int _remainTime;

    public ExPCCafePointInfoPacket(Player player, int mAddPoint, int mPeriodType, int pointType, int remainTime) {
        this._pcBangPoints = player.getPcBangPoints();
        this._mAddPoint = mAddPoint;
        this._mPeriodType = mPeriodType;
        this._pointType = pointType;
        this._remainTime = remainTime;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._pcBangPoints);
        this.writeD(this._mAddPoint);
        this.writeC(this._mPeriodType);
        this.writeD(this._remainTime);
        this.writeC(this._pointType);
        this.writeD(0);
    }
}

