package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.mail.MailPeaceZone;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExShowSentPostList;

public class RequestExRequestSentPostList
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
        Player cha = ((GameClient)this.getClient()).getActiveChar();
        if (cha != null) {
            if (MailPeaceZone.blockIfPeaceOnly(cha, SystemMsg.YOU_CANNOT_FORWARD_IN_A_NONPEACE_ZONE_LOCATION, true)) {
                return;
            }
            cha.sendPacket((IBroadcastPacket)new ExShowSentPostList(cha));
        }
    }
}

