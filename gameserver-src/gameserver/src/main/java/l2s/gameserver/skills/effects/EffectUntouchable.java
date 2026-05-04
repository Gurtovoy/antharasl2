/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectUntouchable
extends EffectHandler {
    public EffectUntouchable(EffectTemplate template) {
        super(template);
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        effected.setMeditated(true);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        effected.setMeditated(false);
    }
}

