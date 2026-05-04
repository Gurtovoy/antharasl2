/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Player;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.templates.item.ArmorTemplate;

public class ConditionUsingArmor
extends Condition {
    private final ArmorTemplate.ArmorType _armor;

    public ConditionUsingArmor(ArmorTemplate.ArmorType armor) {
        this._armor = armor;
    }

    @Override
    protected boolean testImpl(Env env) {
        return env.character.isPlayer() && ((Player)env.character).getWearingArmorType() == this._armor;
    }
}

