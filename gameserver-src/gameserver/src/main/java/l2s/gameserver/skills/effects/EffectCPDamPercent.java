/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectCPDamPercent
extends EffectHandler {
    public EffectCPDamPercent(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return !effected.isDead() && effected.isPlayer();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isDead()) {
            return;
        }
        double newCp = (100.0 - this.getValue()) * (double)effected.getMaxCp() / 100.0;
        newCp = Math.min(effected.getCurrentCp(), Math.max(0.0, newCp));
        effected.setCurrentCp(newCp);
    }
}

