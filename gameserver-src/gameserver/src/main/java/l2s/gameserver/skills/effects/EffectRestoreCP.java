package l2s.gameserver.skills.effects;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.effects.EffectRestore;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectRestoreCP
extends EffectRestore {
    public EffectRestoreCP(EffectTemplate template) {
        super(template);
    }

    private int calcAddToCp(Creature effector, Creature effected) {
        if (!effected.isPlayer()) {
            return 0;
        }
        double power = this.getValue();
        if (power <= 0.0) {
            return 0;
        }
        if (this._percent) {
            power = (double)effected.getMaxCp() / 100.0 * power;
        }
        if (!this._staticPower && !this._ignoreBonuses) {
            if (this.getSkill().isHandler()) {
                power += effector.getStat().getAdd(Stats.POTION_CP_HEAL_EFFECT, effected, this.getSkill());
                power *= effected.getStat().getMul(Stats.POTION_CP_HEAL_EFFECT, effector, this.getSkill());
            } else {
                power *= effected.getStat().calc(Stats.CPHEAL_EFFECTIVNESS, 100.0, effector, this.getSkill()) / 100.0;
            }
        }
        return (int)power;
    }

    protected int checkRestoreCpLimits(Creature effected, double power) {
        int newCp = (int)(effected.getCurrentCp() + power);
        newCp = Math.max(0, Math.min(newCp, (int)((double)effected.getMaxCp() / 100.0 * effected.getStat().calc(Stats.CP_LIMIT, null, null))));
        newCp = Math.max(0, newCp - (int)effected.getCurrentCp());
        newCp = Math.min(effected.getMaxCp() - (int)effected.getCurrentCp(), newCp);
        return newCp;
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isHealBlocked()) {
            return;
        }
        if (!this.getTemplate().isInstant()) {
            return;
        }
        int addToCp = this.calcAddToCp(effector, effected);
        if (addToCp > 0) {
            addToCp = this.checkRestoreCpLimits(effected, addToCp);
            if (effector != effected) {
                effected.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.S2_CP_HAS_BEEN_RESTORED_BY_C1).addName(effector)).addInteger(addToCp));
            } else {
                effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CP_HAS_BEEN_RESTORED).addInteger(addToCp));
            }
            effected.setCurrentCp(effected.getCurrentCp() + (double)addToCp, false);
            StatusUpdate su = new StatusUpdate(effected, effector, StatusUpdatePacket.UpdateType.REGEN, 33);
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
        int addToCp = this.calcAddToCp(effector, effected);
        if (addToCp > 0) {
            addToCp = this.checkRestoreCpLimits(effected, addToCp);
            effected.setCurrentCp(effected.getCurrentCp() + (double)addToCp, false);
            StatusUpdate su = new StatusUpdate(effected, effector, StatusUpdatePacket.UpdateType.REGEN, 33);
            effector.sendPacket((IBroadcastPacket)su);
            effected.sendPacket((IBroadcastPacket)su);
            effected.broadcastStatusUpdate();
            effected.sendChanges();
        }
        return true;
    }
}

