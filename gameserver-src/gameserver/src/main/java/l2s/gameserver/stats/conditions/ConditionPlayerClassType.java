/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.SubClassType;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerClassType
extends Condition {
    private final SubClassType _type;

    public ConditionPlayerClassType(SubClassType type) {
        this._type = type;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        Player player = env.character.getPlayer();
        return player.getActiveSubClass().getType() == this._type;
    }
}

