/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.clansearch;

import l2s.gameserver.model.clansearch.base.ClanSearchListType;

public class ClanSearchClan {
    private int _clanId;
    private int _application;
    private int _subUnit;
    private ClanSearchListType _searchType;
    private String _desc;

    public ClanSearchClan(int clanId, ClanSearchListType searchType, String desc, int application, int subUnit) {
        this._clanId = clanId;
        this._searchType = searchType;
        this._desc = desc;
        this._application = application;
        this._subUnit = subUnit;
    }

    public int getClanId() {
        return this._clanId;
    }

    public ClanSearchListType getSearchType() {
        return this._searchType;
    }

    public void setSearchType(ClanSearchListType searchType) {
        this._searchType = searchType;
    }

    public String getDesc() {
        return this._desc;
    }

    public void setDesc(String desc) {
        this._desc = desc;
    }

    public int getApplication() {
        return this._application;
    }

    public void setApplication(int value) {
        this._application = value;
    }

    public int getSubUnit() {
        return this._subUnit;
    }

    public void setSubUnit(int value) {
        this._subUnit = value;
    }
}

