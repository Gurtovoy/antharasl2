/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item;

import l2s.gameserver.templates.item.data.ItemData;

public final class StartItem
extends ItemData {
    private final boolean _equiped;
    private final int _enchantLevel;

    public StartItem(int id, long count, boolean equiped, int enchantLevel) {
        super(id, count);
        this._equiped = equiped;
        this._enchantLevel = enchantLevel;
    }

    public boolean isEquiped() {
        return this._equiped;
    }

    public int getEnchantLevel() {
        return this._enchantLevel;
    }
}

