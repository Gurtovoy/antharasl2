/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.tables.ClanTable;

public class RequestAllyInfo
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Alliance ally = player.getAlliance();
        if (ally == null) {
            return;
        }
        int clancount = 0;
        Clan leaderclan = player.getAlliance().getLeader();
        clancount = ClanTable.getInstance().getAlliance(leaderclan.getAllyId()).getMembers().length;
        int[] online = new int[clancount + 1];
        int[] count = new int[clancount + 1];
        Clan[] clans = player.getAlliance().getMembers();
        for (int i = 0; i < clancount; ++i) {
            online[i + 1] = clans[i].getOnlineMembers().size();
            count[i + 1] = clans[i].getAllSize();
            online[0] = online[0] + online[i + 1];
            count[0] = count[0] + count[i + 1];
        }
        ArrayList<IBroadcastPacket> packets = new ArrayList<IBroadcastPacket>(7 + 5 * clancount);
        packets.add(SystemMsg.ALLIANCE_INFORMATION);
        packets.add(new SystemMessage(492).addString(player.getClan().getAlliance().getAllyName()));
        packets.add(new SystemMessage(493).addNumber(online[0]).addNumber(count[0]));
        packets.add(new SystemMessage(494).addString(leaderclan.getName()).addString(leaderclan.getLeaderName()));
        packets.add(new SystemMessage(495).addNumber(clancount));
        packets.add(SystemMsg.CLAN_INFORMATION);
        for (int i = 0; i < clancount; ++i) {
            packets.add(new SystemMessage(497).addString(clans[i].getName()));
            packets.add(new SystemMessage(498).addString(clans[i].getLeaderName()));
            packets.add(new SystemMessage(499).addNumber(clans[i].getLevel()));
            packets.add(new SystemMessage(493).addNumber(online[i + 1]).addNumber(count[i + 1]));
            packets.add(SystemMsg.LINE_500);
        }
        packets.add(SystemMsg.LINE_490);
        player.sendPacket(packets);
    }
}

