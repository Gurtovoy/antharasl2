/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.iterator.TIntIntIterator
 *  gnu.trove.map.hash.TIntIntHashMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  l2s.commons.lang.ArrayUtils
 *  l2s.commons.text.StrTable
 *  org.apache.commons.lang3.ArrayUtils
 */
package l2s.gameserver.geodata;

import gnu.trove.iterator.TIntIntIterator;
import gnu.trove.map.hash.TIntIntHashMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Arrays;
import java.util.PriorityQueue;
import java.util.Queue;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import l2s.commons.text.StrTable;
import l2s.gameserver.Config;
import l2s.gameserver.geometry.Location;
import org.apache.commons.lang3.ArrayUtils;

public class PathFindBuffers {
    public static final int MIN_MAP_SIZE = 64;
    public static final int STEP_MAP_SIZE = 32;
    public static final int MAX_MAP_SIZE = 512;
    private static TIntObjectHashMap<PathFindBuffer[]> buffers = new TIntObjectHashMap();
    private static int[] sizes = new int[0];
    private static Lock lock = new ReentrantLock();

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static PathFindBuffer create(int mapSize) {
        lock.lock();
        try {
            PathFindBuffer buffer;
            PathFindBuffer[] buff = (PathFindBuffer[])buffers.get(mapSize);
            if (buff != null) {
                buffer = new PathFindBuffer(mapSize);
                buff = (PathFindBuffer[])l2s.commons.lang.ArrayUtils.add((Object[])buff, (Object)buffer);
            } else {
                buffer = new PathFindBuffer(mapSize);
                buff = new PathFindBuffer[]{buffer};
                sizes = ArrayUtils.add((int[])sizes, (int)mapSize);
                Arrays.sort(sizes);
            }
            buffers.put(mapSize, buff);
            buffer.inUse = true;
            PathFindBuffer pathFindBuffer = buffer;
            return pathFindBuffer;
        }
        finally {
            lock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static PathFindBuffer get(int mapSize) {
        lock.lock();
        try {
            PathFindBuffer[] buff;
            for (PathFindBuffer buffer : buff = (PathFindBuffer[])buffers.get(mapSize)) {
                if (buffer.inUse) continue;
                buffer.inUse = true;
                PathFindBuffer pathFindBuffer = buffer;
                return pathFindBuffer;
            }
            PathFindBuffer pathFindBufferArray = null;
            return pathFindBufferArray;
        }
        finally {
            lock.unlock();
        }
    }

    public static PathFindBuffer alloc(int mapSize) {
        if (mapSize > 512) {
            return null;
        }
        if ((mapSize += 32) < 64) {
            mapSize = 64;
        }
        PathFindBuffer buffer = null;
        for (int i = 0; i < sizes.length; ++i) {
            if (sizes[i] < mapSize) continue;
            mapSize = sizes[i];
            buffer = PathFindBuffers.get(mapSize);
            break;
        }
        if (buffer == null) {
            for (int size = 64; size < 512; size += 32) {
                if (size < mapSize) continue;
                mapSize = size;
                buffer = PathFindBuffers.create(mapSize);
                break;
            }
        }
        return buffer;
    }

    public static void recycle(PathFindBuffer buffer) {
        lock.lock();
        try {
            buffer.inUse = false;
        }
        finally {
            lock.unlock();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static StrTable getStats() {
        StrTable table = new StrTable("PathFind Buffers Stats");
        lock.lock();
        try {
            long totalUses = 0L;
            long totalPlayable = 0L;
            long totalTime = 0L;
            int index = 0;
            for (int size : sizes) {
                ++index;
                int count = 0;
                long uses = 0L;
                long playable = 0L;
                long itrs = 0L;
                long success = 0L;
                long overtime = 0L;
                long time = 0L;
                for (PathFindBuffer buff : (PathFindBuffer[])buffers.get(size)) {
                    ++count;
                    uses += buff.totalUses;
                    playable += buff.playableUses;
                    success += buff.successUses;
                    overtime += buff.overtimeUses;
                    time += buff.totalTime / 1000000L;
                    itrs += buff.totalItr;
                }
                totalUses += uses;
                totalPlayable += playable;
                totalTime += time;
                table.set(index, "Size", size);
                table.set(index, "Count", count);
                table.set(index, "Uses (success%)", uses + "(" + String.format("%2.2f", uses > 0L ? (double)success * 100.0 / (double)uses : 0.0) + "%)");
                table.set(index, "Uses, playble", playable + "(" + String.format("%2.2f", uses > 0L ? (double)playable * 100.0 / (double)uses : 0.0) + "%)");
                table.set(index, "Uses, overtime", overtime + "(" + String.format("%2.2f", uses > 0L ? (double)overtime * 100.0 / (double)uses : 0.0) + "%)");
                table.set(index, "Iter., avg", uses > 0L ? itrs / uses : 0L);
                table.set(index, "Time, avg (ms)", String.format("%1.3f", uses > 0L ? (double)time / (double)uses : 0.0));
            }
            table.addTitle("Uses, total / playable  : " + totalUses + " / " + totalPlayable);
            table.addTitle("Uses, total time / avg (ms) : " + totalTime + " / " + String.format("%1.3f", totalUses > 0L ? (double)totalTime / (double)totalUses : 0.0));
        }
        finally {
            lock.unlock();
        }
        return table;
    }

    static {
        TIntIntHashMap config = new TIntIntHashMap();
        for (String e : Config.PATHFIND_BUFFERS.split(";")) {
            String[] k;
            if (e.isEmpty() || (k = e.split("x")).length != 2) continue;
            config.put(Integer.valueOf(k[1]).intValue(), Integer.valueOf(k[0]).intValue());
        }
        TIntIntIterator itr = config.iterator();
        while (itr.hasNext()) {
            itr.advance();
            int size = itr.key();
            int count = itr.value();
            PathFindBuffer[] buff = new PathFindBuffer[count];
            for (int i = 0; i < count; ++i) {
                buff[i] = new PathFindBuffer(size);
            }
            buffers.put(size, buff);
        }
        sizes = config.keys();
        Arrays.sort(sizes);
    }

    public static class GeoNode
    implements Comparable<GeoNode> {
        public static final int NONE = 0;
        public static final int OPENED = 1;
        public static final int CLOSED = -1;
        public int x;
        public int y;
        public short z;
        public short nswe = (short)-1;
        public float totalCost;
        public float costFromStart;
        public float costToEnd;
        public int state;
        public GeoNode parent;

        public GeoNode set(int x, int y, short z) {
            this.x = x;
            this.y = y;
            this.z = z;
            return this;
        }

        public boolean isSet() {
            return this.nswe != -1;
        }

        public void free() {
            this.nswe = (short)-1;
            this.costFromStart = 0.0f;
            this.totalCost = 0.0f;
            this.costToEnd = 0.0f;
            this.parent = null;
            this.state = 0;
        }

        public Location getLoc() {
            return new Location(this.x, this.y, this.z);
        }

        public String toString() {
            return "[" + this.x + "," + this.y + "," + this.z + "] f: " + this.totalCost;
        }

        @Override
        public int compareTo(GeoNode o) {
            if (this.totalCost > o.totalCost) {
                return 1;
            }
            if (this.totalCost < o.totalCost) {
                return -1;
            }
            return 0;
        }
    }

    public static class PathFindBuffer {
        final int mapSize;
        final GeoNode[][] nodes;
        final Queue<GeoNode> open;
        int offsetX;
        int offsetY;
        boolean inUse;
        long totalUses;
        long successUses;
        long overtimeUses;
        long playableUses;
        long totalTime;
        long totalItr;

        public PathFindBuffer(int mapSize) {
            this.open = new PriorityQueue<GeoNode>(mapSize);
            this.mapSize = mapSize;
            this.nodes = new GeoNode[mapSize][mapSize];
            for (int i = 0; i < this.nodes.length; ++i) {
                for (int j = 0; j < this.nodes[i].length; ++j) {
                    this.nodes[i][j] = new GeoNode();
                }
            }
        }

        public void free() {
            this.open.clear();
            for (int i = 0; i < this.nodes.length; ++i) {
                for (int j = 0; j < this.nodes[i].length; ++j) {
                    this.nodes[i][j].free();
                }
            }
        }
    }
}

