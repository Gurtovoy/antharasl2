/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class i_fishing_shot
extends i_abstract_effect {
    private final double _power = this.getParams().getDouble("power", 100.0);

    public i_fishing_shot(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return effected.isPlayer();
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        effected.sendPacket((IBroadcastPacket)SystemMsg.YOUR_SPIRITSHOT_HAS_BEEN_ENABLED);
        effected.getPlayer().setChargedFishshotPower(this._power);
    }
}

