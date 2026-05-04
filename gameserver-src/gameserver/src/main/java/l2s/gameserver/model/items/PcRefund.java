/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.items;

import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemContainer;
import l2s.gameserver.model.items.ItemInstance;

public class PcRefund
extends ItemContainer {
    public PcRefund(Player player) {
    }

    @Override
    protected void onAddItem(ItemInstance item) {
        item.setLocation(ItemInstance.ItemLocation.VOID);
        if (item.getJdbcState().isPersisted()) {
            item.setJdbcState(JdbcEntityState.UPDATED);
            item.update();
        }
        if (this._items.size() > 12) {
            this.destroyItem((ItemInstance)this._items.remove(0));
        }
    }

    @Override
    protected void onModifyItem(ItemInstance item) {
    }

    @Override
    protected void onRemoveItem(ItemInstance item) {
    }

    @Override
    protected void onDestroyItem(ItemInstance item) {
        item.setCount(0L);
        item.delete();
    }

    @Override
    public void clear() {
        this.writeLock();
        try {
            _itemsDAO.delete(this._items);
            this._items.clear();
        }
        finally {
            this.writeUnlock();
        }
    }
}

