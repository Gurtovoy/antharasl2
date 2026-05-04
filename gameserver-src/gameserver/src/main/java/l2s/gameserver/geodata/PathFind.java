package l2s.gameserver.geodata;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geodata.PathFindBuffers;
import l2s.gameserver.geometry.Location;

public class PathFind {
    public static final int BOOST_NONE = 0;
    public static final int BOOST_START = 1;
    public static final int BOOST_BOTH = 2;
    private final int geoIndex;
    private final PathFindBuffers.PathFindBuffer buff;
    private final short[] hNSWE = new short[2];
    private final Location startPoint;
    private final Location endPoint;
    private PathFindBuffers.GeoNode startNode;
    private PathFindBuffers.GeoNode endNode;
    private PathFindBuffers.GeoNode currentNode;

    public static List<Location> findPath(int x, int y, int z, Location target, boolean isPlayable, int geoIndex) {
        return PathFind.findPath(x, y, z, target.x, target.y, target.z, isPlayable, geoIndex);
    }

    public static final List<Location> findPath(int x, int y, int z, int destX, int destY, int destZ, boolean isPlayable, int geoIndex) {
        Location endPoint;
        Location startPoint;
        if (Math.abs(z - destZ) > (isPlayable ? Config.NPC_PATH_FIND_MAX_HEIGHT : Config.PLAYABLE_PATH_FIND_MAX_HEIGHT)) {
            return null;
        }
        z = GeoEngine.getLowerHeight(x, y, z, geoIndex);
        destZ = GeoEngine.getLowerHeight(destX, destY, destZ, geoIndex);
        Location location = startPoint = Config.PATHFIND_BOOST == 0 ? new Location(x, y, z) : GeoEngine.moveCheckWithCollision(x, y, z, destX, destY, true, geoIndex);
        if (startPoint == null) {
            startPoint = new Location(x, y, z);
        }
        Location location2 = endPoint = Config.PATHFIND_BOOST != 2 || Math.abs(destZ - z) > 200 ? new Location(destX, destY, destZ) : GeoEngine.moveCheckBackwardWithCollision(destX, destY, destZ, startPoint.x, startPoint.y, true, geoIndex);
        if (endPoint == null) {
            endPoint = new Location(destX, destY, destZ);
        }
        startPoint.world2geo();
        endPoint.world2geo();
        int xdiff = Math.abs(endPoint.x - startPoint.x);
        int ydiff = Math.abs(endPoint.y - startPoint.y);
        if (xdiff == 0 && ydiff == 0) {
            if (Math.abs(endPoint.z - startPoint.z) < Config.PATHFIND_MAX_Z_DIFF) {
                ArrayList<Location> path = new ArrayList<Location>(2);
                path.add(new Location(x, y, z));
                path.add(new Location(destX, destY, destZ));
                return path;
            }
            return null;
        }
        List<Location> path = null;
        int mapSize = Config.PATHFIND_MAP_MUL * Math.max(xdiff, ydiff);
        PathFindBuffers.PathFindBuffer buff = PathFindBuffers.alloc(mapSize);
        if (buff != null) {
            buff.offsetX = startPoint.x - buff.mapSize / 2;
            buff.offsetY = startPoint.y - buff.mapSize / 2;
            ++buff.totalUses;
            if (isPlayable) {
                ++buff.playableUses;
            }
            PathFind n = new PathFind(startPoint, endPoint, buff, geoIndex);
            path = n.findPath();
            buff.free();
            PathFindBuffers.recycle(buff);
        }
        if (path == null || path.isEmpty()) {
            return null;
        }
        ArrayList<Location> targetRecorder = new ArrayList<Location>(path.size() + 2);
        targetRecorder.add(new Location(x, y, z));
        for (Location p : path) {
            targetRecorder.add(p.geo2world());
        }
        targetRecorder.add(new Location(destX, destY, destZ));
        if (Config.PATH_CLEAN) {
            PathFind.pathClean(targetRecorder, geoIndex);
        }
        return targetRecorder;
    }

    private static void pathClean(List<Location> path, int geoIndex) {
        int size = path.size();
        if (size > 2) {
            for (int i = 2; i < size; ++i) {
                Location p3 = path.get(i);
                Location p2 = path.get(i - 1);
                Location p1 = path.get(i - 2);
                if (!p1.equals(p2) && !p3.equals(p2) && !PathFind.IsPointInLine(p1, p2, p3)) continue;
                path.remove(i - 1);
                --size;
                i = Math.max(2, i - 2);
            }
        }
        for (int current = 0; current < path.size() - 2; ++current) {
            Location one = path.get(current);
            for (int sub = current + 2; sub < path.size(); ++sub) {
                Location two = path.get(sub);
                if (!one.equals(two) && !GeoEngine.canMoveWithCollision(one.x, one.y, one.z, two.x, two.y, two.z, geoIndex)) continue;
                while (current + 1 < sub) {
                    path.remove(current + 1);
                    --sub;
                }
            }
        }
    }

