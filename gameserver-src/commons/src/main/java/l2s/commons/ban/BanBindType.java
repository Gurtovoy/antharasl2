package l2s.commons.ban;

public enum BanBindType {
    LOGIN(true, true),
    IP(true, true),
    HWID(true, true),
    PLAYER(false, true),
    CHAT(false, true);

    public static final BanBindType[] VALUES;
    private final boolean auth;
    private final boolean game;

    private BanBindType(boolean auth, boolean game) {
        this.auth = auth;
        this.game = game;
    }

    public boolean isAuth() {
        return this.auth;
    }

    public boolean isGame() {
        return this.game;
    }

    static {
        VALUES = BanBindType.values();
    }
}

