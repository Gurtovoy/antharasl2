/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data;

import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.lang.reflect.Constructor;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.data.xml.holder.ShuttleTemplateHolder;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.model.entity.boat.Shuttle;
import l2s.gameserver.templates.CreatureTemplate;
import l2s.gameserver.templates.ShuttleTemplate;

public final class BoatHolder
extends AbstractHolder {
    public static final CreatureTemplate TEMPLATE = new CreatureTemplate(CreatureTemplate.getEmptyStatsSet());
    private static BoatHolder _instance = new BoatHolder();
    private final TIntObjectHashMap<Boat> _boats = new TIntObjectHashMap();

    public static BoatHolder getInstance() {
        return _instance;
    }

    public void spawnAll() {
        this.log();
        TIntObjectIterator iterator = this._boats.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            ((Boat)iterator.value()).spawnMe();
            this.info("Spawning: " + ((Boat)iterator.value()).getName());
        }
    }

    public Boat initBoat(String name, String clazz) {
        try {
            Class<?> cl = Class.forName("l2s.gameserver.model.entity.boat." + clazz);
            Constructor<?> constructor = cl.getConstructor(Integer.TYPE, CreatureTemplate.class);
            Boat boat = (Boat)constructor.newInstance(IdFactory.getInstance().getNextId(), TEMPLATE);
            boat.setName(name);
            this.addBoat(boat);
            return boat;
        }
        catch (Exception e) {
            this.error("Fail to init boat: " + clazz, e);
            return null;
        }
    }

    public Shuttle initShuttle(String name, int shuttleId) {
        try {
            ShuttleTemplate template = ShuttleTemplateHolder.getInstance().getTemplate(shuttleId);
            Shuttle shuttle = new Shuttle(IdFactory.getInstance().getNextId(), template);
            shuttle.setName(name);
            this.addBoat(shuttle);
            return shuttle;
        }
        catch (Exception e) {
            this.error("Fail to init shuttle id: " + shuttleId, e);
            return null;
        }
    }

    public Boat getBoat(String name) {
        TIntObjectIterator iterator = this._boats.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            if (!((Boat)iterator.value()).getName().equals(name)) continue;
            return (Boat)iterator.value();
        }
        return null;
    }

    public Boat getBoat(int boatId) {
        return (Boat)this._boats.get(boatId);
    }

    public void addBoat(Boat boat) {
        this._boats.put(boat.getBoatId(), boat);
    }

    public void removeBoat(Boat boat) {
        this._boats.remove(boat.getBoatId());
    }

    public int size() {
        return this._boats.size();
    }

    public void clear() {
        this._boats.clear();
    }
}

