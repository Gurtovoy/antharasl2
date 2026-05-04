/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.base;

public enum Sex {
    MALE,
    FEMALE;

    public static final Sex[] VALUES;

    public Sex revert() {
        switch (this) {
            case MALE: {
                return FEMALE;
            }
            case FEMALE: {
                return MALE;
            }
        }
        return this;
    }

    static {
        VALUES = Sex.values();
    }
}

