package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class i_my_summon_kill
extends i_abstract_effect {
    public i_my_summon_kill(EffectTemplate template) {
        super(template);
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        for (Servitor servitor : effected.getServitors()) {
            if (!servitor.isSummon()) continue;
            servitor.unSummon(false);
        }
    }
}

