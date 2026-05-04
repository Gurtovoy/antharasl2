/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collections;
import java.util.List;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowSentPostList
extends L2GameServerPacket {
    private final List<Mail> mails;

    public ExShowSentPostList(Player cha) {
        this.mails = MailDAO.getInstance().getSentMailByOwnerId(cha.getObjectId());
        Collections.sort(this.mails);
    }

    @Override
    protected void writeImpl() {
        this.writeD((int)(System.currentTimeMillis() / 1000L));
        this.writeD(this.mails.size());
        for (Mail mail : this.mails) {
            this.writeD(mail.getMessageId());
            this.writeS(mail.getTopic());
            this.writeS(mail.getReceiverName());
            this.writeD(mail.isPayOnDelivery() ? 1 : 0);
            this.writeD(mail.getExpireTime());
            this.writeD(mail.isUnread() ? 1 : 0);
            this.writeD(mail.isReturnable());
            this.writeD(mail.getAttachments().isEmpty() ? 0 : 1);
            this.writeD(0);
        }
    }
}

