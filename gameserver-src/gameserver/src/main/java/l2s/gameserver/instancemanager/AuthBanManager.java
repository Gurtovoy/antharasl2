package l2s.gameserver.instancemanager;

import l2s.commons.ban.BanManager;

public class AuthBanManager
extends BanManager {
    private static final AuthBanManager INSTANCE = new AuthBanManager();

    public static AuthBanManager getInstance() {
        return INSTANCE;
    }
}

