/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.List;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExUnReadMailCount
extends L2GameServerPacket {
    private final int _count;

    public ExUnReadMailCount(Player player) {
        int count = 0;
        List<Mail> mails = MailDAO.getInstance().getReceivedMailByOwnerId(player.getObjectId());
        for (Mail mail : mails) {
            if (!mail.isUnread()) continue;
            ++count;
        }
        this._count = count;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._count);
    }
}

