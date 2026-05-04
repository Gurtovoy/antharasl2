/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.quest.startcondition.impl;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.startcondition.ICheckStartCondition;

public final class QuestCompletedCondition
implements ICheckStartCondition {
    private final int _questId;

    public QuestCompletedCondition(int questId) {
        this._questId = questId;
    }

    @Override
    public final boolean checkCondition(Player player) {
        return player.isQuestCompleted(this._questId);
    }
}

