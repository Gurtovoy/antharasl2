/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class PlayerLogout
extends SendablePacket {
    private String account;

    public PlayerLogout(String account) {
        this.account = account;
    }

    @Override
    protected void writeImpl() {
        this.writeC(4);
        this.writeS(this.account);
    }
}

