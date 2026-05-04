/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.SkillTrait;
import l2s.gameserver.templates.skill.EffectTemplate;

public class p_defence_trait
extends EffectHandler {
    private final SkillTrait _type;
    private final double _power;

    public p_defence_trait(EffectTemplate template) {
        super(template);
        String traitName = this.getTemplate().getParams().getString("type").toUpperCase();
        if (traitName.startsWith("TRAIT_")) {
            traitName = traitName.substring(6).trim();
        }
        this._type = SkillTrait.valueOf(traitName);
        this._power = ((double)this.getTemplate().getParams().getInteger("power") + 100.0) / 100.0;
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (this._power == 1.0) {
            return;
        }
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        if (this._power == 1.0) {
            return;
        }
    }
}

