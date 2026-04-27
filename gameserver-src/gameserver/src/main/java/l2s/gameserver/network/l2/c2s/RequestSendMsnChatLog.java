/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestSendMsnChatLog
extends L2GameClientPacket {
    private int unk3;
    private String unk;
    private String unk2;

    @Override
    protected boolean readImpl() {
        this.unk = this.readS();
        this.unk2 = this.readS();
        this.unk3 = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

