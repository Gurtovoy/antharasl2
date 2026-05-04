/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.base;

public enum PledgeAttendanceType {
    NOT_ACQUIRED,
    ACQUIRED,
    NEW_RECRUIT;

    public static PledgeAttendanceType[] VALUES;

    static {
        VALUES = PledgeAttendanceType.values();
    }
}

