/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectEffectImmunity
extends EffectHandler {
    private final boolean _withException = this.getParams().getBool("with_exception", false);

    public EffectEffectImmunity(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return !effected.isRaid();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getFlags().getEffectImmunity().start(this);
        if (this._withException) {
            if (effected == effector) {
                if (this.getSkill().equals(effector.getSkillCast(SkillCastingType.NORMAL).getSkillEntry().getTemplate())) {
                    effected.setEffectImmunityException(effector.getSkillCast(SkillCastingType.NORMAL).getTarget());
                } else if (this.getSkill().equals(effector.getSkillCast(SkillCastingType.NORMAL_SECOND).getSkillEntry().getTemplate())) {
                    effected.setEffectImmunityException(effector.getSkillCast(SkillCastingType.NORMAL_SECOND).getTarget());
                }
            } else {
                effected.setEffectImmunityException(effector);
            }
        }
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getFlags().getEffectImmunity().stop(this);
        effected.setEffectImmunityException(null);
    }
}

