/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.clansearch.ClanSearchPlayer;
import l2s.gameserver.model.clansearch.base.ClanSearchListType;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPledgeRecruitApplyInfo;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestPledgeWaitingApply
extends L2GameClientPacket {
    private ClanSearchListType _searchType;
    private int _clanId;
    private String _desc;

    @Override
    protected boolean readImpl() {
        this._searchType = ClanSearchListType.getType(this.readD());
        this._clanId = this.readD();
        this._desc = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.getClan() != null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ONLY_THE_CLAN_LEADER_OR_SOMEONE_WITH_RANK_MANAGEMENT_AUTHORITY_MAY_REGISTER_THE_CLAN);
            return;
        }
        ClanSearchPlayer csPlayer = new ClanSearchPlayer(activeChar.getObjectId(), activeChar.getName(), activeChar.getLevel(), activeChar.getBaseClassId(), this._clanId, this._searchType, this._desc);
        if (ClanSearchManager.getInstance().addPlayer(csPlayer)) {
            activeChar.sendPacket((IBroadcastPacket)ExPledgeRecruitApplyInfo.WAITING);
        } else {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_MAY_APPLY_FOR_ENTRY_AFTER_S1_MINUTES_DUE_TO_CANCELLING_YOUR_APPLICATION).addInteger(5.0));
        }
    }
}

