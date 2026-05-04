/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item.support.variation;

public class VariationOption {
    private final int _id;
    private final double _chance;

    public VariationOption(int id, double chance) {
        this._id = id;
        this._chance = chance;
    }

    public int getId() {
        return this._id;
    }

    public double getChance() {
        return this._chance;
    }
}

