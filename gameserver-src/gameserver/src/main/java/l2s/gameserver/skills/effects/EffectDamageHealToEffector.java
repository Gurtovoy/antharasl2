/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import java.util.Collections;
import java.util.List;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.listener.actor.OnCurrentHpDamageListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.effects.tick.t_hp;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectDamageHealToEffector
extends EffectHandler {
    private final int _hpAbsorbPercent = this.getTemplate().getParams().getInteger("hp_absorb_percent", 0);
    private final int _mpAbsorbPercent = this.getTemplate().getParams().getInteger("mp_absorb_percent", 0);
    private final boolean _healServitors = this.getTemplate().getParams().getBool("heal_servitors", false);

    public EffectDamageHealToEffector(EffectTemplate template) {
        super(template);
    }

    @Override
    public EffectHandler getImpl() {
        return new EffectDamageHealToEffectorImpl(this.getTemplate());
    }

    public class EffectDamageHealToEffectorImpl
    extends t_hp {
        private DamageListener _damageListener;

        public EffectDamageHealToEffectorImpl(EffectTemplate template) {
            super(template);
        }

        @Override
        public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
            this._damageListener = new DamageListener(effector, effected);
            effected.addListener(this._damageListener);
        }

        @Override
        public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
            if (effected.isDead()) {
                effected.removeListener(this._damageListener);
            }
            return super.onActionTime(abnormal, effector, effected);
        }

        @Override
        public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
            effected.removeListener(this._damageListener);
        }

        private class DamageListener
        implements OnCurrentHpDamageListener {
            private final HardReference<? extends Creature> _effectorRef;
            private final HardReference<? extends Creature> _effectedRef;

            public DamageListener(Creature effector, Creature effected) {
                this._effectorRef = effector.getRef();
                this._effectedRef = effected.getRef();
            }

            @Override
            public void onCurrentHpDamage(Creature actor, double damage, Creature attacker, Skill skill) {
                Creature effector = (Creature)this._effectorRef.get();
                if (effector == null) {
                    return;
                }
                List<Servitor> servitors = EffectDamageHealToEffector.this._healServitors ? effector.getServitors() : Collections.emptyList();
                double hp = damage * (double)EffectDamageHealToEffector.this._hpAbsorbPercent / 100.0 / (double)(servitors.size() + 1);
                double mp = damage * (double)EffectDamageHealToEffector.this._mpAbsorbPercent / 100.0 / (double)(servitors.size() + 1);
                for (Servitor servitor : servitors) {
                    if (hp > 0.0) {
                        servitor.setCurrentHp(servitor.getCurrentHp() + hp, false);
                    }
                    if (!(mp > 0.0)) continue;
                    servitor.setCurrentMp(servitor.getCurrentMp() + mp);
                }
                if (hp > 0.0) {
                    effector.setCurrentHp(effector.getCurrentHp() + hp, false);
                    effector.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HP_HAS_BEEN_RESTORED).addInteger(Math.round(hp)));
                }
                if (mp > 0.0) {
                    effector.setCurrentMp(effector.getCurrentMp() + mp);
                    effector.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_MP_HAS_BEEN_RESTORED).addInteger(Math.round(mp)));
                }
            }
        }
    }
}

