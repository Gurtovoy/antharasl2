package l2s.gameserver.templates.item.support.variation;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.templates.item.support.variation.VariationOption;

public class VariationCategory {
    private final double _probability;
    private final List<VariationOption> _options = new ArrayList<VariationOption>();

    public VariationCategory(double probability) {
        this._probability = probability;
    }

    public double getProbability() {
        return this._probability;
    }

    public void addOption(VariationOption option) {
        this._options.add(option);
    }

    public VariationOption[] getOptions() {
        return this._options.toArray(new VariationOption[this._options.size()]);
    }
}

