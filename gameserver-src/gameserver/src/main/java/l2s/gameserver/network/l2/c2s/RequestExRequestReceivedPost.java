/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExChangePostState;
import l2s.gameserver.network.l2.s2c.ExReplyReceivedPost;
import l2s.gameserver.network.l2.s2c.ExShowReceivedPostList;
import l2s.gameserver.network.l2.s2c.ExUnReadMailCount;

public class RequestExRequestReceivedPost
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
        Mail mail = MailDAO.getInstance().getReceivedMailByMailId(activeChar.getObjectId(), this.postId);
        if (mail != null) {
            if (mail.isUnread()) {
                mail.setUnread(false);
                mail.setJdbcState(JdbcEntityState.UPDATED);
                mail.update();
                activeChar.sendPacket((IBroadcastPacket)new ExChangePostState(true, 1, mail));
                activeChar.sendPacket((IBroadcastPacket)new ExUnReadMailCount(activeChar));
            }
            activeChar.sendPacket((IBroadcastPacket)new ExReplyReceivedPost(mail));
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new ExShowReceivedPostList(activeChar));
    }
}

