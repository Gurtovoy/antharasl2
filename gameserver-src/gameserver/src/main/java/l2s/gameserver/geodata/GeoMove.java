/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.geodata;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geodata.PathFind;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExShowTracePacket;

public class GeoMove {
    public static List<List<Location>> findMovePath(int x, int y, int z, int destX, int destY, int destZ, Creature c, int geoIndex) {
        List<Location> path = PathFind.findPath(x, y, z, destX, destY, destZ, c != null && c.isPlayable(), geoIndex);
        if (path == null) {
            return Collections.emptyList();
        }
        if (c != null && c.isPlayer() && ((Player)c).getVarBoolean("trace")) {
            Player player = (Player)c;
            ExShowTracePacket trace = new ExShowTracePacket(30000);
            int i = 0;
            for (Location loc : path) {
                if (++i == 1 || i == path.size()) continue;
                trace.addTrace(loc.x, loc.y, loc.z + 15);
            }
            player.sendPacket((IBroadcastPacket)trace);
        }
        return GeoMove.getNodePath(path, geoIndex);
    }

    private static List<List<Location>> getNodePath(List<Location> path, int geoIndex) {
        int size = path.size();
        if (size <= 1) {
            return Collections.emptyList();
        }
        ArrayList<List<Location>> result = new ArrayList<List<Location>>(size);
        for (int i = 1; i < size; ++i) {
            Location p2 = path.get(i);
            Location p1 = path.get(i - 1);
            List<Location> moveList = GeoEngine.MoveList(p1.x, p1.y, p1.z, p2.x, p2.y, geoIndex, true);
            if (moveList == null) {
                return Collections.emptyList();
            }
            if (moveList.isEmpty()) continue;
            result.add(moveList);
        }
        return result;
    }

    public static List<Location> constructMoveList(Location begin, Location end) {
        begin.world2geo();
        end.world2geo();
        int diff_x = end.x - begin.x;
        int diff_y = end.y - begin.y;
        int diff_z = end.z - begin.z;
        int dx = Math.abs(diff_x);
        int dy = Math.abs(diff_y);
        int dz = Math.abs(diff_z);
        float steps = Math.max(Math.max(dx, dy), dz);
        if (steps == 0.0f) {
            return Collections.emptyList();
        }
        float step_x = (float)diff_x / steps;
        float step_y = (float)diff_y / steps;
        float step_z = (float)diff_z / steps;
        float next_x = begin.x;
        float next_y = begin.y;
        float next_z = begin.z;
        ArrayList<Location> result = new ArrayList<Location>((int)steps + 1);
        result.add(new Location(begin.x, begin.y, begin.z));
        int i = 0;
        while ((float)i < steps) {
            result.add(new Location((int)((next_x += step_x) + 0.5f), (int)((next_y += step_y) + 0.5f), (int)((next_z += step_z) + 0.5f)));
            ++i;
        }
        return result;
    }
}

