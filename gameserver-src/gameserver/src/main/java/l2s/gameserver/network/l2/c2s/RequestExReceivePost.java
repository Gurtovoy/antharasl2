package l2s.gameserver.network.l2.c2s;

import l2s.commons.dao.JdbcEntityState;
import l2s.commons.math.SafeMath;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.model.mail.MailPeaceZone;
import java.util.Set;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExShowReceivedPostList;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.taskmanager.DelayedItemsManager;
import l2s.gameserver.utils.Log;
import org.apache.commons.lang3.StringUtils;

public class RequestExReceivePost
extends L2GameClientPacket {
    private int postId;

    @Override
    protected boolean readImpl() {
        this.postId = this.readD();
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     * Unable to fully structure code
     * Enabled aggressive block sorting
     * Enabled unnecessary exception pruning
     * Enabled aggressive exception aggregation
     * Converted monitor instructions to comments
     * Lifted jumps to return sites
     */
    @Override
    protected void runImpl() {
        Player activeChar = null;
        Mail mail;
        Set<ItemInstance> attachments;
        boolean safePost;
        Object var6_6;
        ItemInstance[] items;
        int slots;
        long weight;
        block30: {
            try {
                block28: {
                    block27: {
                        block26: {
                            block25: {
                                activeChar = ((GameClient)this.getClient()).getActiveChar();
                                if (activeChar == null) {
                                    return;
                                }
                                if (activeChar.isActionsDisabled()) {
                                    activeChar.sendActionFailed();
                                    return;
                                }
                                if (MailPeaceZone.blockIfPeaceOnly(activeChar, SystemMsg.YOU_CANNOT_RECEIVE_IN_A_NONPEACE_ZONE_LOCATION, true)) {
                                    return;
                                }
                                if (activeChar.isInStoreMode()) {
                                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_RECEIVE_BECAUSE_THE_PRIVATE_SHOP_OR_WORKSHOP_IS_IN_PROGRESS);
                                    return;
                                }
                                if (activeChar.isInTrade()) {
                                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_RECEIVE_DURING_AN_EXCHANGE);
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
                                if (activeChar.getEnchantScroll() != null) {
                                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_RECEIVE_DURING_AN_ITEM_ENHANCEMENT_OR_ATTRIBUTE_ENHANCEMENT);
                                    return;
                                }
                                mail = MailDAO.getInstance().getReceivedMailByMailId(activeChar.getObjectId(), this.postId);
                                if (mail == null) break block30;
                                activeChar.getInventory().writeLock();
                                attachments = mail.getAttachments();
                                if (attachments.size() <= 0 || !activeChar.isInJail()) break block25;
                                activeChar.sendMessage("You cannot receive mail while in jail.");
                                activeChar.getInventory().writeUnlock();
                                return;
                            }
                            safePost = false;
                            var6_6 = attachments;
                            // MONITORENTER : attachments
                            if (!mail.getAttachments().isEmpty()) break block26;
                            // MONITOREXIT : var6_6
                            activeChar.getInventory().writeUnlock();
                            return;
                        }
                        items = mail.getAttachments().toArray(new ItemInstance[attachments.size()]);
                        slots = 0;
                        weight = 0L;
                        for (ItemInstance item : items) {
                            weight = SafeMath.addAndCheck((long)weight, (long)SafeMath.mulAndCheck((long)item.getCount(), (long)item.getTemplate().getWeight()));
                            if (item.getTemplate().isStackable() && activeChar.getInventory().getItemByItemId(item.getItemId()) != null) continue;
                            ++slots;
                        }
                        if (activeChar.getInventory().validateWeight(weight)) break block27;
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_COULD_NOT_RECEIVE_BECAUSE_YOUR_INVENTORY_IS_FULL);
                        // MONITOREXIT : var6_6
                        activeChar.getInventory().writeUnlock();
                        return;
                    }
                    if (activeChar.getInventory().validateCapacity(slots)) break block28;
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_COULD_NOT_RECEIVE_BECAUSE_YOUR_INVENTORY_IS_FULL);
                    // MONITOREXIT : var6_6
                    activeChar.getInventory().writeUnlock();
                    return;
                }
                if (!mail.isReturned() && mail.getPrice() > 0L) {
                    safePost = true;
                    if (!activeChar.reduceAdena(mail.getPrice(), true)) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_RECEIVE_BECAUSE_YOU_DONT_HAVE_ENOUGH_ADENA);
                        // MONITOREXIT : var6_6
                        activeChar.getInventory().writeUnlock();
                        return;
                    }
                    try {
                        Player sender = World.getPlayer(mail.getSenderId());
                        if (sender != null) {
                            ItemInstance adena = sender.addAdena(mail.getPrice(), true);
                            sender.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_ACQUIRED_THE_ATTACHED_ITEM_TO_YOUR_MAIL).addName(activeChar));
                            Log.LogItem((Creature)sender, "PostPaymentRecieve", adena, "receive mail payment: message_id[" + mail.getMessageId() + "], receiver_id[" + mail.getReceiverId() + "]");
                        } else {
                            DelayedItemsManager.addDelayed(mail.getSenderId(), 57, mail.getPrice(), 0, "receive mail payment: message_id[" + mail.getMessageId() + "], receiver_id[" + mail.getReceiverId() + "]");
                        }
                    } catch (ArithmeticException var3_4) {}
                }
                attachments.clear();
                // MONITOREXIT : var6_6
                mail.setJdbcState(JdbcEntityState.UPDATED);
                if (StringUtils.isEmpty((CharSequence)mail.getBody())) {
                    mail.delete();
                } else {
                    mail.update();
                }
                for (ItemInstance item : items) {
                    activeChar.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_ACQUIRED_S2_S1).addItemName(item.getItemId())).addLong(item.getCount()));
                    Log.LogItem((Creature)activeChar, safePost != false ? "SafePostRecieve" : "PostRecieve", item, "receive mail attachments: message_id[" + mail.getMessageId() + "], sender_id[" + mail.getSenderId() + "]");
                    activeChar.getInventory().addItem(item);
                }
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.MAIL_SUCCESSFULLY_RECEIVED);
                break block30;
            }
            finally {
                activeChar.getInventory().writeUnlock();
            }
        }
        activeChar.sendPacket((IBroadcastPacket)new ExShowReceivedPostList(activeChar));
    }
}

