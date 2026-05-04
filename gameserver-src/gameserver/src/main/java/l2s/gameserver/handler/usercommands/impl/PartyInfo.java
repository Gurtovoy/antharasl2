/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.usercommands.impl;

import l2s.gameserver.handler.usercommands.IUserCommandHandler;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class PartyInfo
implements IUserCommandHandler {
    private static final int[] COMMAND_IDS = new int[]{81};

    @Override
    public boolean useUserCommand(int id, Player activeChar) {
        if (id != COMMAND_IDS[0]) {
            return false;
        }
        Party playerParty = activeChar.getParty();
        if (!activeChar.isInParty()) {
            return false;
        }
        Player partyLeader = playerParty.getPartyLeader();
        if (partyLeader == null) {
            return false;
        }
        int memberCount = playerParty.getMemberCount();
        int lootDistribution = playerParty.getLootDistribution();
        activeChar.sendPacket((IBroadcastPacket)SystemMsg.PARTY_INFORMATION);
        switch (lootDistribution) {
            case 0: {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.LOOTING_METHOD_FINDERS_KEEPERS);
                break;
            }
            case 3: {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.LOOTING_METHOD_BY_TURN);
                break;
            }
            case 4: {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.LOOTING_METHOD_BY_TURN_INCLUDING_SPOIL);
                break;
            }
            case 1: {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.LOOTING_METHOD_RANDOM);
                break;
            }
            case 2: {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.LOOTING_METHOD_RANDOM_INCLUDING_SPOIL);
            }
        }
        activeChar.sendPacket((IBroadcastPacket)SystemMsg.LINE_500);
        return true;
    }

    @Override
    public final int[] getUserCommandList() {
        return COMMAND_IDS;
    }
}

