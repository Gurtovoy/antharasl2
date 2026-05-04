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

public class ExShowReceivedPostList
extends L2GameServerPacket {
    private final Mail[] _mails;

    public ExShowReceivedPostList(Player cha) {
        List<Mail> mails = MailDAO.getInstance().getReceivedMailByOwnerId(cha.getObjectId());
        Collections.sort(mails);
        this._mails = mails.toArray(new Mail[mails.size()]);
    }

    @Override
    protected void writeImpl() {
        this.writeD((int)(System.currentTimeMillis() / 1000L));
        this.writeD(this._mails.length);
        for (Mail mail : this._mails) {
            this.writeD(mail.getType().ordinal());
            if (mail.getType() == Mail.SenderType.SYSTEM) {
                this.writeD(mail.getSystemTopic());
            }
            this.writeD(mail.getMessageId());
            this.writeS(mail.getTopic());
            this.writeS(mail.getSenderName());
            this.writeD(mail.isPayOnDelivery() ? 1 : 0);
            this.writeD(mail.getExpireTime());
            this.writeD(mail.isUnread() ? 1 : 0);
            this.writeD(mail.isReturnable());
            this.writeD(mail.getAttachments().isEmpty() ? 0 : 1);
            this.writeD(mail.isReturned() ? 1 : 0);
            this.writeD(mail.getReceiverId());
        }
        this.writeD(100);
        this.writeD(1000);
    }
}