    private static boolean IsPointInLine(Location p1, Location p2, Location p3) {
        if (p1.x == p3.x && p3.x == p2.x || p1.y == p3.y && p3.y == p2.y) {
            return true;
        }
        return (p1.x - p2.x) * (p1.y - p2.y) == (p2.x - p3.x) * (p2.y - p3.y);
    }

    public PathFind(Location startPoint, Location endPoint, PathFindBuffers.PathFindBuffer buff, int geoIndex) {
        this.geoIndex = geoIndex;
        this.startPoint = startPoint;
        this.endPoint = endPoint;
        this.buff = buff;
    }

    private List<Location> findPath() {
        this.startNode = this.buff.nodes[this.startPoint.x - this.buff.offsetX][this.startPoint.y - this.buff.offsetY].set(this.startPoint.x, this.startPoint.y, (short)this.startPoint.z);
        GeoEngine.NgetLowerHeightAndNSWE(this.startPoint.x, this.startPoint.y, (short)this.startPoint.z, this.hNSWE, this.geoIndex);
        this.startNode.z = this.hNSWE[0];
        this.startNode.nswe = this.hNSWE[1];
        this.startNode.costFromStart = 0.0f;
        this.startNode.state = 1;
        this.startNode.parent = null;
        this.endNode = this.buff.nodes[this.endPoint.x - this.buff.offsetX][this.endPoint.y - this.buff.offsetY].set(this.endPoint.x, this.endPoint.y, (short)this.endPoint.z);
        this.startNode.costToEnd = this.pathCostEstimate(this.startNode);
        this.startNode.totalCost = this.startNode.costFromStart + this.startNode.costToEnd;
        this.buff.open.add(this.startNode);
        long nanos = System.nanoTime();
        long searhTime = 0L;
        int itr = 0;
        List<Location> path = null;
        while ((searhTime = System.nanoTime() - nanos) < Config.PATHFIND_MAX_TIME && (this.currentNode = this.buff.open.poll()) != null) {
            ++itr;
            if (this.currentNode.x == this.endPoint.x && this.currentNode.y == this.endPoint.y && Math.abs(this.currentNode.z - this.endPoint.z) < Config.MAX_Z_DIFF) {
                path = this.tracePath(this.currentNode);
                break;
            }
            this.handleNode(this.currentNode);
            this.currentNode.state = -1;
        }
        this.buff.totalTime += searhTime;
        this.buff.totalItr += (long)itr;
        if (path != null) {
            ++this.buff.successUses;
        } else if (searhTime > Config.PATHFIND_MAX_TIME) {
            ++this.buff.overtimeUses;
        }
        return path;
    }

    private List<Location> tracePath(PathFindBuffers.GeoNode f) {
        LinkedList<Location> locations = new LinkedList<Location>();
        do {
            locations.addFirst(f.getLoc());
            f = f.parent;
        } while (f.parent != null);
        return locations;
    }

    private void handleNode(PathFindBuffers.GeoNode node) {
        int clX = node.x;
        int clY = node.y;
        short clZ = node.z;
        this.getHeightAndNSWE(clX, clY, clZ);
        short NSWE = this.hNSWE[1];
        if (Config.PATHFIND_DIAGONAL) {
            if ((NSWE & 4) == 4 && (NSWE & 1) == 1) {
                this.getHeightAndNSWE(clX + 1, clY, clZ);
                if ((this.hNSWE[1] & 4) == 4) {
                    this.getHeightAndNSWE(clX, clY + 1, clZ);
                    if ((this.hNSWE[1] & 1) == 1) {
                        this.handleNeighbour(clX + 1, clY + 1, node, true);
                    }
                }
            }
            if ((NSWE & 4) == 4 && (NSWE & 2) == 2) {
                this.getHeightAndNSWE(clX - 1, clY, clZ);
                if ((this.hNSWE[1] & 4) == 4) {
                    this.getHeightAndNSWE(clX, clY + 1, clZ);
                    if ((this.hNSWE[1] & 2) == 2) {
                        this.handleNeighbour(clX - 1, clY + 1, node, true);
                    }
                }
            }
            if ((NSWE & 8) == 8 && (NSWE & 1) == 1) {
                this.getHeightAndNSWE(clX + 1, clY, clZ);
                if ((this.hNSWE[1] & 8) == 8) {
                    this.getHeightAndNSWE(clX, clY - 1, clZ);
                    if ((this.hNSWE[1] & 1) == 1) {
                        this.handleNeighbour(clX + 1, clY - 1, node, true);
                    }
                }
            }
            if ((NSWE & 8) == 8 && (NSWE & 2) == 2) {
                this.getHeightAndNSWE(clX - 1, clY, clZ);
                if ((this.hNSWE[1] & 8) == 8) {
                    this.getHeightAndNSWE(clX, clY - 1, clZ);
                    if ((this.hNSWE[1] & 2) == 2) {
                        this.handleNeighbour(clX - 1, clY - 1, node, true);
                    }
                }
            }
        }
        if ((NSWE & 1) == 1) {
            this.handleNeighbour(clX + 1, clY, node, false);
        }
        if ((NSWE & 2) == 2) {
            this.handleNeighbour(clX - 1, clY, node, false);
        }
        if ((NSWE & 4) == 4) {
            this.handleNeighbour(clX, clY + 1, node, false);
        }
        if ((NSWE & 8) == 8) {
            this.handleNeighbour(clX, clY - 1, node, false);
        }
    }

