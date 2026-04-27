/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerClanLeaderOnline
extends Condition {
    private final boolean _value;

    public ConditionPlayerClanLeaderOnline(boolean value) {
        this._value = value;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return !this._value;
        }
        Clan clan = env.character.getPlayer().getClan();
        if (clan == null) {
            return !this._value;
        }
        return clan.getLeader().isOnline() == this._value;
    }
}

