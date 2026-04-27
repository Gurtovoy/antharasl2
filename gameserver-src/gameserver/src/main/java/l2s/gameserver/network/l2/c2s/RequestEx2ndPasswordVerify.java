/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestEx2ndPasswordVerify
extends L2GameClientPacket {
    private String _password;

    @Override
    protected boolean readImpl() {
        this._password = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        if (!Config.EX_SECOND_AUTH_ENABLED) {
            return;
        }
        ((GameClient)this.getClient()).getSecondaryAuth().checkPassword(this._password, false);
    }
}

