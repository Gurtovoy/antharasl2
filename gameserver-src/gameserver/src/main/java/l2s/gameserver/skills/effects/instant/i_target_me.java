package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_target_me
extends i_abstract_effect {
    public i_target_me(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        if (effected.isRaid()) {
            return false;
        }
        return effected != effector;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        effected.setTarget(effector);
        effected.abortCast(true, true);
        effected.abortAttack(true, true);
        effected.getAI().clearNextAction();
    }
}

