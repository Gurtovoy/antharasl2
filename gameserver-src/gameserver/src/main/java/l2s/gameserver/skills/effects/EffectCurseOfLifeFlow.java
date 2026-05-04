package l2s.gameserver.skills.effects;

import gnu.trove.iterator.TObjectIntIterator;
import gnu.trove.map.hash.TObjectIntHashMap;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.listener.actor.OnCurrentHpDamageListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectCurseOfLifeFlow
extends EffectHandler {
    public EffectCurseOfLifeFlow(EffectTemplate template) {
        super(template);
    }

    @Override
    public EffectHandler getImpl() {
        return new EffectCurseOfLifeFlowImpl(this.getTemplate());
    }

    private class EffectCurseOfLifeFlowImpl
    extends EffectHandler {
        private final TObjectIntHashMap<HardReference<? extends Creature>> _damageList;
        private CurseOfLifeFlowListener _listener;

        public EffectCurseOfLifeFlowImpl(EffectTemplate template) {
            super(template);
            this._damageList = new TObjectIntHashMap();
        }

        @Override
        protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
            return !effected.isRaid();
        }

        @Override
        public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
            this._listener = new CurseOfLifeFlowListener(effector, effected);
            effected.addListener(this._listener);
        }

        @Override
        public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
            effected.removeListener(this._listener);
            this._listener = null;
        }

        @Override
        public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
            if (effected.isDead()) {
                return false;
            }
            TObjectIntIterator iterator = this._damageList.iterator();
            while (iterator.hasNext()) {
                int damage;
                iterator.advance();
                Creature damager = (Creature)((HardReference)iterator.key()).get();
                if (damager == null || damager.isDead() || damager.isCurrentHpFull() || (damage = iterator.value()) <= 0) continue;
                double max_heal = this.getValue();
                double heal = Math.min((double)damage, max_heal);
                double newHp = Math.min(damager.getCurrentHp() + heal, (double)damager.getMaxHp());
                if (damager != effector) {
                    damager.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_HP_HAS_BEEN_RESTORED_BY_C1).addName(effector)).addLong((long)(newHp - damager.getCurrentHp())));
                } else {
                    damager.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HP_HAS_BEEN_RESTORED).addLong((long)(newHp - damager.getCurrentHp())));
                }
                damager.setCurrentHp(newHp, false);
            }
            this._damageList.clear();
            return true;
        }

        private class CurseOfLifeFlowListener
        implements OnCurrentHpDamageListener {
            private final HardReference<? extends Creature> _effectorRef;
            private final HardReference<? extends Creature> _effectedRef;

            public CurseOfLifeFlowListener(Creature effector, Creature effected) {
                this._effectorRef = effector.getRef();
                this._effectedRef = effected.getRef();
            }

            @Override
            public void onCurrentHpDamage(Creature actor, double damage, Creature attacker, Skill skill) {
                Creature effected = (Creature)this._effectedRef.get();
                if (effected == null || attacker == actor || attacker == effected) {
                    return;
                }
                int old_damage = EffectCurseOfLifeFlowImpl.this._damageList.get(attacker.getRef());
                EffectCurseOfLifeFlowImpl.this._damageList.put(attacker.getRef(), old_damage == 0 ? (int)damage : old_damage + (int)damage);
            }
        }
    }
}

