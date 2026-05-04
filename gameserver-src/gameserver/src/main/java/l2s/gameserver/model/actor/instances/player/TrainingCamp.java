/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.actor.instances.player;

import java.util.concurrent.TimeUnit;
import l2s.gameserver.Config;
import l2s.gameserver.instancemanager.TrainingCampManager;
import l2s.gameserver.model.Player;

public class TrainingCamp {
    public static final long TRAINING_DIVIDER = TimeUnit.SECONDS.toMinutes(Config.TRAINING_CAMP_MAX_DURATION);
    private final String _accountName;
    private final int _objectId;
    private final int _classIndex;
    private final int _level;
    private final long _startTime;
    private long _endTime = 0L;

    public TrainingCamp(String accountName, int objectId, int classIndex, int level, long startTime, long endTime) {
        this._accountName = accountName;
        this._objectId = objectId;
        this._classIndex = classIndex;
        this._level = level;
        this._startTime = startTime;
        this._endTime = endTime;
    }

    public TrainingCamp(String accountName, int objectId, int classIndex, int level, long startTime) {
        this._accountName = accountName;
        this._objectId = objectId;
        this._classIndex = classIndex;
        this._level = level;
        this._startTime = startTime;
    }

    public int getObjectId() {
        return this._objectId;
    }

    public int getClassIndex() {
        return this._classIndex;
    }

    public int getLevel() {
        return this._level;
    }

    public long getStartTime() {
        return this._startTime;
    }

    public void setEndTime(long value) {
        this._endTime = value;
    }

    public long getEndTime() {
        return this._endTime;
    }

    public boolean isTraining() {
        return this._endTime == 0L;
    }

    public boolean isValid(Player player) {
        return Config.TRAINING_CAMP_ENABLE && player.getObjectId() == this._objectId && player.getActiveSubClass().getIndex() == this._classIndex;
    }

    public int getElapsedTime() {
        return Math.max(0, (int)TimeUnit.SECONDS.convert(System.currentTimeMillis() - this._startTime, TimeUnit.MILLISECONDS));
    }

    public int getRemainingTime() {
        return Math.max(0, this.getMaxDuration() - this.getElapsedTime());
    }

    public long getTrainingTime(TimeUnit unit) {
        long time = Math.max(0L, unit.convert(this._endTime - this._startTime, TimeUnit.MILLISECONDS));
        time = Math.min(time, unit.convert(this.getMaxDuration(), TimeUnit.SECONDS));
        return time;
    }

    public int getMaxDuration() {
        return Math.max(0, Config.TRAINING_CAMP_MAX_DURATION - TrainingCampManager.getInstance().getTrainingCampDuration(this._accountName));
    }
}

