/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item.support.variation;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.templates.item.support.variation.VariationCategory;

public class VariationInfo {
    private final int _id;
    private final List<VariationCategory> _categories = new ArrayList<VariationCategory>();

    public VariationInfo(int id) {
        this._id = id;
    }

    public int getId() {
        return this._id;
    }

    public void addCategory(VariationCategory category) {
        this._categories.add(category);
    }

    public VariationCategory[] getCategories() {
        return this._categories.toArray(new VariationCategory[this._categories.size()]);
    }
}

