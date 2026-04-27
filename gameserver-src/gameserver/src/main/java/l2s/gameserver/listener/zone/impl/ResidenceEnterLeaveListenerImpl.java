/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.listener.zone.impl;

import l2s.gameserver.listener.zone.OnZoneEnterLeaveListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.ResidenceFunctionType;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceFunction;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.FuncMul;
import l2s.gameserver.templates.StatsSet;

public class ResidenceEnterLeaveListenerImpl
implements OnZoneEnterLeaveListener {
    public static final OnZoneEnterLeaveListener STATIC = new ResidenceEnterLeaveListenerImpl();

    @Override
    public void onZoneEnter(Zone zone, Creature actor) {
        double value;
        if (!actor.isPlayer()) {
            return;
        }
        Player player = (Player)actor;
        Residence residence = (Residence)zone.getParams().get("residence");
        if (residence == null) {
            return;
        }
        if (!residence.isOwner(player.getClanId())) {
            return;
        }
        ResidenceFunction function = residence.getActiveFunction(ResidenceFunctionType.RESTORE_HP);
        if (function != null && (value = function.getTemplate().getHpRegen()) > 0.0) {
            player.getStat().addFuncs(new FuncMul(Stats.REGENERATE_HP_RATE, 48, residence, value, StatsSet.EMPTY));
        }
        if ((function = residence.getActiveFunction(ResidenceFunctionType.RESTORE_MP)) != null && (value = function.getTemplate().getMpRegen()) > 0.0) {
            player.getStat().addFuncs(new FuncMul(Stats.REGENERATE_MP_RATE, 48, residence, value, StatsSet.EMPTY));
        }
    }

    @Override
    public void onZoneLeave(Zone zone, Creature actor) {
        if (!actor.isPlayer()) {
            return;
        }
        Residence residence = (Residence)zone.getParams().get("residence");
        if (residence == null) {
            return;
        }
        actor.getStat().removeFuncsByOwner(residence);
    }
}

