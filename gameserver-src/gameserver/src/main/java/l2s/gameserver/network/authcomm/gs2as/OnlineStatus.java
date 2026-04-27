/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class OnlineStatus
extends SendablePacket {
    private boolean _online;

    public OnlineStatus(boolean online) {
        this._online = online;
    }

    @Override
    protected void writeImpl() {
        this.writeC(1);
        this.writeC(this._online ? 1 : 0);
    }
}

