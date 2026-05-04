/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.clansearch.ClanSearchWaiterParams;
import l2s.gameserver.model.clansearch.base.ClanSearchPlayerRoleType;
import l2s.gameserver.model.clansearch.base.ClanSearchPlayerSortType;
import l2s.gameserver.model.clansearch.base.ClanSearchSortOrder;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExPledgeDraftListSearch;

public class RequestPledgeDraftListSearch
extends L2GameClientPacket {
    private int _minLevel;
    private int _maxLevel;
    private ClanSearchPlayerRoleType _role;
    private String _charName;
    private ClanSearchPlayerSortType _sortType;
    private ClanSearchSortOrder _sortOrder;

    @Override
    protected boolean readImpl() {
        this._minLevel = Math.max(0, Math.min(this.readD(), 99));
        this._maxLevel = Math.max(0, Math.min(this.readD(), 99));
        this._role = ClanSearchPlayerRoleType.valueOf(this.readD());
        this._charName = this.readS().trim().toLowerCase();
        if (this._charName.length() > 255) {
            this._charName = this._charName.substring(0, 255);
        }
        this._sortType = ClanSearchPlayerSortType.valueOf(this.readD());
        this._sortOrder = ClanSearchSortOrder.valueOf(this.readD());
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExPledgeDraftListSearch(new ClanSearchWaiterParams(this._minLevel, this._maxLevel, this._role, this._charName, this._sortType, this._sortOrder)));
    }
}

