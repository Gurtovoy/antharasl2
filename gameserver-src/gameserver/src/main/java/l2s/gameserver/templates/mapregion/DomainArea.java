/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.mapregion;

import l2s.gameserver.geometry.Territory;
import l2s.gameserver.templates.mapregion.RegionData;

public class DomainArea
implements RegionData {
    private final int _id;
    private final Territory _territory;

    public DomainArea(int id, Territory territory) {
        this._id = id;
        this._territory = territory;
    }

    public int getId() {
        return this._id;
    }

    @Override
    public Territory getTerritory() {
        return this._territory;
    }
}

