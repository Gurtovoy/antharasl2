/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.geometry;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import l2s.commons.util.Rnd;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.templates.spawn.SpawnRange;

public class LocationsList
implements SpawnRange,
Iterable<Location> {
    private final List<Location> _locations;

    public LocationsList(List<Location> locations) {
        this._locations = locations;
    }

    public LocationsList() {
        this(new ArrayList<Location>());
    }

    public List<Location> getLocations() {
        return this._locations;
    }

    public void addLocation(Location loc) {
        this._locations.add(loc);
    }

    @Override
    public Iterator<Location> iterator() {
        return this._locations.iterator();
    }

    @Override
    public Location getRandomLoc(int geoIndex, boolean fly) {
        if (this._locations.isEmpty()) {
            return null;
        }
        return ((Location)Rnd.get(this._locations)).getRandomLoc(geoIndex, fly);
    }
}

