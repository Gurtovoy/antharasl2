/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.npc;

public enum WalkerRouteType {
    LENGTH,
    ROUND,
    RANDOM,
    DELETE,
    FINISH;

    public static final WalkerRouteType[] VALUES;

    static {
        VALUES = WalkerRouteType.values();
    }
}

