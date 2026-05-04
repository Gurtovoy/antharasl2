package l2s.gameserver.templates.item.support.variation;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.gameserver.templates.item.support.variation.VariationFee;

public class VariationGroup {
    private final int _id;
    private final TIntObjectMap<VariationFee> _fees = new TIntObjectHashMap();

    public VariationGroup(int id) {
        this._id = id;
    }

    public int getId() {
        return this._id;
    }

    public void addFee(VariationFee fee) {
        this._fees.put(fee.getStoneId(), fee);
    }

    public VariationFee getFee(int id) {
        return (VariationFee)this._fees.get(id);
    }

    public VariationFee[] getFees() {
        return (VariationFee[])this._fees.values(new VariationFee[this._fees.size()]);
    }
}

