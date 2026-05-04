/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills;

public enum EffectUseType {
    START(true, false),
    TICK(true, false),
    NORMAL(false, false),
    NORMAL_INSTANT(true, false),
    SELF(false, true),
    SELF_INSTANT(true, true),
    END(true, false);

    public static final EffectUseType[] VALUES;
    private final boolean _instant;
    private final boolean _self;

    private EffectUseType(boolean instant, boolean self) {
        this._instant = instant;
        this._self = self;
    }

    public boolean isInstant() {
        return this._instant;
    }

    public boolean isSelf() {
        return this._self;
    }

    static {
        VALUES = EffectUseType.values();
    }
}

