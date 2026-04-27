/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.tables.ClanTable;

public class RequestStopPledgeWar
extends L2GameClientPacket {
    private String _pledgeName;

    @Override
    protected boolean readImpl() {
        this._pledgeName = this.readS(32);
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Clan playerClan = activeChar.getClan();
        if (playerClan == null) {
            activeChar.sendActionFailed();
            return;
        }
        if ((activeChar.getClanPrivileges() & 0x20) != 32) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT);
            activeChar.sendActionFailed();
            return;
        }
        Clan clan = ClanTable.getInstance().getClanByName(this._pledgeName);
        if (clan == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_TARGET_FOR_DECLARATION_IS_WRONG);
            activeChar.sendActionFailed();
            return;
        }
        if (!playerClan.isAtWarWith(clan.getClanId())) {
            activeChar.sendActionFailed();
            return;
        }
        for (UnitMember mbr : playerClan) {
            if (!mbr.isOnline() || !mbr.getPlayer().isInCombat()) continue;
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_CEASEFIRE_DURING_A_CLAN_WAR_CAN_NOT_BE_CALLED_WHILE_MEMBERS_OF_YOUR_CLAN_ARE_ENGAGED_IN_BATTLE);
            activeChar.sendActionFailed();
            return;
        }
        ClanWar war = playerClan.getWarWith(clan.getClanId());
        if (war != null) {
            war.cancel(playerClan);
        }
    }
}

