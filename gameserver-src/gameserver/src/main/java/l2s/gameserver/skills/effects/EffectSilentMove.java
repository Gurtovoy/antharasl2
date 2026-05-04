package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectSilentMove
extends EffectHandler {
    public EffectSilentMove(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return effected.isPlayable() && !effected.isDead();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        ((Playable)effected).getFlags().getSilentMoving().start(this);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        ((Playable)effected).getFlags().getSilentMoving().stop(this);
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isDead()) {
            return false;
        }
        double manaDam = this.getValue();
        if (manaDam > effected.getCurrentMp()) {
            if (this.getSkill().isToggle()) {
                effected.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_MP);
                effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(this.getSkill().getId(), this.getSkill().getDisplayLevel()));
            }
            return false;
        }
        effected.reduceCurrentMp(manaDam, null);
        return true;
    }
}

