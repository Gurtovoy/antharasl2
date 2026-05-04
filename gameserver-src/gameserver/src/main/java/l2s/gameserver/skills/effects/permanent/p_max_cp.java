package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.effects.permanent.p_abstract_stat_effect;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class p_max_cp
extends p_abstract_stat_effect {
    private final boolean _restore = this.getParams().getBool("restore", false);

    public p_max_cp(EffectTemplate template) {
        super(template, Stats.MAX_CP);
    }

    @Override
    public void onApplied(Abnormal abnormal, Creature effector, Creature effected) {
        if (!this._restore || effected.isHealBlocked()) {
            return;
        }
        double power = this.getValue();
        if (this.getModifierType() == StatModifierType.PER) {
            power = power / 100.0 * (double)effected.getMaxCp();
        }
        if (power > 0.0) {
            effected.setCurrentCp(effected.getCurrentCp() + power, false);
        }
    }
}

