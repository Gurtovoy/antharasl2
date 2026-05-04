package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectMPDamPercent
extends EffectHandler {
    public EffectMPDamPercent(EffectTemplate template) {
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
        double newMp = (100.0 - this.getValue()) * (double)effected.getMaxMp() / 100.0;
        newMp = Math.min(effected.getCurrentMp(), Math.max(0.0, newMp));
        effected.setCurrentMp(newMp, false);
        StatusUpdate su = new StatusUpdate(effected, effector, StatusUpdatePacket.UpdateType.DAMAGED, 11);
        effector.sendPacket((IBroadcastPacket)su);
        effected.sendPacket((IBroadcastPacket)su);
        effected.broadcastStatusUpdate();
        effected.sendChanges();
    }
}

