/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.network.gamecomm.as2gs;

import l2s.authserver.network.gamecomm.SendablePacket;

public class ChangePasswordResponse
extends SendablePacket {
    public String _account;
    public boolean _hasChanged;

    public ChangePasswordResponse(String account, boolean hasChanged) {
        this._account = account;
        this._hasChanged = hasChanged;
    }

    @Override
    protected void writeImpl() {
        this.writeC(6);
        this.writeS(this._account);
        this.writeD(this._hasChanged ? 1 : 0);
    }
}

