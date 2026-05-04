/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item;

public enum ItemFlags {
    DESTROYABLE(true),
    DROPABLE(true),
    FREIGHTABLE(false),
    ENCHANTABLE(true),
    SELLABLE(true),
    TRADEABLE(true),
    STOREABLE(true),
    APPEARANCEABLE(true),
    PRIVATESTOREABLE(true),
    ENSOULABLE(true);

    public static final ItemFlags[] VALUES;
    private final int _mask;
    private final boolean _defaultValue;

    private ItemFlags(boolean defaultValue) {
        this._defaultValue = defaultValue;
        this._mask = 1 << this.ordinal();
    }

    public int mask() {
        return this._mask;
    }

    public boolean getDefaultValue() {
        return this._defaultValue;
    }

    static {
        VALUES = ItemFlags.values();
    }
}

