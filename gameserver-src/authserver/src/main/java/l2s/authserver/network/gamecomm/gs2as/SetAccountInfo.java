/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.net.HostInfo
 *  org.apache.commons.lang3.ArrayUtils
 */
package l2s.authserver.network.gamecomm.gs2as;

import l2s.authserver.accounts.SessionManager;
import l2s.authserver.network.gamecomm.GameServer;
import l2s.authserver.network.gamecomm.ReceivablePacket;
import l2s.commons.net.HostInfo;
import org.apache.commons.lang3.ArrayUtils;

public class SetAccountInfo
extends ReceivablePacket {
    private String _account;
    private int _size;
    private int[] _deleteChars;

    @Override
    protected boolean readImpl() {
        this._account = this.readS();
        this._size = this.readC();
        int size = this.readD();
        if (size > 7 || size <= 0) {
            this._deleteChars = ArrayUtils.EMPTY_INT_ARRAY;
        } else {
            this._deleteChars = new int[size];
            for (int i = 0; i < this._deleteChars.length; ++i) {
                this._deleteChars[i] = this.readD();
            }
        }
        return true;
    }

    @Override
    protected void runImpl() {
        GameServer gs = this.getGameServer();
        if (gs.isAuthed()) {
            SessionManager.Session session = SessionManager.getInstance().getSessionByName(this._account);
            if (session == null) {
                return;
            }
            for (HostInfo host : gs.getHosts()) {
                session.getAccount().addAccountInfo(host.getId(), this._size, this._deleteChars);
            }
        }
    }
}

