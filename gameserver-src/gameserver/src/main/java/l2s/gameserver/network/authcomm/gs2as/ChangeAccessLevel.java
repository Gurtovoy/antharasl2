/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class ChangeAccessLevel
extends SendablePacket {
    private String account;
    private int level;
    private int banExpire;

    public ChangeAccessLevel(String account, int level, int banExpire) {
        this.account = account;
        this.level = level;
        this.banExpire = banExpire;
    }

    @Override
    protected void writeImpl() {
        this.writeC(17);
        this.writeS(this.account);
        this.writeD(this.level);
        this.writeD(this.banExpire);
    }
}

