/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.actor.instances.player;

import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.AccountVariablesDAO;
import l2s.gameserver.data.xml.holder.VIPDataHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.DailyMissionList;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ReciveVipInfo;
import l2s.gameserver.templates.VIPTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class VIP {
    private static final Logger _log = LoggerFactory.getLogger(DailyMissionList.class);
    private static final String VIP_POINTS_VAR = "@vip_points";
    private static final String VIP_CONSUMED_POINTS_VAR = "@vip_consumed_points";
    private static final String VIP_CONSUME_START_TIME_VAR = "@vip_consume_start_time";
    private final Player _owner;
    private long _points = 0L;
    private VIPTemplate _vipTemplate = VIPTemplate.DEFAULT_VIP_TEMPLATE;
    private long _totalConsumedPoints = 0L;
    private long _pointsConsumeStartTime = 0L;
    private ScheduledFuture<?> _consumePointsTask = null;

    public VIP(Player owner) {
        this._owner = owner;
    }

    public void restore() {
        if (!Config.EX_USE_PRIME_SHOP) {
            return;
        }
        this.setPoints(Long.parseLong(AccountVariablesDAO.getInstance().select(this._owner.getAccountName(), VIP_POINTS_VAR, "0")));
        this.setTotalConsumedPoints(Long.parseLong(AccountVariablesDAO.getInstance().select(this._owner.getAccountName(), VIP_CONSUMED_POINTS_VAR, "0")));
        this.setPointsConsumeStartTime(Long.parseLong(AccountVariablesDAO.getInstance().select(this._owner.getAccountName(), VIP_CONSUME_START_TIME_VAR, "0")));
        this.checkTemplate(true);
    }

    public synchronized void startTask() {
        if (!Config.EX_USE_PRIME_SHOP) {
            return;
        }
        this.stopTask();
        long consumeCount = this.getPointsConsumeCount();
        long delay = this.getPointsConsumeDelay(TimeUnit.MILLISECONDS);
        long startTime = this.getPointsConsumeStartTime();
        long leftTime = delay + startTime - System.currentTimeMillis();
        if (consumeCount > 0L && delay > 0L) {
            if (startTime > 0L) {
                boolean update = false;
                while (leftTime <= 0L) {
                    update = true;
                    this.setPoints(this.getPoints() - consumeCount);
                    this.setTotalConsumedPoints(this.getTotalConsumedPoints() + consumeCount);
                    this.checkTemplate(false);
                    startTime += delay;
                    consumeCount = this.getPointsConsumeCount();
                    if (consumeCount <= 0L || (delay = this.getPointsConsumeDelay(TimeUnit.MILLISECONDS)) <= 0L) break;
                    leftTime = delay + startTime - System.currentTimeMillis();
                }
                if (update) {
                    AccountVariablesDAO.getInstance().insert(this._owner.getAccountName(), VIP_POINTS_VAR, String.valueOf(this.getPoints()));
                    AccountVariablesDAO.getInstance().insert(this._owner.getAccountName(), VIP_CONSUMED_POINTS_VAR, String.valueOf(this.getTotalConsumedPoints()));
                    this.setPointsConsumeStartTime(startTime);
                    AccountVariablesDAO.getInstance().insert(this._owner.getAccountName(), VIP_CONSUME_START_TIME_VAR, String.valueOf(startTime));
                    this._owner.sendPacket((IBroadcastPacket)new ReciveVipInfo(this._owner));
                }
            } else {
                startTime = System.currentTimeMillis();
                leftTime = delay;
                this.setPointsConsumeStartTime(startTime);
                AccountVariablesDAO.getInstance().insert(this._owner.getAccountName(), VIP_CONSUME_START_TIME_VAR, String.valueOf(startTime));
                this._owner.sendPacket((IBroadcastPacket)new ReciveVipInfo(this._owner));
            }
        }
        if (consumeCount <= 0L || delay <= 0L || leftTime <= 0L) {
            if (startTime > 0L) {
                startTime = 0L;
                this.setPointsConsumeStartTime(startTime);
                AccountVariablesDAO.getInstance().delete(this._owner.getAccountName(), VIP_CONSUME_START_TIME_VAR);
            }
            return;
        }
        this._consumePointsTask = ThreadPoolManager.getInstance().schedule(() -> this.startTask(), leftTime + 1000L);
    }

    public void stopTask() {
        if (this._consumePointsTask != null) {
            this._consumePointsTask.cancel(false);
            this._consumePointsTask = null;
        }
    }

    public long getPoints() {
        return this._points;
    }

    private void setPoints(long value) {
        if (!Config.EX_USE_PRIME_SHOP) {
            return;
        }
        this._points = Math.max(0L, value);
    }

    public synchronized void addPoints(long value) {
        if (!Config.EX_USE_PRIME_SHOP) {
            return;
        }
        if (value <= 0L) {
            return;
        }
        this.setPoints(this.getPoints() + value);
        AccountVariablesDAO.getInstance().insert(this._owner.getAccountName(), VIP_POINTS_VAR, String.valueOf(this.getPoints()));
        if (this.checkTemplate(false)) {
            this.startTask();
        }
    }

    private synchronized boolean checkTemplate(boolean onRestore) {
        VIPTemplate newTemplate = VIPDataHolder.getInstance().getVIPTemplateByPoints(this.getPoints());
        if (!onRestore) {
            if (newTemplate == this._vipTemplate) {
                return false;
            }
            this._vipTemplate.onRemove(this._owner);
        }
        this._vipTemplate = newTemplate;
        this._vipTemplate.onAdd(this._owner);
        return true;
    }

    public VIPTemplate getTemplate() {
        return this._vipTemplate;
    }

    public long getTotalConsumedPoints() {
        return this._totalConsumedPoints;
    }

    public void setTotalConsumedPoints(long value) {
        this._totalConsumedPoints = value;
    }

    public long getPointsConsumeStartTime() {
        return this._pointsConsumeStartTime;
    }

    public void setPointsConsumeStartTime(long value) {
        this._pointsConsumeStartTime = value;
    }

    public long getPointsConsumeLeftTime(TimeUnit timeUnit) {
        long delay = this.getPointsConsumeDelay(TimeUnit.MILLISECONDS);
        if (delay > 0L) {
            return timeUnit.convert(delay + this.getPointsConsumeStartTime() - System.currentTimeMillis(), TimeUnit.MILLISECONDS);
        }
        return 0L;
    }

    public double getPointsRefillPercent() {
        return this._vipTemplate.getPointsRefillPercent();
    }

    public long getPointsConsumeCount() {
        return this._vipTemplate.getPointsConsumeCount();
    }

    public long getPointsConsumeDelay(TimeUnit timeUnit) {
        return this._vipTemplate.getPointsConsumeDelay(timeUnit);
    }

    public int getLevel() {
        return this._vipTemplate.getLevel();
    }

    public String toString() {
        return "VIP[owner=" + this._owner.getName() + "]";
    }
}

