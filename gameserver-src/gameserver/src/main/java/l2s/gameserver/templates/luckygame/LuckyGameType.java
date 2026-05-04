package l2s.gameserver.templates.luckygame;

public enum LuckyGameType {
    NONE,
    NORMAL,
    LUXURY;

    public static final LuckyGameType[] VALUES;

    static {
        VALUES = LuckyGameType.values();
    }
}

