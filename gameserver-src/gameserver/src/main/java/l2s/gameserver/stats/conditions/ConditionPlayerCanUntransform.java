/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionPlayerCanUntransform
extends Condition {
    private final boolean _val;

    public ConditionPlayerCanUntransform(boolean val) {
        this._val = val;
    }

    @Override
    protected boolean testImpl(Env env) {
        if (!env.character.isPlayer()) {
            return !this._val;
        }
        Player player = env.character.getPlayer();
        if (!player.isTransformed()) {
            return !this._val;
        }
        if (player.isInFlyingTransform() && Math.abs(player.getZ() - player.getLoc().correctGeoZ((int)player.getGeoIndex()).z) > 333) {
            return !this._val;
        }
        return this._val;
    }
}

