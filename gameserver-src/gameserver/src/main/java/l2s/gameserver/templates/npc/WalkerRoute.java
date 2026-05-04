package l2s.gameserver.templates.npc;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.templates.npc.WalkerRoutePoint;
import l2s.gameserver.templates.npc.WalkerRouteType;

public class WalkerRoute {
    private final int _id;
    private final WalkerRouteType _type;
    private final List<WalkerRoutePoint> _points = new ArrayList<WalkerRoutePoint>();

    public WalkerRoute(int id, WalkerRouteType type) {
        this._id = id;
        this._type = type;
    }

    public int getId() {
        return this._id;
    }

    public WalkerRouteType getType() {
        return this._type;
    }

    public void addPoint(WalkerRoutePoint route) {
        this._points.add(route);
    }

    public WalkerRoutePoint getPoint(int id) {
        return this._points.get(id);
    }

    public int size() {
        return this._points.size();
    }

    public boolean isValid() {
        if (this._type == WalkerRouteType.DELETE || this._type == WalkerRouteType.FINISH) {
            return this.size() > 0;
        }
        return this.size() > 1;
    }
}

