/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.clansearch.base;

public enum ClanSearchPlayerSortType {
    SORT_TYPE_NONE,
    SORT_TYPE_NAME,
    SORT_TYPE_SEARCH_TYPE,
    SORT_TYPE_ROLE,
    SORT_TYPE_LEVEL;

    public static final ClanSearchPlayerSortType[] VALUES;

    public static ClanSearchPlayerSortType valueOf(int value) {
        if (value < VALUES.length) {
            return VALUES[value];
        }
        return SORT_TYPE_NONE;
    }

    static {
        VALUES = ClanSearchPlayerSortType.values();
    }
}

