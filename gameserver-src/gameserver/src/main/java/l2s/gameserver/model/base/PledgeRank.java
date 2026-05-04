/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.base;

public enum PledgeRank {
    VAGABOND,
    VASSAL,
    HEIR,
    KNIGHT,
    WISEMAN,
    BARON,
    VISCOUNT,
    COUNT,
    MARQUIS,
    DUKE,
    GRAND_DUKE,
    DISTINGUISHED_KING,
    EMPEROR;

    public static final PledgeRank[] VALUES;

    static {
        VALUES = PledgeRank.values();
    }
}

