/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.clansearch;

import l2s.gameserver.model.clansearch.base.ClanSearchPlayerRoleType;
import l2s.gameserver.model.clansearch.base.ClanSearchPlayerSortType;
import l2s.gameserver.model.clansearch.base.ClanSearchSortOrder;

public class ClanSearchWaiterParams {
    private final int _minLevel;
    private final int _maxLevel;
    private final ClanSearchPlayerRoleType _role;
    private final String _charName;
    private final ClanSearchPlayerSortType _sortType;
    private final ClanSearchSortOrder _sortOrder;

    public ClanSearchWaiterParams(int minLevel, int maxLevel, ClanSearchPlayerRoleType role, String charName, ClanSearchPlayerSortType sortType, ClanSearchSortOrder sortOrder) {
        this._minLevel = minLevel;
        this._maxLevel = maxLevel;
        this._role = role;
        this._charName = charName;
        this._sortType = sortType;
        this._sortOrder = sortOrder;
    }

    public int getMinLevel() {
        return this._minLevel;
    }

    public int getMaxLevel() {
        return this._maxLevel;
    }

    public ClanSearchPlayerRoleType getRole() {
        return this._role;
    }

    public String getCharName() {
        return this._charName;
    }

    public ClanSearchPlayerSortType getSortType() {
        return this._sortType;
    }

    public ClanSearchSortOrder getSortOrder() {
        return this._sortOrder;
    }
}

