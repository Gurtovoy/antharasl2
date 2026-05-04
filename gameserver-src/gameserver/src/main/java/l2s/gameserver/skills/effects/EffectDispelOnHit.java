/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.listener.actor.OnAttackListener;
import l2s.gameserver.listener.actor.OnMagicUseListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class EffectDispelOnHit
extends EffectHandler {
    private final int _maxHitCount = this.getTemplate().getParams().getInteger("max_hits", 0);

    public EffectDispelOnHit(EffectTemplate template) {
        super(template);
    }

    @Override
    public EffectHandler getImpl() {
        return new EffectDispelOnHitImpl(this.getTemplate());
    }

    private class EffectDispelOnHitImpl
    extends EffectHandler {
        private AttackListener _listener;
        private int _hitCount;

        public EffectDispelOnHitImpl(EffectTemplate template) {
            super(template);
            this._hitCount = 0;
        }

        private void onAttack(Abnormal abnormal, Creature effector, Creature effected) {
            ++this._hitCount;
            if (this._hitCount >= EffectDispelOnHit.this._maxHitCount) {
                effected.getAbnormalList().stop(this.getSkill(), false);
            }
        }

        @Override
        protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
            return !effected.isRaid();
        }

        @Override
        public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
            this._listener = new AttackListener(abnormal, effector, effected);
            effected.addListener(this._listener);
        }

        @Override
        public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
            effected.removeListener(this._listener);
            this._listener = null;
        }

        private class AttackListener
        implements OnAttackListener,
        OnMagicUseListener {
            private final Abnormal _abnormal;
            private final HardReference<? extends Creature> _effectorRef;
            private final HardReference<? extends Creature> _effectedRef;

            public AttackListener(Abnormal abnormal, Creature effector, Creature effected) {
                this._abnormal = abnormal;
                this._effectorRef = effector.getRef();
                this._effectedRef = effected.getRef();
            }

            @Override
            public void onMagicUse(Creature actor, Skill skill, Creature target, boolean alt) {
                if (!skill.isDebuff()) {
                    return;
                }
                EffectDispelOnHitImpl.this.onAttack(this._abnormal, (Creature)this._effectorRef.get(), (Creature)this._effectedRef.get());
            }

            @Override
            public void onAttack(Creature actor, Creature target) {
                EffectDispelOnHitImpl.this.onAttack(this._abnormal, (Creature)this._effectorRef.get(), (Creature)this._effectedRef.get());
            }
        }
    }
}

