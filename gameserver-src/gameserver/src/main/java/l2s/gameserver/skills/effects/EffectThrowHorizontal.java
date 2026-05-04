package l2s.gameserver.skills.effects;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.FlyToLocationPacket;
import l2s.gameserver.skills.effects.EffectFlyAbstract;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectThrowHorizontal
extends EffectFlyAbstract {
    public EffectThrowHorizontal(EffectTemplate template) {
        super(template);
    }

    @Override
    public EffectHandler getImpl() {
        return new EffectThrowHorizontalImpl(this.getTemplate());
    }

    private class EffectThrowHorizontalImpl
    extends EffectHandler {
        private Location _flyLoc;

        public EffectThrowHorizontalImpl(EffectTemplate template) {
            super(template);
            this._flyLoc = null;
        }

        @Override
        protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
            if (effected.isThrowAndKnockImmune()) {
                effected.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
                return false;
            }
            Player player = effected.getPlayer();
            if (player != null && effected.isSummon()) {
                for (SiegeEvent siegeEvent : player.getEvents(SiegeEvent.class)) {
                    if (!siegeEvent.containsSiegeSummon((SummonInstance)effected)) continue;
                    effector.sendPacket((IBroadcastPacket)SystemMsg.THAT_IS_AN_INCORRECT_TARGET);
                    return false;
                }
            }
            if (effected.isInPeaceZone()) {
                effector.sendPacket((IBroadcastPacket)SystemMsg.YOU_MAY_NOT_ATTACK_IN_A_PEACEFUL_ZONE);
                return false;
            }
            this._flyLoc = effected.getFlyLocation(effector, this.getSkill());
            return this._flyLoc != null;
        }

        @Override
        public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
            effected.abortAttack(true, true);
            effected.abortCast(true, true);
            effected.getMovement().stopMove();
            effected.block();
            effected.broadcastPacket(new FlyToLocationPacket(effected, this._flyLoc, FlyToLocationPacket.FlyType.THROW_HORIZONTAL, EffectThrowHorizontal.this.getFlySpeed(), EffectThrowHorizontal.this.getFlyDelay(), EffectThrowHorizontal.this.getFlyAnimationSpeed()));
            effected.setLoc(this._flyLoc);
        }

        @Override
        public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
            effected.unblock();
        }
    }
}

