/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class ExSendClientINI
extends L2GameClientPacket {
    private int _iniType;
    private byte[] _content;

    @Override
    protected boolean readImpl() {
        this._iniType = this.readC();
        this._content = new byte[this.readH()];
        this.readB(this._content);
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

