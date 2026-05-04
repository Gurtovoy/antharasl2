/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.npc;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.items.TradeItem;

public final class BuyListTemplate {
    private final int _listId;
    private final int _npcId;
    private final int _id;
    private final int _baseMarkup;
    private final List<TradeItem> _items = new ArrayList<TradeItem>();

    public BuyListTemplate(int npcId, int id, int baseMarkup) {
        this._listId = this.hashCode();
        this._npcId = npcId;
        this._id = id;
        this._baseMarkup = baseMarkup;
    }

    public int getListId() {
        return this._listId;
    }

    public int getNpcId() {
        return this._npcId;
    }

    public int getId() {
        return this._id;
    }

    public int getBaseMarkup() {
        return this._baseMarkup;
    }

    public void addItem(TradeItem item) {
        this._items.add(item);
    }

    public synchronized List<TradeItem> getItems() {
        int currentTime = (int)(System.currentTimeMillis() / 60000L);
        ArrayList<TradeItem> result = new ArrayList<TradeItem>();
        for (TradeItem ti : this._items) {
            if (ti.isCountLimited()) {
                if (ti.getCurrentValue() < ti.getCount() && ti.getLastRechargeTime() + ti.getRechargeTime() <= currentTime) {
                    ti.setLastRechargeTime(currentTime);
                    ti.setCurrentValue(ti.getCount());
                }
                if (ti.getCurrentValue() == 0L) continue;
            }
            result.add(ti);
        }
        return result;
    }

    public TradeItem getItemByItemId(int itemId) {
        for (TradeItem item : this._items) {
            if (item.getItemId() != itemId) continue;
            return item;
        }
        return null;
    }

    public synchronized void updateItems(List<TradeItem> items) {
        for (TradeItem item : items) {
            TradeItem ti = this.getItemByItemId(item.getItemId());
            if (!ti.isCountLimited()) continue;
            ti.setCurrentValue(Math.max(ti.getCurrentValue() - item.getCount(), 0L));
        }
    }

    public void refresh() {
        for (TradeItem ti : this._items) {
            if (!ti.isCountLimited()) continue;
            ti.setLastRechargeTime((int)(System.currentTimeMillis() / 60000L));
            ti.setCurrentValue(ti.getCount());
        }
    }

    public BuyListTemplate clone() {
        BuyListTemplate template = new BuyListTemplate(this.getNpcId(), this.getId(), this.getBaseMarkup());
        for (TradeItem item : this.getItems()) {
            template.addItem(item.clone());
        }
        return template;
    }
}

