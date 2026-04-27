/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates;

import java.util.concurrent.TimeUnit;
import l2s.gameserver.templates.PremiumAccountTemplate;
import l2s.gameserver.templates.StatsSet;

public class VIPTemplate
extends PremiumAccountTemplate {
    public static final VIPTemplate DEFAULT_VIP_TEMPLATE = new VIPTemplate(0, 0L, 0.0, 0L, 0, StatsSet.EMPTY);
    private final int _level;
    private final long _points;
    private double _pointsRefillPercent;
    private long _pointsConsumeCount;
    private int _pointsConsumeDelay;

    public VIPTemplate(int level, long points, double pointsRefillPercent, long pointsConsumeCount, int pointsConsumeDelay, StatsSet set) {
        super(100000000 + level, set);
        this._level = level;
        this._points = points;
        this.setPointsRefillPercent(pointsRefillPercent);
        this.setPointsConsumeCount(pointsConsumeCount);
        this.setPointsConsumeDelay(pointsConsumeDelay);
    }

    public int getLevel() {
        return this._level;
    }

    public long getPoints() {
        return this._points;
    }

    public double getPointsRefillPercent() {
        return this._pointsRefillPercent;
    }

    public void setPointsRefillPercent(double value) {
        this._pointsRefillPercent = value;
    }

    public long getPointsConsumeCount() {
        return this._pointsConsumeCount;
    }

    public void setPointsConsumeCount(long value) {
        this._pointsConsumeCount = value;
    }

    public long getPointsConsumeDelay(TimeUnit timeUnit) {
        return timeUnit.convert(this._pointsConsumeDelay, TimeUnit.HOURS);
    }

    public void setPointsConsumeDelay(int value) {
        this._pointsConsumeDelay = value;
    }
}

