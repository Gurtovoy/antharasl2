/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.actor.instances.player.TrainingCamp;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExTrainingZone_Admission
extends L2GameServerPacket {
    private final int _timeElapsed;
    private final int _timeRemaining;
    private final double _maxExp;
    private final double _maxSp;

    public ExTrainingZone_Admission(int level, int timeElapsed, int timeRemaing) {
        this._timeElapsed = timeElapsed;
        this._timeRemaining = timeRemaing;
        double experience = (double)Experience.getExpForLevel(level) * Experience.getTrainingRate(level) / (double)TrainingCamp.TRAINING_DIVIDER;
        this._maxExp = experience * Config.RATE_XP_BY_LVL[level];
        this._maxSp = experience * Config.RATE_SP_BY_LVL[level] / 250.0;
    }

    public ExTrainingZone_Admission(TrainingCamp trainingCamp) {
        this(trainingCamp.getLevel(), 0, trainingCamp.getMaxDuration());
    }

    @Override
    public void writeImpl() {
        this.writeD(this._timeElapsed);
        this.writeD(this._timeRemaining);
        this.writeF(this._maxExp);
        this.writeF(this._maxSp);
    }
}

