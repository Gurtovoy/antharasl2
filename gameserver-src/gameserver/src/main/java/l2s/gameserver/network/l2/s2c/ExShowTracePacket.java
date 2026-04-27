/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowTracePacket
extends L2GameServerPacket {
    private final List<Trace> _traces = new ArrayList<Trace>();
    private final int _time;

    public ExShowTracePacket(int time) {
        this._time = time;
    }

    public ExShowTracePacket addTrace(int x, int y, int z) {
        this._traces.add(new Trace(x, y, z));
        return this;
    }

    public ExShowTracePacket addLine(Location from, Location to, int step) {
        this.addLine(from.x, from.y, from.z, to.x, to.y, to.z, step);
        return this;
    }

    public ExShowTracePacket addLine(int from_x, int from_y, int from_z, int to_x, int to_y, int to_z, int step) {
        int x_diff = to_x - from_x;
        int y_diff = to_y - from_y;
        int z_diff = to_z - from_z;
        double xy_dist = Math.sqrt(x_diff * x_diff + y_diff * y_diff);
        double full_dist = Math.sqrt(xy_dist * xy_dist + (double)(z_diff * z_diff));
        int steps = (int)(full_dist / (double)step);
        this.addTrace(from_x, from_y, from_z);
        if (steps > 1) {
            int step_x = x_diff / steps;
            int step_y = y_diff / steps;
            int step_z = z_diff / steps;
            for (int i = 1; i < steps; ++i) {
                this.addTrace(from_x + step_x * i, from_y + step_y * i, from_z + step_z * i);
            }
        }
        this.addTrace(to_x, to_y, to_z);
        return this;
    }

    public ExShowTracePacket addTrace(GameObject obj) {
        this.addTrace(obj.getX(), obj.getY(), obj.getZ());
        return this;
    }

    @Override
    protected final void writeImpl() {
        this.writeH(0);
        this.writeD(0);
        this.writeH(this._traces.size());
        for (Trace t : this._traces) {
            this.writeD(t._x);
            this.writeD(t._y);
            this.writeD(t._z);
        }
    }

    static final class Trace {
        public final int _x;
        public final int _y;
        public final int _z;

        public Trace(int x, int y, int z) {
            this._x = x;
            this._y = y;
            this._z = z;
        }
    }
}

