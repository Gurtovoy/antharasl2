/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.components;

public enum SysString {
    PASSENGER_BOAT_INFO(801),
    PREVIOUS(1037),
    NEXT(1038);

    private static final SysString[] VALUES;
    private final int _id;

    private SysString(int i) {
        this._id = i;
    }

    public int getId() {
        return this._id;
    }

    public static SysString valueOf2(String id) {
        for (SysString m : VALUES) {
            if (!m.name().equals(id)) continue;
            return m;
        }
        return null;
    }

    public static SysString valueOf(int id) {
        for (SysString m : VALUES) {
            if (m.getId() != id) continue;
            return m;
        }
        return null;
    }

    static {
        VALUES = SysString.values();
    }
}