    private float pathCostEstimate(PathFindBuffers.GeoNode n) {
        int diffx = this.endNode.x - n.x;
        int diffy = this.endNode.y - n.y;
        int diffz = this.endNode.z - n.z;
        return (float)Math.sqrt(diffx * diffx + diffy * diffy + diffz * diffz / 256);
    }

    private float traverseCost(PathFindBuffers.GeoNode from, PathFindBuffers.GeoNode n, boolean d) {
        if (n.nswe != 15 || Math.abs(n.z - from.z) > 16) {
            return (float) Config.TERRAIN_HIGH_WEIGHT;
        }
        this.getHeightAndNSWE(n.x + 1, n.y, n.z);
        if (this.hNSWE[1] != 15 || Math.abs(n.z - this.hNSWE[0]) > 16) {
            return (float) Config.TERRAIN_MEDIUM_WEIGHT;
        }
        this.getHeightAndNSWE(n.x - 1, n.y, n.z);
        if (this.hNSWE[1] != 15 || Math.abs(n.z - this.hNSWE[0]) > 16) {
            return (float) Config.TERRAIN_MEDIUM_WEIGHT;
        }
        this.getHeightAndNSWE(n.x, n.y + 1, n.z);
        if (this.hNSWE[1] != 15 || Math.abs(n.z - this.hNSWE[0]) > 16) {
            return (float) Config.TERRAIN_MEDIUM_WEIGHT;
        }
        this.getHeightAndNSWE(n.x, n.y - 1, n.z);
        if (this.hNSWE[1] != 15 || Math.abs(n.z - this.hNSWE[0]) > 16) {
            return (float) Config.TERRAIN_MEDIUM_WEIGHT;
        }
        return d ? (float) Config.DIAGONAL_WEIGHT : (float) Config.TERRAIN_LOW_WEIGHT;
    }

    private void handleNeighbour(int x, int y, PathFindBuffers.GeoNode from, boolean d) {
        int height;
        int nX = x - this.buff.offsetX;
        int nY = y - this.buff.offsetY;
        if (nX >= this.buff.mapSize || nX < 0 || nY >= this.buff.mapSize || nY < 0) {
            return;
        }
        PathFindBuffers.GeoNode n = this.buff.nodes[nX][nY];
        if (!n.isSet()) {
            n = n.set(x, y, from.z);
            GeoEngine.NgetLowerHeightAndNSWE(x, y, from.z, this.hNSWE, this.geoIndex);
            n.z = this.hNSWE[0];
            n.nswe = this.hNSWE[1];
        }
        if ((height = Math.abs(n.z - from.z)) > Config.PATHFIND_MAX_Z_DIFF || n.nswe == 0) {
            return;
        }
        float newCost = from.costFromStart + this.traverseCost(from, n, d);
        if ((n.state == 1 || n.state == -1) && n.costFromStart <= newCost) {
            return;
        }
        if (n.state == 0) {
            n.costToEnd = this.pathCostEstimate(n);
        }
        n.parent = from;
        n.costFromStart = newCost;
        n.totalCost = n.costFromStart + n.costToEnd;
        if (n.state == 1) {
            return;
        }
        n.state = 1;
        this.buff.open.add(n);
    }

    private void getHeightAndNSWE(int x, int y, short z) {
        int nX = x - this.buff.offsetX;
        int nY = y - this.buff.offsetY;
        if (nX >= this.buff.mapSize || nX < 0 || nY >= this.buff.mapSize || nY < 0) {
            this.hNSWE[1] = 0;
            return;
        }
        PathFindBuffers.GeoNode n = this.buff.nodes[nX][nY];
        if (!n.isSet()) {
            n = n.set(x, y, z);
            GeoEngine.NgetLowerHeightAndNSWE(x, y, z, this.hNSWE, this.geoIndex);
            n.z = this.hNSWE[0];
            n.nswe = this.hNSWE[1];
        } else {
            this.hNSWE[0] = n.z;
            this.hNSWE[1] = n.nswe;
        }
    }
}

