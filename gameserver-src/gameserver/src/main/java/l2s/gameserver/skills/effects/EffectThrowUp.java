/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.s2c.FlyToLocationPacket;
import l2s.gameserver.skills.effects.EffectFlyAbstract;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectThrowUp
extends EffectFlyAbstract {
    public EffectThrowUp(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return !effected.isRaid();
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        int curX = effected.getX();
        int curY = effected.getY();
        int curZ = effected.getZ();
        double dx = effector.getX() - curX;
        double dy = effector.getY() - curY;
        double dz = effector.getZ() - curZ;
        double distance = Math.sqrt(dx * dx + dy * dy);
        if (distance > 2000.0) {
            return;
        }
        int offset = Math.min((int)distance + this.getFlyRadius(), 1400);
        if ((offset = (int)((double)offset + Math.abs(dz))) < 5) {
            offset = 5;
        }
        if (distance < 1.0) {
            return;
        }
        double sin = dy / distance;
        double cos = dx / distance;
        int x = effector.getX() - (int)((double)offset * cos);
        int y = effector.getY() - (int)((double)offset * sin);
        int z = effected.getZ();
        Location destiny = GeoEngine.moveCheck(effected.getX(), effected.getY(), effected.getZ(), x, y, effected.getGeoIndex());
        if (destiny == null) {
            return;
        }
        x = destiny.getX();
        y = destiny.getY();
        effected.getFlags().getStunned().start(this);
        effected.broadcastPacket(new FlyToLocationPacket(effected, new Location(x, y, z), FlyToLocationPacket.FlyType.THROW_UP, this.getFlySpeed(), this.getFlyDelay(), this.getFlyAnimationSpeed()));
        effected.setXYZ(x, y, z);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        effected.getFlags().getStunned().stop(this);
    }
}

