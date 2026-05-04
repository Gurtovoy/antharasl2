/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item;

public enum ItemQuality {
    COMMON,
    BOUND,
    NORMAL,
    MASTERWORK,
    BLESSED,
    RB;

    public static final ItemQuality[] VALUES;

    static {
        VALUES = ItemQuality.values();
    }
}

