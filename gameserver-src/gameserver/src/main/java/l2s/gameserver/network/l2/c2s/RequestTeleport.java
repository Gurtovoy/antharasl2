package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestTeleport
extends L2GameClientPacket {
    private int unk;
    private int _type;
    private int unk2;
    private int unk3;
    private int unk4;

    @Override
    protected boolean readImpl() {
        this.unk = this.readD();
        this._type = this.readD();
        if (this._type == 2) {
            this.unk2 = this.readD();
            this.unk3 = this.readD();
        } else if (this._type == 3) {
            this.unk2 = this.readD();
            this.unk3 = this.readD();
            this.unk4 = this.readD();
        }
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

