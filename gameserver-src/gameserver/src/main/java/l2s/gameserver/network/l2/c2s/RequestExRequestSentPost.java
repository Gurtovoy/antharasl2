/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExReplySentPost;
import l2s.gameserver.network.l2.s2c.ExShowSentPostList;

public class RequestExRequestSentPost
extends L2GameClientPacket {
    private int postId;

    @Override
    protected boolean readImpl() {
        this.postId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Mail mail = MailDAO.getInstance().getSentMailByMailId(activeChar.getObjectId(), this.postId);
        if (mail != null) {
            activeChar.sendPacket((IBroadcastPacket)new ExReplySentPost(mail));
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExShowSentPostList(activeChar));
    }
}

