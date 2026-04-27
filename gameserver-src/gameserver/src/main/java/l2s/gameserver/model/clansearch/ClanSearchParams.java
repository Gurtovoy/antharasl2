/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.clansearch;

import l2s.gameserver.model.clansearch.base.ClanSearchClanSortType;
import l2s.gameserver.model.clansearch.base.ClanSearchListType;
import l2s.gameserver.model.clansearch.base.ClanSearchSortOrder;
import l2s.gameserver.model.clansearch.base.ClanSearchTargetType;

public class ClanSearchParams {
    private final int _clanLevel;
    private final ClanSearchListType _listType;
    private final ClanSearchTargetType _targetType;
    private final String _targetName;
    private final ClanSearchClanSortType _sortType;
    private final ClanSearchSortOrder _sortOrder;
    private final int _currentPage;
    private final int _application;

    public ClanSearchParams(int clanLevel, ClanSearchListType searchListType, ClanSearchTargetType targetType, String targetName, ClanSearchClanSortType sortType, ClanSearchSortOrder sortOrder, int currentPage, int application) {
        this._clanLevel = clanLevel;
        this._listType = searchListType;
        this._targetType = targetType;
        this._targetName = targetName;
        this._sortType = sortType;
        this._sortOrder = sortOrder;
        this._currentPage = Math.max(0, currentPage - 1);
        this._application = application;
    }

    public int getClanLevel() {
        return this._clanLevel;
    }

    public ClanSearchListType getSearchType() {
        return this._listType;
    }

    public ClanSearchTargetType getTargetType() {
        return this._targetType;
    }

    public String getName() {
        return this._targetName;
    }

    public ClanSearchClanSortType getSortType() {
        return this._sortType;
    }

    public ClanSearchSortOrder getSortOrder() {
        return this._sortOrder;
    }

    public int getCurrentPage() {
        return this._currentPage;
    }

    public int getApplication() {
        return this._application;
    }
}

