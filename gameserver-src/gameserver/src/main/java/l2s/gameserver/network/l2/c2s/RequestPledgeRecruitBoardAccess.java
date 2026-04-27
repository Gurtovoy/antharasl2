/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.clansearch.ClanSearchClan;
import l2s.gameserver.model.clansearch.base.ClanSearchListType;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestPledgeRecruitBoardAccess
extends L2GameClientPacket {
    private int _pledgeAccess;
    private int _application;
    private int _subUnit;
    private ClanSearchListType _searchType;
    private String _desc;

    @Override
    protected boolean readImpl() {
        this._pledgeAccess = this.readD();
        this._searchType = ClanSearchListType.getType(this.readD());
        this.readS();
        this._desc = this.readS();
        this._application = this.readD();
        this._subUnit = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Clan clan = activeChar.getClan();
        if (clan == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ONLY_THE_CLAN_LEADER_OR_SOMEONE_WITH_RANK_MANAGEMENT_AUTHORITY_MAY_REGISTER_THE_CLAN);
            return;
        }
        if ((activeChar.getClanPrivileges() & 0x10) != 16) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ONLY_THE_CLAN_LEADER_OR_SOMEONE_WITH_RANK_MANAGEMENT_AUTHORITY_MAY_REGISTER_THE_CLAN);
            return;
        }
        if (this._desc.length() > 256) {
            this._desc = this._desc.substring(0, 255);
        }
        if (ClanSearchManager.getInstance().addClan(new ClanSearchClan(clan.getClanId(), this._searchType, this._desc, this._application, this._subUnit))) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.ENTRY_APPLICATION_COMPLETE_USE_ENTRY_APPLICATION_INFO_TO_CHECK_OR_CANCEL_YOUR_APPLICATION);
        } else {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_MAY_APPLY_FOR_ENTRY_AFTER_S1_MINUTES_DUE_TO_CANCELLING_YOUR_APPLICATION).addInteger(5.0));
        }
    }
}

