/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.mapregion;

import java.util.Map;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.templates.mapregion.RegionData;
import l2s.gameserver.templates.mapregion.RestartPoint;

public class RestartArea
implements RegionData {
    private final Territory _territory;
    private final Map<Race, RestartPoint> _restarts;

    public RestartArea(Territory territory, Map<Race, RestartPoint> restarts) {
        this._territory = territory;
        this._restarts = restarts;
    }

    @Override
    public Territory getTerritory() {
        return this._territory;
    }

    public Map<Race, RestartPoint> getRestartPoint() {
        return this._restarts;
    }
}

