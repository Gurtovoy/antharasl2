/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.base;

public enum TransformType {
    COMBAT(true),
    NON_COMBAT(false),
    MODE_CHANGE(true),
    RIDING_MODE(false),
    FLYING(true),
    PURE_STAT(true),
    CURSED(true);

    public static final TransformType[] VALUES;
    private final boolean _canAttack;

    private TransformType(boolean canAttack) {
        this._canAttack = canAttack;
    }

    public boolean isCanAttack() {
        return this._canAttack;
    }

    static {
        VALUES = TransformType.values();
    }
}

