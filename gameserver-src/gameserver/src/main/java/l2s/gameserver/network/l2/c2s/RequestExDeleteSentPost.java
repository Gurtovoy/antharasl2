package l2s.gameserver.network.l2.c2s;

import java.util.List;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.model.mail.MailPeaceZone;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExShowSentPostList;
import org.apache.commons.lang3.ArrayUtils;

public class RequestExDeleteSentPost
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
        if (MailPeaceZone.blockIfPeaceOnly(activeChar, SystemMsg.YOU_CANNOT_CANCEL_IN_A_NONPEACE_ZONE_LOCATION, true)) {
            return;
        }
        List<Mail> mails = MailDAO.getInstance().getSentMailByOwnerId(activeChar.getObjectId());
        if (!mails.isEmpty()) {
            for (Mail mail : mails) {
                if (!ArrayUtils.contains((int[])this._list, (int)mail.getMessageId()) || !mail.getAttachments().isEmpty()) continue;
                MailDAO.getInstance().deleteSentMailByMailId(activeChar.getObjectId(), mail.getMessageId());
            }
        }
        activeChar.sendPacket((IBroadcastPacket)new ExShowSentPostList(activeChar));
    }
}

