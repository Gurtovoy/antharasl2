/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.utils;

import l2s.commons.util.Rnd;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.MapRegionManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.TeleportPoint;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.templates.mapregion.RestartArea;
import l2s.gameserver.templates.mapregion.RestartPoint;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TeleportUtils {
    private static final Logger _log = LoggerFactory.getLogger(TeleportUtils.class);
    public static final Location DEFAULT_RESTART = new Location(17817, 170079, -3530);

    public static TeleportPoint getRestartPoint(Player player, RestartType restartType) {
        return TeleportUtils.getRestartPoint(player, player.getLoc(), restartType);
    }

    public static TeleportPoint getRestartPoint(Player player, Location from, RestartType restartType) {
        RestartArea ra;
        Clan clan;
        TeleportPoint teleportPoint = new TeleportPoint();
        Reflection r = player.getReflection();
        if (!r.isMain()) {
            if (r.getCoreLoc() != null) {
                return teleportPoint.setLoc(r.getCoreLoc());
            }
            if (r.getReturnLoc() != null) {
                return teleportPoint.setLoc(r.getReturnLoc());
            }
        }
        if ((clan = player.getClan()) != null) {
            Reflection reflection;
            Object residence;
            int residenceId = 0;
            if (restartType == RestartType.TO_CLANHALL) {
                residenceId = clan.getHasHideout();
            } else if (restartType == RestartType.TO_CASTLE) {
                residenceId = clan.getCastle();
            }
            if (residenceId != 0 && (residence = ResidenceHolder.getInstance().getResidence(residenceId)) != null && (reflection = ((Residence)residence).getReflection(clan.getClanId())) != null) {
                teleportPoint.setLoc(((Residence)residence).getOwnerRestartPoint());
                teleportPoint.setReflection(reflection);
                return teleportPoint;
            }
        }
        if (player.isPK()) {
            if (player.getPKRestartPoint() != null) {
                return teleportPoint.setLoc(player.getPKRestartPoint());
            }
        } else if (player.getRestartPoint() != null) {
            return teleportPoint.setLoc(player.getRestartPoint());
        }
        if ((ra = MapRegionManager.getInstance().getRegionData(RestartArea.class, from)) != null) {
            RestartPoint rp = ra.getRestartPoint().get(player.getRace());
            Location restartPoint = (Location)Rnd.get(rp.getRestartPoints());
            Location PKrestartPoint = (Location)Rnd.get(rp.getPKrestartPoints());
            return teleportPoint.setLoc(player.isPK() ? PKrestartPoint : restartPoint);
        }
        _log.warn("Cannot find restart location from coordinates: " + from + "!");
        return teleportPoint.setLoc(DEFAULT_RESTART);
    }
}

