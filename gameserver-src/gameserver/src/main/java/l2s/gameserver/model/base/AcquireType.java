/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.base;

public enum AcquireType {
    NORMAL(0),
    FISHING(1),
    CLAN(2),
    SUB_UNIT(3),
    GENERAL(11),
    HERO(13),
    GM(14),
    MULTICLASS(20),
    CUSTOM;

    public static final AcquireType[] VALUES;
    private final int _id;

    private AcquireType(int id) {
        this._id = id;
    }

    private AcquireType() {
        this._id = this.ordinal();
    }

    public int getId() {
        return this._id;
    }

    public static AcquireType getById(int id) {
        for (AcquireType at : VALUES) {
            if (at.getId() != id) continue;
            return at;
        }
        return null;
    }

    static {
        VALUES = AcquireType.values();
    }
}

