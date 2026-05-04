package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_pledge_reputation
extends i_abstract_effect {
    public i_pledge_reputation(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return effected.getClan() != null;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        effected.getClan().incReputation((int)this.getValue(), false, "Using skill ID[" + this.getSkill().getId() + "] LEVEL[" + this.getSkill().getLevel() + "]");
    }
}

