/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.base;

public enum HitCondBonusType {
    AHEAD,
    SIDE,
    BACK,
    HIGH,
    LOW,
    DARK,
    RAIN;

    public static final HitCondBonusType[] VALUES;

    static {
        VALUES = HitCondBonusType.values();
    }
}

