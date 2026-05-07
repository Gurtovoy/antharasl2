package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExNoticePostArrived;
import l2s.gameserver.network.l2.s2c.ExShowReceivedPostList;

public class RequestExRejectPost
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
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_CANCEL_BECAUSE_THE_PRIVATE_SHOP_OR_WORKSHOP_IS_IN_PROGRESS);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_CANCEL_DURING_AN_EXCHANGE);
            return;
        }
        if (activeChar.getEnchantScroll() != null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_CANCEL_DURING_AN_ITEM_ENHANCEMENT_OR_ATTRIBUTE_ENHANCEMENT);
            return;
        }
        if (activeChar.isInJail()) {
            activeChar.sendMessage("You cannot manage mail while in jail.");
            return;
        }
        if (activeChar.isFishing()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING);
            return;
        }
        if (activeChar.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        Mail mail = MailDAO.getInstance().getReceivedMailByMailId(activeChar.getObjectId(), this.postId);
        if (mail != null) {
            if (!mail.isReturnable()) {
                activeChar.sendActionFailed();
                return;
            }
            int expireTime = 1296000 + (int)(System.currentTimeMillis() / 1000L);
            Mail reject = mail.reject();
            mail.delete();
            reject.setExpireTime(expireTime);
            reject.save();
            Player sender = World.getPlayer(reject.getReceiverId());
            if (sender != null) {
                sender.sendPacket((IBroadcastPacket)ExNoticePostArrived.STATIC_TRUE);
            }
        }
        activeChar.sendPacket((IBroadcastPacket)new ExShowReceivedPostList(activeChar));
    }
}

