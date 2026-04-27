/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills;

import l2s.gameserver.model.Skill;

public class TimeStamp {
    private final int _id;
    private final int _level;
    private final long _reuse;
    private final long _endTime;

    public TimeStamp(int id, long endTime, long reuse) {
        this._id = id;
        this._level = 0;
        this._reuse = reuse;
        this._endTime = endTime;
    }

    public TimeStamp(Skill skill, long reuse) {
        this(skill, System.currentTimeMillis() + reuse, reuse);
    }

    public TimeStamp(Skill skill, long endTime, long reuse) {
        this._id = skill.getId();
        this._level = skill.getLevel();
        this._reuse = reuse;
        this._endTime = endTime;
    }

    public long getReuseBasic() {
        if (this._reuse == 0L) {
            return this.getReuseCurrent();
        }
        return this._reuse;
    }

    public long getReuseCurrent() {
        return Math.max(this._endTime - System.currentTimeMillis(), 0L);
    }

    public long getEndTime() {
        return this._endTime;
    }

    public boolean hasNotPassed() {
        return System.currentTimeMillis() < this._endTime;
    }

    public int getId() {
        return this._id;
    }

    public int getLevel() {
        return this._level;
    }
}

