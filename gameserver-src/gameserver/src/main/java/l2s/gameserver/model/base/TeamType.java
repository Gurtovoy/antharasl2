package l2s.gameserver.model.base;

import java.util.Arrays;

public enum TeamType {
    NONE,
    BLUE,
    RED;

    public static TeamType[] VALUES;

    public int ordinalWithoutNone() {
        return this.ordinal() - 1;
    }

    public TeamType revert() {
        return this == BLUE ? RED : (this == RED ? BLUE : NONE);
    }

    static {
        VALUES = Arrays.copyOfRange(TeamType.values(), 1, 3);
    }
}

