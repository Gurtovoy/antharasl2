package l2s.gameserver.model.quest.startcondition.impl;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.startcondition.ICheckStartCondition;

public final class PlayerLevelCondition
implements ICheckStartCondition {
    private final int _min;
    private final int _max;

    public PlayerLevelCondition(int min, int max) {
        this._min = min;
        this._max = max;
    }

    @Override
    public final boolean checkCondition(Player player) {
        return player.getLevel() >= this._min && player.getLevel() <= this._max;
    }
}

