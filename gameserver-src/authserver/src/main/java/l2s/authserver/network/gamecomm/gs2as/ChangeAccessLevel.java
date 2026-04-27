/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.accounts.Account;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ChangeAccessLevel
extends ReceivablePacket {
    public static final Logger _log = LoggerFactory.getLogger(ChangeAccessLevel.class);
    private String account;
    private int level;
    private int banExpire;

    @Override
    protected boolean readImpl() {
        this.account = this.readS();
        this.level = this.readD();
        this.banExpire = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Account acc = new Account(this.account);
        acc.restore();
        acc.setAccessLevel(this.level);
        acc.setBanExpire(this.banExpire);
        acc.update();
    }
}

