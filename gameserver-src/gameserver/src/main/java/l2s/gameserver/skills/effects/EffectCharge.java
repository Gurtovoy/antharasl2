/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectCharge
extends EffectHandler {
    public EffectCharge(EffectTemplate template) {
        super(template);
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isPlayer()) {
            Player player = (Player)effected;
            if ((double)player.getIncreasedForce() >= this.getValue()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOUR_FORCE_HAS_REACHED_MAXIMUM_CAPACITY_);
            } else {
                player.setIncreasedForce(player.getIncreasedForce() + 1);
            }
        }
    }
}

