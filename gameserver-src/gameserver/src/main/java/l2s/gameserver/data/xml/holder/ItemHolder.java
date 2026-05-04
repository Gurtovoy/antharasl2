/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.templates.item.ItemTemplate;

public final class ItemHolder
extends AbstractHolder {
    private static final ItemHolder _instance = new ItemHolder();
    private final TIntObjectMap<ItemTemplate> _items = new TIntObjectHashMap();
    private ItemTemplate[] _allTemplates;

    public static ItemHolder getInstance() {
        return _instance;
    }

    private ItemHolder() {
    }

    public void addItem(ItemTemplate template) {
        this._items.put(template.getItemId(), template);
    }

    private void buildFastLookupTable() {
        int highestId = 0;
        for (int id : this._items.keys()) {
            if (id <= highestId) continue;
            highestId = id;
        }
        this._allTemplates = new ItemTemplate[highestId + 1];
        TIntObjectIterator iterator = this._items.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            this._allTemplates[iterator.key()] = (ItemTemplate)iterator.value();
        }
    }

    public ItemTemplate getTemplate(int id) {
        ItemTemplate item = (ItemTemplate)ArrayUtils.valid((Object[])this._allTemplates, (int)id);
        if (item == null) {
            this.warn("Not defined item id : " + id + ", or out of range!", new Exception());
            return null;
        }
        return this._allTemplates[id];
    }

    public ItemTemplate[] getAllTemplates() {
        return this._allTemplates;
    }

    protected void process() {
        this.buildFastLookupTable();
    }

    public int size() {
        return this._items.size();
    }

    public void clear() {
        this._items.clear();
    }
}

