package l2s.gameserver.templates.mapregion;

import java.util.List;
import l2s.gameserver.geometry.Location;

public class RestartPoint {
    private final String _name;
    private final int _bbs;
    private final int _msgId;
    private final List<Location> _restartPoints;
    private final List<Location> _PKrestartPoints;

    public RestartPoint(String name, int bbs, int msgId, List<Location> restartPoints, List<Location> PKrestartPoints) {
        this._name = name;
        this._bbs = bbs;
        this._msgId = msgId;
        this._restartPoints = restartPoints;
        this._PKrestartPoints = PKrestartPoints;
    }

    public String getName() {
        return this._name;
    }

    public int getBbs() {
        return this._bbs;
    }

    public int getMsgId() {
        return this._msgId;
    }

    public List<Location> getRestartPoints() {
        return this._restartPoints;
    }

    public List<Location> getPKrestartPoints() {
        return this._PKrestartPoints;
    }
}

