package l2s.gameserver.handler.usercommands.impl;

import java.util.Calendar;
import l2s.gameserver.handler.usercommands.IUserCommandHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class MyBirthday
implements IUserCommandHandler {
    private static final int[] COMMAND_IDS = new int[]{126};

    @Override
    public boolean useUserCommand(int id, Player activeChar) {
        if (activeChar.getCreateTime() == 0L) {
            return false;
        }
        Calendar c = Calendar.getInstance();
        c.setTimeInMillis(activeChar.getCreateTime());
        activeChar.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1S_BIRTHDAY_IS_S3S4S2).addName(activeChar)).addInteger(c.get(1))).addInteger(c.get(2) + 1)).addInteger(c.get(5)));
        if (c.get(2) == 1 && c.get(7) == 29) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_CHARACTER_BORN_ON_FEBRUARY_29_WILL_RECEIVE_A_GIFT_ON_FEBRUARY_28);
        }
        return true;
    }

    @Override
    public final int[] getUserCommandList() {
        return COMMAND_IDS;
    }
}

