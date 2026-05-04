/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.GameTimeController;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionGameTime
extends Condition {
    private final CheckGameTime _check;
    private final boolean _required;

    public ConditionGameTime(CheckGameTime check, boolean required) {
        this._check = check;
        this._required = required;
    }

    @Override
    protected boolean testImpl(Env env) {
        switch (this._check) {
            case NIGHT: {
                return GameTimeController.getInstance().isNowNight() == this._required;
            }
        }
        return !this._required;
    }

    public static enum CheckGameTime {
        NIGHT;

    }
}

