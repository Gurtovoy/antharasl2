package l2s.gameserver.model.mail;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.mail.Mail;

public class Attachment {
    private int messageId;
    private ItemInstance item;
    private Mail mail;

    public int getMessageId() {
        return this.messageId;
    }

    public void setMessageId(int messageId) {
        this.messageId = messageId;
    }

    public ItemInstance getItem() {
        return this.item;
    }

    public void setItem(ItemInstance item) {
        this.item = item;
    }

    public Mail getMail() {
        return this.mail;
    }

    public void setMail(Mail mail) {
        this.mail = mail;
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
        return ((Attachment)o).getItem() == this.getItem();
    }

    public int hashCode() {
        return 12 * this.getItem().hashCode() + 11270;
    }
}

