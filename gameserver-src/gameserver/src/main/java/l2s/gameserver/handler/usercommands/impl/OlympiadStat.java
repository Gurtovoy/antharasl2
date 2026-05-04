package l2s.gameserver.handler.usercommands.impl;

import l2s.gameserver.Config;
import l2s.gameserver.handler.usercommands.IUserCommandHandler;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class OlympiadStat
implements IUserCommandHandler {
    private static final int[] COMMAND_IDS = new int[]{109};

    @Override
    public boolean useUserCommand(int id, Player activeChar) {
        GameObject objectTarget;
        if (id != COMMAND_IDS[0]) {
            return false;
        }
        GameObject gameObject = objectTarget = Config.OLYMPIAD_OLDSTYLE_STAT ? activeChar : activeChar.getTarget();
        if (objectTarget == null || !objectTarget.isPlayer() || objectTarget.getPlayer().getClassLevel().ordinal() < ClassLevel.SECOND.ordinal()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_COMMAND_CAN_ONLY_BE_USED_BY_A_NOBLESSE);
            return true;
        }
        Player playerTarget = objectTarget.getPlayer();
        SystemMessagePacket sm = new SystemMessagePacket(SystemMsg.FOR_THE_CURRENT_GRAND_OLYMPIAD_YOU_HAVE_PARTICIPATED_IN_S1_MATCHES_S2_WINS_S3_DEFEATS_YOU_CURRENTLY_HAVE_S4_OLYMPIAD_POINTS);
        sm.addInteger(Olympiad.getCompetitionDone(playerTarget.getObjectId()));
        sm.addInteger(Olympiad.getCompetitionWin(playerTarget.getObjectId()));
        sm.addInteger(Olympiad.getCompetitionLoose(playerTarget.getObjectId()));
        sm.addInteger(Olympiad.getParticipantPoints(playerTarget.getObjectId()));
        activeChar.sendPacket((IBroadcastPacket)sm);
        int[] ar = Olympiad.getWeekGameCounts(playerTarget.getObjectId());
        sm = new SystemMessagePacket(SystemMsg.YOU_HAVE_S1_MATCHES_REMAINING_THAT_YOU_CAN_PARTICIPATE_IN_THIS_WEEK_S2_1_VS_1_CLASS_MATCHES_S3_1_VS_1_MATCHES__S4_3_VS_3_TEAM_MATCHES);
        sm.addInteger(ar[0]);
        sm.addInteger(ar[1]);
        sm.addInteger(ar[2]);
        sm.addInteger(0.0);
        activeChar.sendPacket((IBroadcastPacket)sm);
        return true;
    }

    @Override
    public int[] getUserCommandList() {
        return COMMAND_IDS;
    }
}

