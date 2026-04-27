/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.ban.BanBindType
 */
package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.AuthBanManager;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import l2s.commons.ban.BanBindType;

public class UnbanRequest
extends ReceivablePacket {
    private BanBindType bindType;
    private String bindValue;

    @Override
    protected boolean readImpl() {
        try {
            this.bindType = BanBindType.VALUES[this.readC()];
        }
        catch (Exception e) {
            return false;
        }
        this.bindValue = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        AuthBanManager.getInstance().removeBan(this.bindType, this.bindValue);
    }
}

