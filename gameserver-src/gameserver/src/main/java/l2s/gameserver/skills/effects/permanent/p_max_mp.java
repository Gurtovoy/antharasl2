/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.skills.effects.permanent.p_abstract_stat_effect;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class p_max_mp
extends p_abstract_stat_effect {
    private final boolean _heal = this.getParams().getBool("heal", false);

    public p_max_mp(EffectTemplate template) {
        super(template, Stats.MAX_MP);
    }

    @Override
    public void onApplied(Abnormal abnormal, Creature effector, Creature effected) {
        if (!this._heal || effected.isHealBlocked()) {
            return;
        }
        double power = this.getValue();
        if (this.getModifierType() == StatModifierType.PER) {
            power = power / 100.0 * (double)effected.getMaxMp();
        }
        if (power > 0.0) {
            effected.setCurrentMp(effected.getCurrentMp() + power, false);
            StatusUpdate su = new StatusUpdate(effected, effector, StatusUpdatePacket.UpdateType.REGEN, 11);
            effector.sendPacket((IBroadcastPacket)su);
            effected.sendPacket((IBroadcastPacket)su);
            effected.broadcastStatusUpdate();
            effected.sendChanges();
        }
    }
}

