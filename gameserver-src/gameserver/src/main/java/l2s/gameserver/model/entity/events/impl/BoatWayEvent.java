/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.impl;

import java.util.List;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.Config;
import l2s.gameserver.data.BoatHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.objects.BoatPoint;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.utils.MapUtils;

public class BoatWayEvent
extends Event {
    public static final String BOAT_POINTS = "boat_points";
    private final int _ticketId;
    private final Location _returnLoc;
    private final Boat _boat;
    private final Location[] _broadcastPoints;

    public BoatWayEvent(MultiValueSet<String> set) {
        super(set);
        this._ticketId = set.getInteger("ticketId", 0);
        this._returnLoc = Location.parseLoc(set.getString("return_point"));
        String className = set.getString("class", null);
        if (className != null) {
            this._boat = BoatHolder.getInstance().initBoat(this.getName(), className);
            Location loc = Location.parseLoc(set.getString("spawn_point"));
            this._boat.setLoc(loc, true);
            this._boat.setHeading(loc.h);
        } else {
            this._boat = BoatHolder.getInstance().getBoat(this.getName());
        }
        this._boat.setWay(className != null ? 1 : 0, this);
        String brPoints = set.getString("broadcast_point", null);
        if (brPoints == null) {
            this._broadcastPoints = new Location[1];
            this._broadcastPoints[0] = this._boat.getLoc();
        } else {
            String[] points = brPoints.split(";");
            this._broadcastPoints = new Location[points.length];
            for (int i = 0; i < points.length; ++i) {
                this._broadcastPoints[i] = Location.parseLoc(points[i]);
            }
        }
    }

    @Override
    public void initEvent() {
    }

    @Override
    public void startEvent() {
        L2GameServerPacket startPacket = this._boat.startPacket();
        for (Player player : this._boat.getPlayers()) {
            if (this._ticketId > 0) {
                if (player.consumeItem(this._ticketId, 1L, true)) {
                    if (startPacket == null) continue;
                    player.sendPacket((IBroadcastPacket)startPacket);
                    continue;
                }
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_POSSESS_THE_CORRECT_TICKET_TO_BOARD_THE_BOAT);
                this._boat.oustPlayer(player, this._returnLoc, true);
                continue;
            }
            if (startPacket == null) continue;
            player.sendPacket((IBroadcastPacket)startPacket);
        }
        this.moveNext();
    }

    public void moveNext() {
        List points = this.getObjects(BOAT_POINTS);
        if (this._boat.getRunState() >= points.size()) {
            this._boat.trajetEnded(true);
            this.clearActions();
            return;
        }
        BoatPoint bp = (BoatPoint)points.get(this._boat.getRunState());
        if (bp.getSpeed1() >= 0) {
            this._boat.setMoveSpeed(bp.getSpeed1());
        }
        if (bp.getSpeed2() >= 0) {
            this._boat.setRotationSpeed(bp.getSpeed2());
        }
        if (this._boat.getRunState() == 0) {
            this._boat.broadcastCharInfo();
        }
        this._boat.setRunState(this._boat.getRunState() + 1);
        if (bp.isTeleport()) {
            this._boat.teleportShip(bp.getX(), bp.getY(), bp.getZ());
        } else {
            this._boat.getMovement().moveToLocation(bp.getX(), bp.getY(), bp.getZ(), 0, false);
        }
    }

    @Override
    public void reCalcNextTime(boolean onInit) {
        this.registerActions();
    }

    @Override
    public EventType getType() {
        return EventType.BOAT_EVENT;
    }

    @Override
    protected long startTimeMillis() {
        return System.currentTimeMillis();
    }

    @Override
    public List<Player> broadcastPlayers(int range) {
        LazyArrayList players = new LazyArrayList(64);
        if (range > 0) {
            for (Location loc : this._broadcastPoints) {
                for (Player player : GameObjectsStorage.getPlayers(false, false)) {
                    if (!player.getReflection().isMain() || !player.isInRangeZ(loc, range) || players.contains(player)) continue;
                    players.add(player);
                }
            }
        } else {
            for (Location loc : this._broadcastPoints) {
                int rx = MapUtils.regionX(loc.getX());
                int ry = MapUtils.regionY(loc.getY());
                for (Player player : GameObjectsStorage.getPlayers(false, false)) {
                    int ty;
                    int tx;
                    if (!player.getReflection().isMain() || (tx = MapUtils.regionX(player) - rx) * tx + (ty = MapUtils.regionY(player) - ry) * ty > Config.SHOUT_SQUARE_OFFSET || players.contains(player)) continue;
                    players.add(player);
                }
            }
        }
        return players;
    }

    @Override
    public void printInfo() {
    }

    public Location getReturnLoc() {
        return this._returnLoc;
    }
}

