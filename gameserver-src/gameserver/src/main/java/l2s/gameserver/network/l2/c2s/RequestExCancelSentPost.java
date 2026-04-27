/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.math.SafeMath
 */
package l2s.gameserver.network.l2.c2s;

import l2s.commons.math.SafeMath;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExShowSentPostList;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.utils.Log;

public class RequestExCancelSentPost
extends L2GameClientPacket {
    private int postId;

    @Override
    protected boolean readImpl() {
        this.postId = this.readD();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
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
        if (!activeChar.isInPeaceZone()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_CANCEL_IN_A_NONPEACE_ZONE_LOCATION);
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
        Mail mail = MailDAO.getInstance().getSentMailByMailId(activeChar.getObjectId(), this.postId);
        if (mail != null) {
            if (mail.getAttachments().isEmpty()) {
                activeChar.sendActionFailed();
                return;
            }
            activeChar.getInventory().writeLock();
            try {
                int slots = 0;
                long weight = 0L;
                for (ItemInstance item : mail.getAttachments()) {
                    weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)item.getCount(), (long)item.getTemplate().getWeight()));
                    if (item.getTemplate().isStackable() && activeChar.getInventory().getItemByItemId(item.getItemId()) != null) continue;
                    ++slots;
                }
                if (!activeChar.getInventory().validateWeight(weight)) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_COULD_NOT_CANCEL_RECEIPT_BECAUSE_YOUR_INVENTORY_IS_FULL);
                    return;
                }
                if (!activeChar.getInventory().validateCapacity(slots)) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_COULD_NOT_CANCEL_RECEIPT_BECAUSE_YOUR_INVENTORY_IS_FULL);
                    return;
                }
                java.util.Set<ItemInstance> attachments = mail.getAttachments();
                synchronized (attachments) {
                    ItemInstance[] items = mail.getAttachments().toArray(new ItemInstance[attachments.size()]);
                    attachments.clear();
                    // ** MonitorExit[var8_8] (shouldn't be in output)
                    for (ItemInstance item : items) {
                        activeChar.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_ACQUIRED_S2_S1).addItemName(item.getItemId())).addLong(item.getCount()));
                        Log.LogItem(activeChar, "PostCancel", item);
                        activeChar.getInventory().addItem(item);
                    }
                    mail.delete();
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.MAIL_SUCCESSFULLY_CANCELLED);
                }
            }
            catch (ArithmeticException arithmeticException) {
            }
            finally {
                activeChar.getInventory().writeUnlock();
            }
        }
        {
            activeChar.sendPacket((IBroadcastPacket)new ExShowSentPostList(activeChar));
            return;
        }
    }
}

