/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class p_block_debuff
extends EffectHandler {
    private final int _maxDebuffsDisabled = this.getTemplate().getParams().getInteger("max_disabled_debuffs", -1);

    public p_block_debuff(EffectTemplate template) {
        super(template);
    }

    @Override
    public EffectHandler getImpl() {
        return new p_block_debuff_impl(this.getTemplate());
    }

    private class p_block_debuff_impl
    extends EffectHandler {
        private int _disabledDebuffs;

        public p_block_debuff_impl(EffectTemplate template) {
            super(template);
            this._disabledDebuffs = 0;
        }

        @Override
        protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
            return !effected.isRaid();
        }

        @Override
        public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
            effected.getFlags().getDebuffImmunity().start(this);
        }

        @Override
        public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
            effected.getFlags().getDebuffImmunity().stop(this);
        }

        @Override
        public boolean checkDebuffImmunity(Abnormal abnormal, Creature effector, Creature effected) {
            if (p_block_debuff.this._maxDebuffsDisabled > 0) {
                ++this._disabledDebuffs;
                if (effected.isPlayer() && effected.getPlayer().isGM()) {
                    effected.sendMessage("DebuffImmunity: disabled_debuffs: " + this._disabledDebuffs + " max_disabled_debuffs: " + p_block_debuff.this._maxDebuffsDisabled);
                }
                if (this._disabledDebuffs >= p_block_debuff.this._maxDebuffsDisabled) {
                    effected.getAbnormalList().stop(this.getSkill(), false);
                    if (effected.isPlayer() && effected.getPlayer().isGM()) {
                        effected.sendMessage("DebuffImmunity: All disabled. Abnormal canceled.");
                    }
                }
            }
            return true;
        }
    }
}

