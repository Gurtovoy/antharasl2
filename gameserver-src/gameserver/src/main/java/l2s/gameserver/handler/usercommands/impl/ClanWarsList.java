/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.usercommands.impl;

import java.util.ArrayList;
import l2s.gameserver.handler.usercommands.IUserCommandHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessage;

public class ClanWarsList
implements IUserCommandHandler {
    private static final int[] COMMAND_IDS = new int[]{88, 89, 90};

    @Override
    public boolean useUserCommand(int id, Player activeChar) {
        Clan opposingClan;
        Clan clan = activeChar.getClan();
        if (clan == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.NOT_JOINED_IN_ANY_CLAN);
            return false;
        }
        ArrayList<Clan> data = new ArrayList<Clan>();
        if (id == 88) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.CLANS_YOUVE_DECLARED_WAR_ON);
            for (ClanWar war : clan.getWars().valueCollection()) {
                if (war.getPeriod() != ClanWar.ClanWarPeriod.PREPARATION || !war.isAttacker(clan) || (opposingClan = war.getAttackedClan()) == null) continue;
                data.add(opposingClan);
            }
        } else if (id == 89) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.CLANS_THAT_HAVE_DECLARED_WAR_ON_YOU);
            for (ClanWar war : clan.getWars().valueCollection()) {
                Clan attackerClan;
                if (war.getPeriod() != ClanWar.ClanWarPeriod.PREPARATION || !war.isAttacked(clan) || (attackerClan = war.getAttackerClan()) == null) continue;
                data.add(attackerClan);
            }
        } else if (id == 90) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WAR_LIST);
            for (ClanWar war : clan.getWars().valueCollection()) {
                if (war.getPeriod() != ClanWar.ClanWarPeriod.MUTUAL || (opposingClan = war.getOpposingClan(clan)) == null) continue;
                data.add(opposingClan);
            }
        } else {
            return false;
        }
        for (Clan c : data) {
            String clanName = c.getName();
            Alliance alliance = c.getAlliance();
            SystemMessage sm = alliance != null ? new SystemMessage(1200).addString(clanName).addString(alliance.getAllyName()) : new SystemMessage(1202).addString(clanName);
            activeChar.sendPacket((IBroadcastPacket)sm);
        }
        activeChar.sendPacket((IBroadcastPacket)SystemMsg.LINE_490);
        return true;
    }

    @Override
    public int[] getUserCommandList() {
        return COMMAND_IDS;
    }
}

