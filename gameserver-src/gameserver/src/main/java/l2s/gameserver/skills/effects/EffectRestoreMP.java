/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.Config;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.effects.EffectRestore;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectRestoreMP
extends EffectRestore {
    public EffectRestoreMP(EffectTemplate template) {
        super(template);
    }

    private int calcAddToMp(Creature effector, Creature effected) {
        double power = this.getValue();
        if (power <= 0.0) {
            return 0;
        }
        if (this._percent) {
            power = (double)effected.getMaxMp() / 100.0 * power;
        }
        if (this.getSkill().isHandler()) {
            if (!this._staticPower && !this._ignoreBonuses) {
                power += effector.getStat().getAdd(Stats.POTION_MP_HEAL_EFFECT, effected, this.getSkill());
                power *= effected.getStat().getMul(Stats.POTION_MP_HEAL_EFFECT, effector, this.getSkill());
            }
        } else if (!this._staticPower) {
            if (!this._percent && this.getSkill().isSSPossible() && Config.MANAHEAL_SPS_BONUS) {
                power *= 1.0 + (200.0 + effector.getChargedSpiritshotPower()) * 0.001;
            }
            if (!this._ignoreBonuses) {
                if (this._percent || effector != effected) {
                    power *= effected.getStat().calc(Stats.MANAHEAL_EFFECTIVNESS, 100.0, effector, this.getSkill()) / 100.0;
                }
            } else if (!this._percent) {
                power *= 1.7;
            }
            if (!this._percent && this.getSkill().getTargetType() != Skill.SkillTargetType.TARGET_SELF && this.getSkill().getMagicLevel() > 0 && effected.getLevel() > this.getSkill().getMagicLevel()) {
                int lvlDiff = effected.getLevel() - this.getSkill().getMagicLevel();
                if (lvlDiff == 6) {
                    power *= 0.9;
                } else if (lvlDiff == 7) {
                    power *= 0.8;
                } else if (lvlDiff == 8) {
                    power *= 0.7;
                } else if (lvlDiff == 9) {
                    power *= 0.6;
                } else if (lvlDiff == 10) {
                    power *= 0.5;
                } else if (lvlDiff == 11) {
                    power *= 0.4;
                } else if (lvlDiff == 12) {
                    power *= 0.3;
                } else if (lvlDiff == 13) {
                    power *= 0.2;
                } else if (lvlDiff == 14) {
                    power *= 0.1;
                } else if (lvlDiff >= 15) {
                    power = 0.0;
                }
            }
        }
        return (int)power;
    }

    private int checkRestoreMpLimits(Creature effected, double power) {
        int newMp = (int)(effected.getCurrentMp() + power);
        newMp = Math.max(0, Math.min(newMp, (int)((double)effected.getMaxMp() / 100.0 * effected.getStat().calc(Stats.MP_LIMIT, null, null))));
        newMp = Math.max(0, newMp - (int)effected.getCurrentMp());
        newMp = Math.min(effected.getMaxMp() - (int)effected.getCurrentMp(), newMp);
        return newMp;
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isHealBlocked()) {
            return;
        }
        if (!this.getTemplate().isInstant()) {
            return;
        }
        int addToMp = this.calcAddToMp(effector, effected);
        if (addToMp > 0) {
            addToMp = this.checkRestoreMpLimits(effected, addToMp);
            if (effector != effected) {
                effected.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_MP_HAS_BEEN_RESTORED_BY_C1).addName(effector)).addInteger(addToMp));
            } else {
                effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_MP_HAS_BEEN_RESTORED).addInteger(addToMp));
            }
            effected.setCurrentMp(effected.getCurrentMp() + (double)addToMp, false);
            StatusUpdate su = new StatusUpdate(effected, effector, StatusUpdatePacket.UpdateType.REGEN, 11);
            effector.sendPacket((IBroadcastPacket)su);
            effected.sendPacket((IBroadcastPacket)su);
            effected.broadcastStatusUpdate();
            effected.sendChanges();
        }
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        if (this.getTemplate().isInstant()) {
            return false;
        }
        if (effected.isHealBlocked()) {
            return true;
        }
        int addToMp = this.calcAddToMp(effector, effected);
        if (addToMp > 0) {
            addToMp = this.checkRestoreMpLimits(effected, addToMp);
            effected.setCurrentMp(effected.getCurrentMp() + (double)addToMp, false);
            StatusUpdate su = new StatusUpdate(effected, effector, StatusUpdatePacket.UpdateType.REGEN, 11);
            effector.sendPacket((IBroadcastPacket)su);
            effected.sendPacket((IBroadcastPacket)su);
            effected.broadcastStatusUpdate();
            effected.sendChanges();
        }
        return true;
    }
}

