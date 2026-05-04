package l2s.gameserver.instancemanager;

import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.World;
import l2s.gameserver.templates.mapregion.RegionData;
import org.apache.commons.lang3.ArrayUtils;

public class MapRegionManager
extends AbstractHolder {
    private static final MapRegionManager _instance = new MapRegionManager();
    private RegionData[][][] map = new RegionData[World.WORLD_SIZE_X][World.WORLD_SIZE_Y][0];

    public static MapRegionManager getInstance() {
        return _instance;
    }

    private MapRegionManager() {
    }

    private int regionX(int x) {
        return x - World.MAP_MIN_X >> 15;
    }

    private int regionY(int y) {
        return y - World.MAP_MIN_Y >> 15;
    }

    public void addRegionData(RegionData rd) {
        for (int x = this.regionX(rd.getTerritory().getXmin()); x <= this.regionX(rd.getTerritory().getXmax()); ++x) {
            for (int y = this.regionY(rd.getTerritory().getYmin()); y <= this.regionY(rd.getTerritory().getYmax()); ++y) {
                this.map[x][y] = (RegionData[])ArrayUtils.add((Object[])this.map[x][y], (Object)rd);
            }
        }
    }

    public <T extends RegionData> T getRegionData(Class<T> clazz, GameObject o) {
        return this.getRegionData(clazz, o.getX(), o.getY(), o.getZ());
    }

    public <T extends RegionData> T getRegionData(Class<T> clazz, Location loc) {
        return this.getRegionData(clazz, loc.getX(), loc.getY(), loc.getZ());
    }

    public <T extends RegionData> T getRegionData(Class<T> clazz, int x, int y, int z) {
        for (RegionData rd : this.map[this.regionX(x)][this.regionY(y)]) {
            if (rd.getClass() != clazz || !rd.getTerritory().isInside(x, y, z)) continue;
            return (T)rd;
        }
        return null;
    }

    public int size() {
        return World.WORLD_SIZE_X * World.WORLD_SIZE_Y;
    }

    public void clear() {
    }
}

