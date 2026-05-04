/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.List;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExShowReceivedPostList;
import org.apache.commons.lang3.ArrayUtils;

public class RequestExDeleteReceivedPost
extends L2GameClientPacket {
    private int _count;
    private int[] _list;

    @Override
    protected boolean readImpl() {
        this._count = this.readD();
        if (this._count * 4 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._list = new int[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._list[i] = this.readD();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._count == 0) {
            return;
        }
        List<Mail> mails = MailDAO.getInstance().getReceivedMailByOwnerId(activeChar.getObjectId());
        if (!mails.isEmpty()) {
            for (Mail mail : mails) {
                if (!ArrayUtils.contains((int[])this._list, (int)mail.getMessageId()) || !mail.getAttachments().isEmpty()) continue;
                MailDAO.getInstance().deleteReceivedMailByMailId(activeChar.getObjectId(), mail.getMessageId());
            }
        }
        activeChar.sendPacket((IBroadcastPacket)new ExShowReceivedPostList(activeChar));
    }
}

