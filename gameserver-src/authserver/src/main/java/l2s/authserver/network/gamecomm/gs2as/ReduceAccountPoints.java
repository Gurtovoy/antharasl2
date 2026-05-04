package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.accounts.Account;
import l2s.authserver.network.gamecomm.ReceivablePacket;

public class ReduceAccountPoints
extends ReceivablePacket {
    private String account;
    private int count;

    @Override
    protected boolean readImpl() {
        this.account = this.readS();
        this.count = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Account.reducePoints(this.account, this.count);
    }
}

