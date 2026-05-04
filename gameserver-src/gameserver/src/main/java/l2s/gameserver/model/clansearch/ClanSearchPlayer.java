/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.clansearch;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.clansearch.base.ClanSearchListType;

public class ClanSearchPlayer {
    private final int _charId;
    private final int _prefferedClanId;
    private final ClanSearchListType _searchType;
    private final String _desc;
    private String _charName;
    private int _charLevel;
    private int _charClassId;

    public ClanSearchPlayer(int charId, String charName, int charLevel, int charClassId, int prefferedClanId, ClanSearchListType searchType, String desc) {
        this._charId = charId;
        this._prefferedClanId = prefferedClanId;
        this._searchType = searchType;
        this._desc = desc;
        this._charName = charName;
        this._charLevel = charLevel;
        this._charClassId = charClassId;
    }

    public ClanSearchPlayer(int charId, String charName, int charLevel, int charClassId, ClanSearchListType searchType) {
        this(charId, charName, charLevel, charClassId, -1, searchType, null);
    }

    public boolean isApplicant() {
        return this._prefferedClanId > 0;
    }

    public int getCharId() {
        return this._charId;
    }

    public int getPrefferedClanId() {
        return this._prefferedClanId;
    }

    public ClanSearchListType getSearchType() {
        return this._searchType;
    }

    public String getDesc() {
        return this._desc;
    }

    public String getName() {
        Player player = World.getPlayer(this._charId);
        if (player != null) {
            this._charName = player.getName();
        }
        return this._charName;
    }

    public int getLevel() {
        Player player = World.getPlayer(this._charId);
        if (player != null) {
            this._charLevel = player.getLevel();
        }
        return this._charLevel;
    }

    public int getClassId() {
        Player player = World.getPlayer(this._charId);
        if (player != null) {
            this._charClassId = player.getBaseClassId();
        }
        return this._charClassId;
    }
}

