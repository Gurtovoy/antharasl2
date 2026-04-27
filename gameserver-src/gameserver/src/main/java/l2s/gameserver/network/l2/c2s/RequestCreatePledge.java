/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestCreatePledge
extends L2GameClientPacket {
    private String _pledgename;

    @Override
    protected boolean readImpl() {
        this._pledgename = this.readS(64);
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

