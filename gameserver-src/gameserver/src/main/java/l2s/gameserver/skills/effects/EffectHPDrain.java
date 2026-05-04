/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectHPDrain
extends EffectHandler {
    private final boolean _percent = this.getParams().getBool("percent", false);

    public EffectHPDrain(EffectTemplate template) {
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
            drained = (double)effected.getMaxHp() / 100.0 * drained;
        }
        if ((drained = Math.min(drained, effected.getCurrentHp())) <= 0.0) {
            return;
        }
        effected.setCurrentHp(Math.max(0.0, effected.getCurrentHp() - drained), false);
        effected.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_DRAINED_YOU_OF_S2_HP).addName(effector)).addInteger(Math.round(drained)));
        double newHp = effector.getCurrentHp() + drained;
        newHp = Math.max(0.0, Math.min(newHp, (double)effector.getMaxHp() / 100.0 * effector.getStat().calc(Stats.HP_LIMIT, null, null)));
        double addToHp = newHp - effected.getCurrentHp();
        if (addToHp > 0.0) {
            effector.setCurrentHp(newHp, false);
        }
    }
}

