/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class p_block_party
extends EffectHandler {
    public p_block_party(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return effected.isPlayer();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getPlayer().getFlags().getPartyBlocked().start(this);
        effected.getPlayer().leaveParty(false);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getPlayer().getFlags().getPartyBlocked().stop(this);
    }
}

