package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExReplyReceivedPost
extends L2GameServerPacket {
    private final Mail mail;

    public ExReplyReceivedPost(Mail mail) {
        this.mail = mail;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this.mail.getType().ordinal());
        if (this.mail.getType() == Mail.SenderType.SYSTEM) {
            this.writeD(this.mail.getSystemParams()[0]);
            this.writeD(this.mail.getSystemParams()[1]);
            this.writeD(this.mail.getSystemParams()[2]);
            this.writeD(this.mail.getSystemParams()[3]);
            this.writeD(this.mail.getSystemParams()[4]);
            this.writeD(this.mail.getSystemParams()[5]);
            this.writeD(this.mail.getSystemParams()[6]);
            this.writeD(this.mail.getSystemParams()[7]);
            this.writeD(this.mail.getSystemTopic());
            this.writeD(this.mail.getSystemBody());
        } else if (this.mail.getType() == Mail.SenderType.UNKNOWN) {
            this.writeD(3492);
            this.writeD(3493);
        }
        this.writeD(this.mail.getMessageId());
        this.writeD(this.mail.isPayOnDelivery() ? 1 : 0);
        this.writeD(this.mail.isReturned() ? 1 : 0);
        this.writeS(this.mail.getSenderName());
        this.writeS(this.mail.getTopic());
        this.writeS(this.mail.getBody());
        this.writeD(this.mail.getAttachments().size());
        for (ItemInstance item : this.mail.getAttachments()) {
            this.writeItemInfo(item);
            this.writeD(item.getObjectId());
        }
        this.writeQ(this.mail.getPrice());
        this.writeD(this.mail.isReturnable());
        this.writeD(this.mail.getReceiverId());
    }
}

