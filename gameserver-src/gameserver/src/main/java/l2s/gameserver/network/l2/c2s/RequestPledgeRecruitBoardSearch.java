package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.clansearch.ClanSearchParams;
import l2s.gameserver.model.clansearch.base.ClanSearchClanSortType;
import l2s.gameserver.model.clansearch.base.ClanSearchListType;
import l2s.gameserver.model.clansearch.base.ClanSearchSortOrder;
import l2s.gameserver.model.clansearch.base.ClanSearchTargetType;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExPledgeRecruitBoardSearch;

public class RequestPledgeRecruitBoardSearch
extends L2GameClientPacket {
    private ClanSearchParams _params;

    @Override
    protected boolean readImpl() {
        this._params = new ClanSearchParams(this.readD(), ClanSearchListType.getType(this.readD()), ClanSearchTargetType.valueOf(this.readD()), this.readS(), ClanSearchClanSortType.valueOf(this.readD()), ClanSearchSortOrder.valueOf(this.readD()), this.readD(), this.readD());
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExPledgeRecruitBoardSearch(this._params));
    }
}

