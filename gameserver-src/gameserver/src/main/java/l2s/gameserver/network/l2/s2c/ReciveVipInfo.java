/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.concurrent.TimeUnit;
import l2s.gameserver.data.xml.holder.VIPDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.VIPTemplate;

public class ReciveVipInfo
extends L2GameServerPacket {
    private final int _vipLevel;
    private final long _vipPoints;
    private final int _timeLeftForConsume;
    private final long _vipPointsForNextLevel;
    private final long _pointsCountForConsume;
    private final int _vipLevelAfterConsume;
    private final long _totalConsumedPoints;

    public ReciveVipInfo(Player player) {
        this._vipLevel = player.getVIP().getLevel();
        this._vipPoints = player.getVIP().getPoints();
        this._timeLeftForConsume = (int)player.getVIP().getPointsConsumeLeftTime(TimeUnit.SECONDS);
        this._pointsCountForConsume = player.getVIP().getPointsConsumeCount();
        this._totalConsumedPoints = player.getVIP().getTotalConsumedPoints();
        VIPTemplate tempTemplate = VIPDataHolder.getInstance().getVIPTemplate(this._vipLevel + 1);
        this._vipPointsForNextLevel = tempTemplate == null ? Integer.MAX_VALUE : tempTemplate.getPoints();
        tempTemplate = VIPDataHolder.getInstance().getVIPTemplateByPoints(this._vipPoints - this._pointsCountForConsume);
        this._vipLevelAfterConsume = tempTemplate == null ? Math.max(0, this._vipLevel - 1) : tempTemplate.getLevel();
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._vipLevel);
        this.writeQ(this._vipPoints);
        this.writeD(this._timeLeftForConsume);
        this.writeQ(this._vipPointsForNextLevel);
        this.writeQ(this._pointsCountForConsume);
        this.writeC(this._vipLevelAfterConsume);
        this.writeQ(this._totalConsumedPoints);
    }
}

