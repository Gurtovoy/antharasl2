/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 */
package l2s.authserver.network.l2;

import l2s.authserver.Config;
import l2s.commons.util.Rnd;

public class SessionKey {
    public final int playOkID1;
    public final int playOkID2;
    public final int loginOkID1;
    public final int loginOkID2;
    private final int hashCode;

    public SessionKey(int loginOK1, int loginOK2, int playOK1, int playOK2) {
        this.playOkID1 = playOK1;
        this.playOkID2 = playOK2;
        this.loginOkID1 = loginOK1;
        this.loginOkID2 = loginOK2;
        int hashCode = playOK1;
        hashCode *= 17;
        hashCode += playOK2;
        hashCode *= 37;
        if (Config.SHOW_LICENCE) {
            hashCode += loginOK1;
            hashCode *= 51;
            hashCode += loginOK2;
        }
        this.hashCode = hashCode;
    }

    public boolean checkLoginPair(int loginOk1, int loginOk2) {
        return this.loginOkID1 == loginOk1 && this.loginOkID2 == loginOk2;
    }

    public static final SessionKey create() {
        return new SessionKey(Rnd.nextInt(), Rnd.nextInt(), Rnd.nextInt(), Rnd.nextInt());
    }

    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null) {
            return false;
        }
        if (o.getClass() == this.getClass()) {
            SessionKey skey = (SessionKey)o;
            if (this.playOkID1 == skey.playOkID1 && this.playOkID2 == skey.playOkID2) {
                if (Config.SHOW_LICENCE) {
                    return skey.checkLoginPair(this.loginOkID1, this.loginOkID2);
                }
                return true;
            }
        }
        return false;
    }

    public int hashCode() {
        return this.hashCode;
    }

    public String toString() {
        return "[playOkID1: " + this.playOkID1 + " playOkID2: " + this.playOkID2 + " loginOkID1: " + this.loginOkID1 + " loginOkID2: " + this.loginOkID2 + "]";
    }
}

