/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerQuestState
extends Condition {
    private final int _questId;
    private final int _cond;

    public ConditionPlayerQuestState(int questId, int cond) {
        this._questId = questId;
        this._cond = cond;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        Player player = env.character.getPlayer();
        QuestState qs = player.getQuestState(this._questId);
        if (qs == null) {
            return false;
        }
        return qs.getCond() == this._cond;
    }
}

