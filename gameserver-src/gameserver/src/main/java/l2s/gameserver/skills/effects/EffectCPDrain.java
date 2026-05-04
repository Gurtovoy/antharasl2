package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectCPDrain
extends EffectHandler {
    private final boolean _percent = this.getParams().getBool("percent", false);

    public EffectCPDrain(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return !effected.isDead() && !effected.isRaid();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isDead()) {
            return;
        }
        if (effected == effector) {
            return;
        }
        double drained = this.getValue();
        if (this._percent) {
            drained = (double)effected.getMaxCp() / 100.0 * drained;
        }
        if ((drained = Math.min(drained, effected.getCurrentCp())) <= 0.0) {
            return;
        }
        effected.setCurrentCp(Math.max(0.0, effected.getCurrentCp() - drained));
        double newCp = effector.getCurrentCp() + drained;
        newCp = Math.max(0.0, Math.min(newCp, (double)effector.getMaxCp() / 100.0 * effector.getStat().calc(Stats.CP_LIMIT, null, null)));
        double addToCp = newCp - effected.getCurrentCp();
        if (addToCp > 0.0) {
            effector.setCurrentCp(newCp);
        }
    }
}

