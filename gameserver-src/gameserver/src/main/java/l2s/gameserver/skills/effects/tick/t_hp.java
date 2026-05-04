package l2s.gameserver.skills.effects.tick;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public class t_hp
extends EffectHandler {
    private final boolean _percent = this.getTemplate().getParams().getBool("percent", false);

    public t_hp(EffectTemplate template) {
        super(template);
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        this.giveDamage(effector, effected, true);
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        this.giveDamage(effector, effected, false);
        return true;
    }

    private void giveDamage(Creature effector, Creature effected, boolean first) {
        if (effected.isDead()) {
            return;
        }
        double hp = this.getValue() * (double)this.getInterval();
        if (this._percent) {
            hp = (double)(effected.getMaxHp() / 100) * hp;
        }
        if (first) {
            if (this.getSkill().isMagic() && Formulas.calcMCrit(effector, effected, this.getSkill())) {
                hp *= 10.0;
            } else {
                return;
            }
        }
        if (hp > 0.0) {
            double heal = effected.getCurrentHp() + hp;
            heal = Math.max(0.0, Math.min(heal, (double)effected.getMaxHp() / 100.0 * effected.getStat().calc(Stats.HP_LIMIT, null, null)));
            heal = Math.max(0.0, heal - effected.getCurrentHp());
            effected.setCurrentHp(effected.getCurrentHp() + heal, false, false);
            StatusUpdate su = new StatusUpdate(effected, effector, StatusUpdatePacket.UpdateType.REGEN, 9);
            effector.sendPacket((IBroadcastPacket)su);
            effected.sendPacket((IBroadcastPacket)su);
            effected.broadcastStatusUpdate();
            effected.sendChanges();
        } else if (hp < 0.0) {
            double damage = effector.getStat().calc(this.getSkill().isMagic() ? Stats.INFLICTS_M_DAMAGE_POWER : Stats.INFLICTS_P_DAMAGE_POWER, Math.abs(hp), effected, this.getSkill());
            damage = Math.min(damage, effected.getCurrentHp() - 1.0);
            if (this.getSkill().getAbsorbPart() > 0.0) {
                effector.setCurrentHp(this.getSkill().getAbsorbPart() * Math.min(effected.getCurrentHp(), damage) + effector.getCurrentHp(), false);
            }
            boolean awake = !effected.isNpc() && effected != effector;
            boolean standUp = effected != effector;
            boolean directHp = effector.isNpc() || effected == effector;
            effected.reduceCurrentHp(damage, effector, this.getSkill(), awake, standUp, directHp, false, false, true, false);
        }
    }
}

