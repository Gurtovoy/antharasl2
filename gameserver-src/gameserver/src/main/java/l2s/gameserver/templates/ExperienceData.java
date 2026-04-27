/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates;

public final class ExperienceData {
    private final int _level;
    private final long _exp;
    private final double _trainingRate;

    public ExperienceData(int level, long exp, double trainingRate) {
        this._level = level;
        this._exp = exp;
        this._trainingRate = trainingRate;
    }

    public int getLevel() {
        return this._level;
    }

    public long getExp() {
        return this._exp;
    }

    public double getTrainingRate() {
        return this._trainingRate;
    }
}

