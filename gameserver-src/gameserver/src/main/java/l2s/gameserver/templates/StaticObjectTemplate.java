package l2s.gameserver.templates;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.model.instances.ChairInstance;
import l2s.gameserver.model.instances.StaticObjectInstance;
import l2s.gameserver.templates.StatsSet;

public class StaticObjectTemplate {
    private final int _uid;
    private final int _type;
    private final String _filePath;
    private final int _mapX;
    private final int _mapY;
    private final String _name;
    private final int _x;
    private final int _y;
    private final int _z;
    private final boolean _spawn;

    public StaticObjectTemplate(StatsSet set) {
        this._uid = set.getInteger("uid");
        this._type = set.getInteger("stype");
        this._mapX = set.getInteger("map_x");
        this._mapY = set.getInteger("map_y");
        this._filePath = set.getString("path");
        this._name = set.getString("name");
        this._x = set.getInteger("x");
        this._y = set.getInteger("y");
        this._z = set.getInteger("z");
        this._spawn = set.getBool("spawn");
    }

    public int getUId() {
        return this._uid;
    }

    public int getType() {
        return this._type;
    }

    public String getFilePath() {
        return this._filePath;
    }

    public int getMapX() {
        return this._mapX;
    }

    public int getMapY() {
        return this._mapY;
    }

    public String getName() {
        return this._name;
    }

    public int getX() {
        return this._x;
    }

    public int getY() {
        return this._y;
    }

    public int getZ() {
        return this._z;
    }

    public boolean isSpawn() {
        return this._spawn;
    }

    public StaticObjectInstance newInstance() {
        StaticObjectInstance instance = this.getType() == 1 ? new ChairInstance(IdFactory.getInstance().getNextId(), this) : new StaticObjectInstance(IdFactory.getInstance().getNextId(), this);
        instance.spawnMe(new Location(this.getX(), this.getY(), this.getZ()));
        return instance;
    }
}

