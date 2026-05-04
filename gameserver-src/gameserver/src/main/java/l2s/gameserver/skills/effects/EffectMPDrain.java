package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectMPDrain
extends EffectHandler {
    private final boolean _percent = this.getParams().getBool("percent", false);

    public EffectMPDrain(EffectTemplate template) {
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
            drained = (double)effected.getMaxMp() / 100.0 * drained;
        }
        if ((drained = Math.min(drained, effected.getCurrentMp())) <= 0.0) {
            return;
        }
        effected.setCurrentMp(Math.max(0.0, effected.getCurrentMp() - drained), false);
        StatusUpdate su = new StatusUpdate(effected, effector, StatusUpdatePacket.UpdateType.DAMAGED, 11);
        effector.sendPacket((IBroadcastPacket)su);
        effected.sendPacket((IBroadcastPacket)su);
        effected.broadcastStatusUpdate();
        effected.sendChanges();
        effected.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2S_MP_HAS_BEEN_DRAINED_BY_C1).addInteger(Math.round(drained))).addName(effector));
        double newMp = effector.getCurrentMp() + drained;
        newMp = Math.max(0.0, Math.min(newMp, (double)effector.getMaxMp() / 100.0 * effector.getStat().calc(Stats.MP_LIMIT, null, null)));
        double addToMp = newMp - effected.getCurrentMp();
        if (addToMp > 0.0) {
            effector.setCurrentMp(newMp, false);
            effector.sendPacket((IBroadcastPacket)new StatusUpdate(effector, effector, StatusUpdatePacket.UpdateType.REGEN, 11));
            effector.broadcastStatusUpdate();
            effector.sendChanges();
        }
    }
}

