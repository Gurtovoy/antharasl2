package l2s.gameserver.skills.effects;

import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectMoveToEffector
extends EffectHandler {
    public EffectMoveToEffector(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isFearImmune()) {
            return false;
        }
        Player player = effected.getPlayer();
        if (player != null && effected.isSummon()) {
            for (SiegeEvent siegeEvent : player.getEvents(SiegeEvent.class)) {
                if (!siegeEvent.containsSiegeSummon((SummonInstance)effected)) continue;
                return false;
            }
        }
        return !effected.isInPeaceZone();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.getFlags().getAfraid().start(this)) {
            effected.abortAttack(true, true);
            effected.abortCast(true, true);
            effected.getMovement().stopMove();
        }
        this.onActionTime(abnormal, effector, effected);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getFlags().getAfraid().stop(this);
        effected.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getMovement().moveToLocation(effector.getLoc(), 40, true);
        return true;
    }
}

