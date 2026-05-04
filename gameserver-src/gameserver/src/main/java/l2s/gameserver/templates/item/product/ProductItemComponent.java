/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.item.product;

import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.data.ItemData;

public class ProductItemComponent
extends ItemData {
    private final int _weight;
    private final boolean _dropable;

    public ProductItemComponent(int itemId, int count) {
        super(itemId, count);
        ItemTemplate item = ItemHolder.getInstance().getTemplate(itemId);
        if (item != null) {
            this._weight = item.getWeight();
            this._dropable = item.isDropable();
        } else {
            this._weight = 0;
            this._dropable = true;
        }
    }

    public int getWeight() {
        return this._weight;
    }

    public boolean isDropable() {
        return this._dropable;
    }
}

