/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.reward;

public enum RewardType {
    RATED_GROUPED,
    NOT_RATED_NOT_GROUPED,
    NOT_RATED_GROUPED,
    SWEEP,
    EVENT_GROUPED;

    public static final RewardType[] VALUES;

    static {
        VALUES = RewardType.values();
    }
}

