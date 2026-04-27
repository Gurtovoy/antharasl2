/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.ban.BanBindType
 */
package l2s.gameserver.network.authcomm.gs2as;

import l2s.commons.ban.BanBindType;
import l2s.gameserver.network.authcomm.SendablePacket;

public class UnbanRequest
extends SendablePacket {
    private final BanBindType bindType;
    private final String bindValue;

    public UnbanRequest(BanBindType bindType, String bindValue) {
        this.bindType = bindType;
        this.bindValue = bindValue;
    }

    @Override
    protected void writeImpl() {
        this.writeC(20);
        this.writeC(this.bindType.ordinal());
        this.writeS(this.bindValue);
    }
}

