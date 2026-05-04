package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.PledgeBonusUtils;

public class ExPledgeBonusOpen
extends L2GameServerPacket {
    private int _attendanceProgress = 0;
    private int _huntingProgress = 0;
    private int _yesterdayAttendanceReward = 0;
    private int _yesterdayHuntingReward = 0;
    private int _yesterdayAttendanceRewardId = 0;
    private int _yesterdayHuntingRewardId = 0;
    private boolean _attendanceRewardReceivable = false;
    private boolean _huntingRewardReceivable = false;

    public ExPledgeBonusOpen(Player player) {
        if (!Config.EX_USE_PLEDGE_BONUS) {
            return;
        }
        Clan clan = player.getClan();
        if (clan == null) {
            return;
        }
        this._attendanceProgress = clan.getAttendanceProgress();
        this._huntingProgress = clan.getHuntingProgress();
        this._yesterdayAttendanceReward = clan.getYesterdayAttendanceReward();
        this._yesterdayHuntingReward = clan.getYesterdayHuntingReward();
        this._yesterdayAttendanceRewardId = PledgeBonusUtils.ATTENDANCE_REWARDS.get(this._yesterdayAttendanceReward);
        this._yesterdayHuntingRewardId = PledgeBonusUtils.HUNTING_REWARDS.get(this._yesterdayHuntingReward);
        this._attendanceRewardReceivable = this._yesterdayAttendanceRewardId > 0 && PledgeBonusUtils.isAttendanceRewardAvailable(player);
        this._huntingRewardReceivable = this._yesterdayHuntingRewardId > 0 && PledgeBonusUtils.isHuntingRewardAvailable(player);
    }

    @Override
    protected final void writeImpl() {
        this.writeD(30);
        this.writeD(this._attendanceProgress);
        this.writeC(0);
        this.writeD(this._yesterdayAttendanceRewardId);
        this.writeC(this._yesterdayAttendanceReward);
        this.writeC(this._attendanceRewardReceivable);
        this.writeD(1542857);
        this.writeD(this._huntingProgress);
        this.writeC(1);
        this.writeD(this._yesterdayHuntingRewardId);
        this.writeC(this._yesterdayHuntingReward);
        this.writeC(this._huntingRewardReceivable);
    }
}

