package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class L2FriendSayPacket
extends L2GameServerPacket {
    private String _sender;
    private String _receiver;
    private String _message;

    public L2FriendSayPacket(String sender, String reciever, String message) {
        this._sender = sender;
        this._receiver = reciever;
        this._message = message;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(0);
        this.writeS(this._receiver);
        this.writeS(this._sender);
        this.writeS(this._message);
    }
}

