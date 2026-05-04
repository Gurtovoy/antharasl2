/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.ResidenceSide;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerCastleType
extends Condition {
    private final ResidenceSide _type;

    public ConditionPlayerCastleType(ResidenceSide type) {
        this._type = type;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        if (env.character.getPlayer().getClan() == null) {
            return false;
        }
        Castle castle = env.character.getPlayer().getCastle();
        if (castle == null) {
            return false;
        }
        return castle.getResidenceSide() == this._type;
    }
}

