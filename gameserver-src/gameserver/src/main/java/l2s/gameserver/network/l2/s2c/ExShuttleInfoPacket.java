/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.entity.boat.Shuttle;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.ShuttleTemplate;

public class ExShuttleInfoPacket
extends L2GameServerPacket {
    private final Shuttle _shuttle;
    private final Collection<ShuttleTemplate.ShuttleStop> _stops;

    public ExShuttleInfoPacket(Shuttle shuttle) {
        this._shuttle = shuttle;
        this._stops = shuttle.getTemplate().getStops();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._shuttle.getBoatId());
        this.writeD(this._shuttle.getX());
        this.writeD(this._shuttle.getY());
        this.writeD(this._shuttle.getZ());
        this.writeD(this._shuttle.getHeading());
        this.writeD(this._shuttle.getBoatId());
        this.writeD(this._stops.size());
        for (ShuttleTemplate.ShuttleStop stop : this._stops) {
            int stopId = stop.getId();
            this.writeD(stopId);
            for (Location loc : stop.getDimensions()) {
                this.writeD(loc.getX());
                this.writeD(loc.getY());
                this.writeD(loc.getZ());
            }
            if (this._shuttle.getCurrentWayEvent().containsStop(stopId)) {
                this.writeD(this._shuttle.isDocked());
                this.writeD(true);
                continue;
            }
            this.writeD(false);
            this.writeD(false);
        }
    }
}

