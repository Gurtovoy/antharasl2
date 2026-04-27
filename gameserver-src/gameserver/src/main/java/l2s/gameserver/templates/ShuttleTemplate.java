/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.TreeMap;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.templates.CreatureTemplate;

public final class ShuttleTemplate
extends CreatureTemplate {
    private final int _id;
    private final TreeMap<Integer, ShuttleStop> _stops = new TreeMap();

    public ShuttleTemplate(int id) {
        super(CreatureTemplate.getEmptyStatsSet());
        this._id = id;
    }

    @Override
    public int getId() {
        return this._id;
    }

    public Collection<ShuttleStop> getStops() {
        return this._stops.values();
    }

    public ShuttleStop getStop(int id) {
        return this._stops.get(id);
    }

    public void addStop(ShuttleStop door) {
        this._stops.put(door.getId(), door);
    }

    public static class ShuttleStop {
        private final int _id;
        private final List<Location> _dimensions = new ArrayList<Location>();

        public ShuttleStop(int id) {
            this._id = id;
        }

        public int getId() {
            return this._id;
        }

        public List<Location> getDimensions() {
            return this._dimensions;
        }
    }
}

