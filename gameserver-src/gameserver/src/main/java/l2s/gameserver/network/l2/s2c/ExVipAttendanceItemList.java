package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import java.util.Collections;
import l2s.gameserver.data.xml.holder.AttendanceRewardHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.data.AttendanceRewardData;

public class ExVipAttendanceItemList
extends L2GameServerPacket {
    private final int _indexToReceive;
    private final int _lastReceivedIndex;
    private final boolean _received;
    private final Collection<AttendanceRewardData> _rewards;

    public ExVipAttendanceItemList(Player player) {
        this._indexToReceive = player.getAttendanceRewards().getNextRewardIndex();
        this._lastReceivedIndex = player.getAttendanceRewards().getReceivedRewardIndex();
        this._received = player.getAttendanceRewards().isReceived();
        this._rewards = this._indexToReceive > 0 ? AttendanceRewardHolder.getInstance().getRewards(player.hasPremiumAccount()) : Collections.emptyList();
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._indexToReceive);
        this.writeC(this._lastReceivedIndex);
        this.writeD(0);
        this.writeD(0);
        this.writeC(1);
        this.writeC(!this._received);
        this.writeC(250);
        this.writeC(this._rewards.size());
        this._rewards.forEach(reward -> {
            this.writeD(reward.getId());
            this.writeQ(reward.getCount());
            this.writeC(reward.isUnknown());
            this.writeC(reward.isBest());
        });
        this.writeC(0);
        this.writeD(0);
    }
}

