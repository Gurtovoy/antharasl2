/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public final class RequestVipLuckyGameItemList
extends L2GameClientPacket {
    private int _unk1;

    @Override
    protected boolean readImpl() {
        this._unk1 = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        System.out.println("RequestVipLuckyGameItemList _unk1=" + this._unk1);
    }
}

