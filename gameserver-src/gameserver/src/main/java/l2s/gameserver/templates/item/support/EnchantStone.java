/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.item.support;

import java.util.Set;
import l2s.gameserver.templates.item.ItemGrade;
import l2s.gameserver.templates.item.support.EnchantType;
import l2s.gameserver.templates.item.support.FailResultType;

public class EnchantStone {
    private final int _itemId;
    private final double _chance;
    private final EnchantType _type;
    private final Set<ItemGrade> _grades;
    private final FailResultType _resultType;
    private final int _enchantDropCount;
    private final int _minEnchantLevel;
    private final int _minFullbodyEnchantLevel;
    private final int _maxEnchantLevel;
    private final int _minEnchantStep;
    private final int _maxEnchantStep;

    public EnchantStone(int itemId, double chance, EnchantType type, Set<ItemGrade> grades, FailResultType resultType, int enchantDropCount, int minEnchantLevel, int minFullbodyEnchantLevel, int maxEnchantLevel, int minEnchantStep, int maxEnchantStep) {
        this._itemId = itemId;
        this._chance = chance;
        this._type = type;
        this._grades = grades;
        this._resultType = resultType;
        this._enchantDropCount = enchantDropCount;
        this._minEnchantLevel = minEnchantLevel;
        this._minFullbodyEnchantLevel = minFullbodyEnchantLevel;
        this._maxEnchantLevel = maxEnchantLevel;
        this._minEnchantStep = minEnchantStep;
        this._maxEnchantStep = maxEnchantStep;
    }

    public int getItemId() {
        return this._itemId;
    }

    public double getChance() {
        return this._chance;
    }

    public boolean containsGrade(ItemGrade grade) {
        return this._grades.contains(grade);
    }

    public EnchantType getType() {
        return this._type;
    }

    public FailResultType getResultType() {
        return this._resultType;
    }

    public int getEnchantDropCount() {
        return this._enchantDropCount;
    }

    public double getMinEnchantLevel() {
        return this._minEnchantLevel;
    }

    public double getMinFullbodyEnchantLevel() {
        return this._minFullbodyEnchantLevel;
    }

    public double getMaxEnchantLevel() {
        return this._maxEnchantLevel;
    }

    public int getMinEnchantStep() {
        return this._minEnchantStep;
    }

    public int getMaxEnchantStep() {
        return this._maxEnchantStep;
    }
}

