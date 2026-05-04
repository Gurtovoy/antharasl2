package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.mail.Mail;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExChangePostState
extends L2GameServerPacket {
    private boolean _receivedBoard;
    private Mail[] _mails;
    private int _changeId;

    public ExChangePostState(boolean receivedBoard, int type, Mail ... n) {
        this._receivedBoard = receivedBoard;
        this._mails = n;
        this._changeId = type;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._receivedBoard ? 1 : 0);
        this.writeD(this._mails.length);
        for (Mail mail : this._mails) {
            this.writeD(mail.getMessageId());
            this.writeD(this._changeId);
        }
    }
}

