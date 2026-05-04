/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.ResidenceType;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerResidence
extends Condition {
    private final int _id;
    private final ResidenceType _type;

    public ConditionPlayerResidence(int id, ResidenceType type) {
        this._id = id;
        this._type = type;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return false;
        }
        Player player = (Player)env.character;
        Clan clan = player.getClan();
        if (clan == null) {
            return false;
        }
        int residenceId = clan.getResidenceId(this._type);
        return this._id > 0 ? residenceId == this._id : residenceId > 0;
    }
}

