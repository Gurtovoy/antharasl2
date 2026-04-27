/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerMaxPK
extends Condition {
    private final int _pk;

    public ConditionPlayerMaxPK(int pk) {
        this._pk = pk;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (env.character.isPlayer()) {
            return ((Player)env.character).getPkKills() <= this._pk;
        }
        return false;
    }
}

