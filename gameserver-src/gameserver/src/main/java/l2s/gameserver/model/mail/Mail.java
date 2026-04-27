/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dao.JdbcEntity
 *  l2s.commons.dao.JdbcEntityState
 */
package l2s.gameserver.model.mail;

import java.util.HashSet;
import java.util.Set;
import l2s.commons.dao.JdbcEntity;
import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.dao.MailDAO;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.SystemMsg;

public class Mail
implements JdbcEntity,
Comparable<Mail> {
    private static final int MAX_SYSTEM_PARAMS_COUNT = 8;
    public static final int DELETED = 0;
    public static final int READED = 1;
    public static final int REJECTED = 2;
    public static final String COMMISSION_BUY_TOPIC = "CommissionBuyTitle";
    public static final int NORMAL_POST = 0;
    public static final int COMMISSION_POST = 5;
    private static final MailDAO _mailDAO = MailDAO.getInstance();
    private int _postType;
    private int messageId;
    private int senderId;
    private String senderName;
    private int receiverId;
    private String receiverName;
    private int expireTime;
    private String topic;
    private String body;
    private long price;
    private SenderType _type = SenderType.NORMAL;
    private boolean _isUnread;
    private boolean _isReturned = false;
    private Set<ItemInstance> attachments = new HashSet<ItemInstance>();
    private int _systemTopic;
    private int _systemBody;
    private int[] _systemParams = new int[8];
    private JdbcEntityState _state = JdbcEntityState.CREATED;

    public int getPostType() {
        return this._postType;
    }

    public void setPostType(int val) {
        this._postType = val;
    }

    public int getMessageId() {
        return this.messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public int getSenderId() {
        return this.senderId;
    }

    public void setSenderId(int senderId) {
        this.senderId = senderId;
    }

    public String getSenderName() {
        return this.senderName;
    }

    public void setSenderName(String senderName) {
        this.senderName = senderName;
    }

    public int getReceiverId() {
        return this.receiverId;
    }

    public void setReceiverId(int receiverId) {
        this.receiverId = receiverId;
    }

    public String getReceiverName() {
        return this.receiverName;
    }

    public void setReceiverName(String receiverName) {
        this.receiverName = receiverName;
    }

    public int getExpireTime() {
        return this.expireTime;
    }

    public void setExpireTime(int expireTime) {
        this.expireTime = expireTime;
    }

    public String getTopic() {
        return this.topic;
    }

    public void setTopic(String topic) {
        this.topic = topic;
    }

    public String getBody() {
        return this.body;
    }

    public void setBody(String body) {
        this.body = body == null ? "" : body;
    }

    public boolean isPayOnDelivery() {
        return this.price > 0L;
    }

    public long getPrice() {
        return this.price;
    }

    public void setPrice(long price) {
        this.price = price;
    }

    public boolean isUnread() {
        return this._isUnread;
    }

    public void setUnread(boolean isUnread) {
        this._isUnread = isUnread;
    }

    public boolean isReturned() {
        return this._isReturned;
    }

    public void setReturned(boolean value) {
        this._isReturned = value;
    }

    public Set<ItemInstance> getAttachments() {
        return this.attachments;
    }

    public void addAttachment(ItemInstance item) {
        this.attachments.add(item);
    }

    public boolean isReturnable() {
        return this._type == SenderType.NORMAL && this.attachments.size() > 0 && !this._isReturned;
    }

    public int getSystemTopic() {
        return this._systemTopic;
    }

    public void setSystemTopic(int systemTopic) {
        this._systemTopic = systemTopic;
    }

    public void setSystemTopic(SystemMsg systemTopic) {
        this._systemTopic = systemTopic.getId();
    }

    public int getSystemBody() {
        return this._systemBody;
    }

    public void setSystemBody(int systemBody) {
        this._systemBody = systemBody;
    }

    public void setSystemBody(SystemMsg systemBody) {
        this._systemBody = systemBody.getId();
    }

    public int[] getSystemParams() {
        return this._systemParams;
    }

    public String getSystemParamsToString() {
        String result = "";
        for (int param : this._systemParams) {
            result = result + param + ";";
        }
        return result;
    }

    public void setSystemParam(int i, int val) {
        this._systemParams[i] = val;
    }

    public void setSystemParams(String val) {
        if (val == null || val.isEmpty()) {
            return;
        }
        String[] params = val.split(";");
        int length = Math.min(params.length, 8);
        for (int i = 0; i < length; ++i) {
            String param = params[i];
            if (param == null || param.isEmpty()) continue;
            this.setSystemParam(i, Integer.parseInt(param));
        }
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (o == null) {
            return false;
        }
        if (o.getClass() != this.getClass()) {
            return false;
        }
        return ((Mail)o).getMessageId() == this.getMessageId();
    }

    public int hashCode() {
        return 13 * this.getMessageId() + 11700;
    }

    public void setJdbcState(JdbcEntityState state) {
        this._state = state;
    }

    public JdbcEntityState getJdbcState() {
        return this._state;
    }

    public void save() {
        _mailDAO.save(this);
    }

    public void update() {
        _mailDAO.update(this);
    }

    public void delete() {
        _mailDAO.delete(this);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Mail reject() {
        Mail mail = new Mail();
        mail.setSenderId(1);
        mail.setSenderName("System");
        mail.setReceiverId(this.getSenderId());
        mail.setReceiverName(this.getSenderName());
        mail.setTopic(this.getTopic());
        mail.setBody(this.getBody());
        Set<ItemInstance> set = this.getAttachments();
        synchronized (set) {
            for (ItemInstance item : this.getAttachments()) {
                mail.addAttachment(item);
            }
            this.getAttachments().clear();
        }
        mail.setType(SenderType.NEWS_INFORMER);
        mail.setUnread(true);
        mail.setReturned(true);
        mail.setPrice(this.getPrice());
        return mail;
    }

    @Override
    public int compareTo(Mail o) {
        return o.getMessageId() - this.getMessageId();
    }

    public SenderType getType() {
        return this._type;
    }

    public void setType(SenderType type) {
        this._type = type;
    }

    public static enum SenderType {
        NORMAL,
        NEWS_INFORMER,
        NONE,
        BIRTHDAY,
        UNKNOWN,
        SYSTEM,
        MENTOR,
        PRESENT;

        public static SenderType[] VALUES;

        static {
            VALUES = SenderType.values();
        }
    }
}

