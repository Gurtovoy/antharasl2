/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item.support;

import java.util.Set;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.support.EnchantType;
import l2s.gameserver.templates.item.support.FailResultType;
import org.napile.primitive.Containers;
import org.napile.primitive.sets.IntSet;
import org.napile.primitive.sets.impl.HashIntSet;

public class EnchantScroll {
    private final int _itemId;
    private final int _minEnchant;
    private final int _maxEnchant;
    private final EnchantType _type;
    private final Set<ItemGrade> _grades;
    private final FailResultType _resultType;
    private final int _enchantDropCount;
    private final int _variation;
    private boolean _showFailEffect;
    private final int _minEnchantStep;
    private final int _maxEnchantStep;
    private IntSet _items = Containers.EMPTY_INT_SET;

    public EnchantScroll(int itemId, int variation, int minEnchant, int maxEnchant, EnchantType type, Set<ItemGrade> grades, FailResultType resultType, int enchantDropCount, boolean showFailEffect, int minEnchantStep, int maxEnchantStep) {
        this._itemId = itemId;
        this._minEnchant = minEnchant;
        this._maxEnchant = maxEnchant;
        this._type = type;
        this._grades = grades;
        this._resultType = resultType;
        this._enchantDropCount = enchantDropCount;
        this._variation = variation;
        this._showFailEffect = showFailEffect;
        this._minEnchantStep = minEnchantStep;
        this._maxEnchantStep = maxEnchantStep;
    }

    public void addItemId(int id) {
        if (this._items.isEmpty()) {
            this._items = new HashIntSet();
        }
        this._items.add(id);
    }

    public int getItemId() {
        return this._itemId;
    }

    public int getMinEnchant() {
        return this._minEnchant;
    }

    public int getMaxEnchant() {
        return this._maxEnchant;
    }

    public boolean containsGrade(ItemGrade grade) {
        return this._grades.contains(grade);
    }

    public IntSet getItems() {
        return this._items;
    }

    public EnchantType getType() {
        return this._type;
    }

    public int getVariationId() {
        return this._variation;
    }

    public FailResultType getResultType() {
        return this._resultType;
    }

    public int getEnchantDropCount() {
        return this._enchantDropCount;
    }

    public boolean showFailEffect() {
        return this._showFailEffect;
    }

    public int getMinEnchantStep() {
        return this._minEnchantStep;
    }

    public int getMaxEnchantStep() {
        return this._maxEnchantStep;
    }
}

