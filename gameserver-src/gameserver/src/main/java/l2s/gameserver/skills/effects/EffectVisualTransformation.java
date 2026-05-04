/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectVisualTransformation
extends EffectHandler {
    public EffectVisualTransformation(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isTransformImmune()) {
            return false;
        }
        return !effected.isInFlyingTransform();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getFlags().getMuted().start(this);
        effected.getFlags().getAMuted().start(this);
        effected.getFlags().getPMuted().start(this);
        effected.abortCast(true, true);
        effected.abortAttack(true, true);
        effected.setVisualTransform((int)this.getValue());
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        effected.setVisualTransform(null);
        effected.getFlags().getMuted().stop(this);
        effected.getFlags().getAMuted().stop(this);
        effected.getFlags().getPMuted().stop(this);
    }
}

