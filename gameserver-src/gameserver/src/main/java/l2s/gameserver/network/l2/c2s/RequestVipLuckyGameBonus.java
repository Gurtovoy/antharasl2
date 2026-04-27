/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public final class RequestVipLuckyGameBonus
extends L2GameClientPacket {
    private int _unk1;
    private int _unk2;

    @Override
    protected boolean readImpl() {
        this._unk1 = this.readC();
        this._unk2 = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        System.out.println("RequestVipLuckyGameBonus _unk1=" + this._unk1 + ", _unk2=" + this._unk2);
    }
}

