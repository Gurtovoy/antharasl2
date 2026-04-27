/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dao.JdbcEntityState
 *  org.apache.commons.lang3.ArrayUtils
 */
package l2s.gameserver.network.l2.c2s;

import java.util.ArrayList;
import java.util.HashMap;
import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.database.mysql;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExNoticePostArrived;
import l2s.gameserver.network.l2.s2c.ExReplyWritePost;
import l2s.gameserver.network.l2.s2c.ExUnReadMailCount;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.utils.Functions;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.Util;
import org.apache.commons.lang3.ArrayUtils;

public class RequestExSendPost
extends L2GameClientPacket {
    private int _messageType;
    private String _recieverName;
    private String _topic;
    private String _body;
    private int _count;
    private int[] _items;
    private long[] _itemQ;
    private long _price;

    @Override
    protected boolean readImpl() {
        this._recieverName = this.readS(35);
        this._messageType = this.readD();
        this._topic = this.readS(127);
        this._body = this.readS(Short.MAX_VALUE);
        this._count = this.readD();
        if (this._count * 12 + 4 > this._buf.remaining() || this._count > Short.MAX_VALUE || this._count < 1) {
            this._count = 0;
            return false;
        }
        this._items = new int[this._count];
        this._itemQ = new long[this._count];
        for (int i = 0; i < this._count; ++i) {
            this._items[i] = this.readD();
            this._itemQ[i] = this.readQ();
            if (this._itemQ[i] >= 1L && ArrayUtils.indexOf((int[])this._items, (int)this._items[i]) >= i) continue;
            this._count = 0;
            return false;
        }
        this._price = this.readQ();
        if (this._price < 0L) {
            this._count = 0;
            this._price = 0L;
        }
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    protected void runImpl() {
        int recieverId;
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isActionsDisabled()) {
            activeChar.sendActionFailed();
            return;
        }
        if (!activeChar.getPlayerAccess().UseMail) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.SOME_LINEAGE_II_FEATURES_HAVE_BEEN_LIMITED_FOR_FREE_TRIALS_);
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isGM() && this._recieverName.equalsIgnoreCase("ONLINE_ALL")) {
            HashMap<Integer, Long> map = new HashMap<Integer, Long>();
            if (this._items != null && this._items.length > 0) {
                for (int i = 0; i < this._items.length; ++i) {
                    ItemInstance item = activeChar.getInventory().getItemByObjectId(this._items[i]);
                    map.put(item.getItemId(), this._itemQ[i]);
                }
            }
            for (Player p : GameObjectsStorage.getPlayers(false, false)) {
                if (p == null || !p.isOnline()) continue;
                Functions.sendSystemMail(p, this._topic, this._body, map);
            }
            activeChar.sendPacket((IBroadcastPacket)ExReplyWritePost.STATIC_TRUE);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.MAIL_SUCCESSFULLY_SENT);
            return;
        }
        if (!Config.ALLOW_MAIL) {
            activeChar.sendMessage(new CustomMessage("mail.Disabled"));
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FORWARD_BECAUSE_THE_PRIVATE_SHOP_OR_WORKSHOP_IS_IN_PROGRESS);
            return;
        }
        if (activeChar.isInTrade()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FORWARD_DURING_AN_EXCHANGE);
            return;
        }
        if (activeChar.getEnchantScroll() != null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FORWARD_DURING_AN_ITEM_ENHANCEMENT_OR_ATTRIBUTE_ENHANCEMENT);
            return;
        }
        if (activeChar.getName().equalsIgnoreCase(this._recieverName)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_SEND_A_MAIL_TO_YOURSELF);
            return;
        }
        if (this._count > 0 && !activeChar.isInPeaceZone()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FORWARD_IN_A_NONPEACE_ZONE_LOCATION);
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
        if (!activeChar.getAntiFlood().canMail()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_PREVIOUS_MAIL_WAS_FORWARDED_LESS_THAN_1_MINUTE_AGO_AND_THIS_CANNOT_BE_FORWARDED);
            return;
        }
        if (this._price > 0L) {
            if (!activeChar.getPlayerAccess().UseMail) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.SOME_LINEAGE_II_FEATURES_HAVE_BEEN_LIMITED_FOR_FREE_TRIALS_);
                activeChar.sendActionFailed();
                return;
            }
            String tradeBan = activeChar.getVar("tradeBan");
            if (tradeBan != null && (tradeBan.equals("-1") || Long.parseLong(tradeBan) >= System.currentTimeMillis())) {
                if (tradeBan.equals("-1")) {
                    activeChar.sendMessage(new CustomMessage("common.TradeBannedPermanently"));
                } else {
                    activeChar.sendMessage(new CustomMessage("common.TradeBanned").addString(Util.formatTime((int)(Long.parseLong(tradeBan) / 1000L - System.currentTimeMillis() / 1000L))));
                }
                return;
            }
        }
        if (activeChar.getBlockList().contains(this._recieverName)) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_BLOCKED_C1).addString(this._recieverName));
            return;
        }
        Player target = World.getPlayer(this._recieverName);
        if (target != null) {
            recieverId = target.getObjectId();
            this._recieverName = target.getName();
            if (target.getBlockList().contains(activeChar)) {
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_HAS_BLOCKED_YOU_YOU_CANNOT_SEND_MAIL_TO_C1).addString(this._recieverName));
                return;
            }
        } else {
            recieverId = CharacterDAO.getInstance().getObjectIdByName(this._recieverName);
            if (recieverId > 0 && mysql.simple_get_int("target_Id", "character_blocklist", "obj_Id=" + recieverId + " AND target_Id=" + activeChar.getObjectId()) > 0) {
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_HAS_BLOCKED_YOU_YOU_CANNOT_SEND_MAIL_TO_C1).addString(this._recieverName));
                return;
            }
        }
        if (recieverId == 0) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.WHEN_THE_RECIPIENT_DOESNT_EXIST_OR_THE_CHARACTER_HAS_BEEN_DELETED_SENDING_MAIL_IS_NOT_POSSIBLE);
            return;
        }
        int expireTime = (this._messageType == 1 ? 12 : 360) * 3600 + (int)(System.currentTimeMillis() / 1000L);
        if (this._count > 8) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INCORRECT_ITEM_COUNT);
            return;
        }
        long serviceCost = 100 + this._count * 1000;
        ArrayList<ItemInstance> attachments = new ArrayList<ItemInstance>();
        activeChar.getInventory().writeLock();
        try {
            ItemInstance item;
            int i;
            if (activeChar.getAdena() < serviceCost) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FORWARD_BECAUSE_YOU_DONT_HAVE_ENOUGH_ADENA);
                return;
            }
            if (this._count > 0) {
                for (i = 0; i < this._count; ++i) {
                    item = activeChar.getInventory().getItemByObjectId(this._items[i]);
                    if (item != null && item.getCount() >= this._itemQ[i] && (item.getItemId() != 57 || item.getCount() >= this._itemQ[i] + serviceCost) && item.canBeTraded(activeChar)) continue;
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_ITEM_THAT_YOURE_TRYING_TO_SEND_CANNOT_BE_FORWARDED_BECAUSE_IT_ISNT_PROPER);
                    return;
                }
            }
            if (!activeChar.reduceAdena(serviceCost, true)) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_FORWARD_BECAUSE_YOU_DONT_HAVE_ENOUGH_ADENA);
                return;
            }
            if (this._count > 0) {
                for (i = 0; i < this._count; ++i) {
                    item = activeChar.getInventory().removeItemByObjectId(this._items[i], this._itemQ[i]);
                    Log.LogItem(activeChar, "PostSend", item);
                    item.setOwnerId(activeChar.getObjectId());
                    item.setLocation(ItemInstance.ItemLocation.MAIL);
                    if (item.getJdbcState().isSavable()) {
                        item.save();
                    } else {
                        item.setJdbcState(JdbcEntityState.UPDATED);
                        item.update();
                    }
                    attachments.add(item);
                }
            }
        }
        finally {
            activeChar.getInventory().writeUnlock();
        }
        Mail mail = new Mail();
        mail.setSenderId(activeChar.getObjectId());
        mail.setSenderName(activeChar.getName());
        mail.setReceiverId(recieverId);
        mail.setReceiverName(this._recieverName);
        mail.setTopic(this._topic);
        mail.setBody(this._body);
        mail.setPrice(this._messageType > 0 ? this._price : 0L);
        mail.setUnread(true);
        mail.setType(Mail.SenderType.NORMAL);
        mail.setExpireTime(expireTime);
        for (ItemInstance item : attachments) {
            mail.addAttachment(item);
        }
        mail.save();
        activeChar.sendPacket((IBroadcastPacket)ExReplyWritePost.STATIC_TRUE);
        activeChar.sendPacket((IBroadcastPacket)SystemMsg.MAIL_SUCCESSFULLY_SENT);
        if (target != null) {
            target.sendPacket((IBroadcastPacket)ExNoticePostArrived.STATIC_TRUE);
            target.sendPacket((IBroadcastPacket)new ExUnReadMailCount(target));
            target.sendPacket((IBroadcastPacket)SystemMsg.THE_MAIL_HAS_ARRIVED);
        }
    }
}

