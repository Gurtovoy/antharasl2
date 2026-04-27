/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.hash.TIntObjectHashMap
 */
package l2s.gameserver.model.entity.boat;

import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.model.entity.events.impl.ShuttleWayEvent;
import l2s.gameserver.network.l2.s2c.ExMTLInSuttlePacket;
import l2s.gameserver.network.l2.s2c.ExShuttleInfoPacket;
import l2s.gameserver.network.l2.s2c.ExStopMoveInShuttlePacket;
import l2s.gameserver.network.l2.s2c.ExSuttleGetOffPacket;
import l2s.gameserver.network.l2.s2c.ExSuttleGetOnPacket;
import l2s.gameserver.network.l2.s2c.ExSuttleMovePacket;
import l2s.gameserver.network.l2.s2c.ExValidateLocationInShuttlePacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.ShuttleTemplate;

public class Shuttle
extends Boat {
    private final TIntObjectHashMap<ShuttleWayEvent> _wayEvents = new TIntObjectHashMap();
    private boolean _moveBack;
    public int _currentWay;

    public Shuttle(int objectId, ShuttleTemplate template) {
        super(objectId, template);
    }

    @Override
    public int getBoatId() {
        return this.getTemplate().getId();
    }

    @Override
    public final ShuttleTemplate getTemplate() {
        return (ShuttleTemplate)super.getTemplate();
    }

    @Override
    public void onSpawn() {
        this._moveBack = false;
        this._currentWay = 0;
        this.getCurrentWayEvent().reCalcNextTime(false);
    }

    @Override
    public void onEvtArrived() {
        ThreadPoolManager.getInstance().schedule(new Docked(this), 1500L);
    }

    @Override
    public L2GameServerPacket infoPacket() {
        return new ExShuttleInfoPacket(this);
    }

    @Override
    public L2GameServerPacket movePacket() {
        return new ExSuttleMovePacket(this);
    }

    @Override
    public L2GameServerPacket inMovePacket(Player player, Location src, Location desc) {
        return new ExMTLInSuttlePacket(player, this, src, desc);
    }

    @Override
    public L2GameServerPacket stopMovePacket() {
        return null;
    }

    @Override
    public L2GameServerPacket inStopMovePacket(Player player) {
        return new ExStopMoveInShuttlePacket(player);
    }

    @Override
    public L2GameServerPacket startPacket() {
        return null;
    }

    @Override
    public L2GameServerPacket checkLocationPacket() {
        return null;
    }

    @Override
    public L2GameServerPacket validateLocationPacket(Player player) {
        return new ExValidateLocationInShuttlePacket(player);
    }

    @Override
    public L2GameServerPacket getOnPacket(Playable playable, Location location) {
        return new ExSuttleGetOnPacket(playable, this, location);
    }

    @Override
    public L2GameServerPacket getOffPacket(Playable playable, Location location) {
        return new ExSuttleGetOffPacket(playable, this, location);
    }

    @Override
    public boolean isShuttle() {
        return true;
    }

    @Override
    public void oustPlayers() {
    }

    @Override
    public void trajetEnded(boolean oust) {
    }

    @Override
    public void teleportShip(int x, int y, int z) {
    }

    @Override
    public Location getReturnLoc() {
        return this.getCurrentWayEvent().getReturnLoc();
    }

    @Override
    public void addPlayer(Player player, Location boatLoc) {
        if (this.getMovement().isMoving()) {
            player.teleToLocation(this.getReturnLoc());
            return;
        }
        super.addPlayer(player, boatLoc);
    }

    @Override
    public void oustPlayer(Player player, Location loc, boolean teleport) {
        if (this.getMovement().isMoving()) {
            player.teleToLocation(this.getReturnLoc());
            return;
        }
        super.oustPlayer(player, loc, teleport);
    }

    public void addWayEvent(ShuttleWayEvent wayEvent) {
        this._wayEvents.put(wayEvent.getId() % 100, wayEvent);
    }

    public ShuttleWayEvent getCurrentWayEvent() {
        return (ShuttleWayEvent)((Object)this._wayEvents.get(this._currentWay));
    }

    private ShuttleWayEvent getNextWayEvent() {
        int ways = this._wayEvents.size() - 1;
        if (!this._moveBack) {
            ++this._currentWay;
            if (this._currentWay > ways) {
                this._currentWay = ways - 1;
                this._moveBack = true;
            }
        } else {
            --this._currentWay;
            if (this._currentWay < 0) {
                this._currentWay = 1;
                this._moveBack = false;
            }
        }
        return (ShuttleWayEvent)((Object)this._wayEvents.get(this._currentWay));
    }

    private static class Docked
    implements Runnable {
        private Shuttle _shuttle;

        public Docked(Shuttle shuttle) {
            this._shuttle = shuttle;
        }

        @Override
        public void run() {
            if (this._shuttle == null) {
                return;
            }
            this._shuttle.getCurrentWayEvent().stopEvent(false);
            this._shuttle.getNextWayEvent().reCalcNextTime(false);
        }
    }
}

