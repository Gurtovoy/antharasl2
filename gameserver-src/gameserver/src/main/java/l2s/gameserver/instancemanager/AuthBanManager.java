/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.ban.BanManager
 */
package l2s.gameserver.instancemanager;

import l2s.commons.ban.BanManager;

public class AuthBanManager
extends BanManager {
    private static final AuthBanManager INSTANCE = new AuthBanManager();

    public static AuthBanManager getInstance() {
        return INSTANCE;
    }
}

