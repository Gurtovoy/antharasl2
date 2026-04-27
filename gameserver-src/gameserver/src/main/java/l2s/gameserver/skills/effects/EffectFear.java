/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.templates.skill.EffectTemplate;
import l2s.gameserver.utils.PositionUtils;

public final class EffectFear
extends EffectHandler {
    public static final double FEAR_RANGE = 900.0;

    public EffectFear(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.isFearImmune()) {
            return false;
        }
        Player player = effected.getPlayer();
        if (player != null && effected.isSummon()) {
            for (SiegeEvent siegeEvent : player.getEvents(SiegeEvent.class)) {
                if (!siegeEvent.containsSiegeSummon((SummonInstance)effected)) continue;
                return false;
            }
        }
        return !effected.isInPeaceZone();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        if (effected.getFlags().getAfraid().start(this)) {
            effected.abortAttack(true, true);
            effected.abortCast(true, true);
            effected.getMovement().stopMove();
        }
        this.onActionTime(abnormal, effector, effected);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getFlags().getAfraid().stop(this);
        effected.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
    }

    @Override
    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        double angle = Math.toRadians(PositionUtils.calculateAngleFrom(effector, effected));
        int oldX = effected.getX();
        int oldY = effected.getY();
        int x = oldX + (int)(900.0 * Math.cos(angle));
        int y = oldY + (int)(900.0 * Math.sin(angle));
        int z = effected.getZ();
        Location loc = GeoEngine.moveCheck(oldX, oldY, z, x, y, effected.getGeoIndex());
        if (loc == null) {
            return true;
        }
        effected.setRunning();
        effected.getMovement().moveToLocation(loc, 0, false);
        return true;
    }

    @Override
    public int getInterval() {
        return 3;
    }
}

