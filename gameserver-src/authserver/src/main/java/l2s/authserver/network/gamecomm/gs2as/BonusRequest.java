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

public class BonusRequest
extends ReceivablePacket {
    private static final Logger log = LoggerFactory.getLogger(BonusRequest.class);
    private String account;
    private int bonus;
    private int bonusExpire;

    @Override
    protected boolean readImpl() {
        this.account = this.readS();
        this.bonus = this.readD();
        this.bonusExpire = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Account acc = new Account(this.account);
        acc.restore();
        acc.setBonus(this.bonus);
        acc.setBonusExpire(this.bonusExpire);
        acc.update();
    }
}

