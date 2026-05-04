package l2s.gameserver.templates.item.support.variation;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.gameserver.templates.item.support.variation.VariationInfo;

public class VariationStone {
    private final int _id;
    private final TIntObjectMap<VariationInfo> _variations = new TIntObjectHashMap();

    public VariationStone(int id) {
        this._id = id;
    }

    public int getId() {
        return this._id;
    }

    public void addVariation(VariationInfo variation) {
        this._variations.put(variation.getId(), variation);
    }

    public VariationInfo getVariation(int id) {
        return (VariationInfo)this._variations.get(id);
    }

    public VariationInfo[] getVariations() {
        return (VariationInfo[])this._variations.values(new VariationInfo[this._variations.size()]);
    }
}

