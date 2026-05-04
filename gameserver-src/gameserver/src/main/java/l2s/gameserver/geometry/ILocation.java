package l2s.gameserver.geometry;

public interface ILocation {
    public int getX();

    public int getY();

    public int getZ();

    public int getHeading();

    default public long getXYDeltaSq(int x, int y) {
        long dx = x - this.getX();
        long dy = y - this.getY();
        return dx * dx + dy * dy;
    }

    default public long getXYDeltaSq(ILocation loc) {
        return this.getXYDeltaSq(loc.getX(), loc.getY());
    }

    default public long getZDeltaSq(int z) {
        long dz = z - this.getZ();
        return dz * dz;
    }

    default public long getZDeltaSq(ILocation loc) {
        return this.getZDeltaSq(loc.getZ());
    }

    default public long getXYZDeltaSq(int x, int y, int z) {
        return this.getXYDeltaSq(x, y) + this.getZDeltaSq(z);
    }

    default public long getXYZDeltaSq(ILocation loc) {
        return this.getXYZDeltaSq(loc.getX(), loc.getY(), loc.getZ());
    }

    default public int getDistance(int x, int y) {
        return (int)Math.sqrt(this.getXYDeltaSq(x, y));
    }

    default public int getDistance(int x, int y, int z) {
        return (int)Math.sqrt(this.getXYZDeltaSq(x, y, z));
    }

    default public int getDistance(ILocation loc) {
        return this.getDistance(loc.getX(), loc.getY());
    }

    default public int getDistance3D(ILocation loc) {
        return this.getDistance(loc.getX(), loc.getY(), loc.getZ());
    }

    default public boolean isInRangeSq(ILocation loc, long range) {
        return this.getXYDeltaSq(loc) <= range;
    }

    default public boolean isInRange(ILocation loc, int range) {
        return this.isInRangeSq(loc, (long)range * (long)range);
    }

    default public boolean isInRangeZ(ILocation loc, int range) {
        return this.isInRangeZSq(loc, (long)range * (long)range);
    }

    default public boolean isInRangeZSq(ILocation loc, long range) {
        return this.getXYZDeltaSq(loc) <= range;
    }

    default public long getSqDistance(int x, int y) {
        return this.getXYDeltaSq(x, y);
    }

    default public long getSqDistance(ILocation loc) {
        return this.getXYDeltaSq(loc);
    }
}

