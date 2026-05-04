/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.clansearch.base;

public enum ClanSearchSortOrder {
    NONE,
    ASC,
    DESC;


    public static ClanSearchSortOrder valueOf(int value) {
        switch (value) {
            case 1: {
                return ASC;
            }
            case 2: {
                return DESC;
            }
        }
        return NONE;
    }
}

