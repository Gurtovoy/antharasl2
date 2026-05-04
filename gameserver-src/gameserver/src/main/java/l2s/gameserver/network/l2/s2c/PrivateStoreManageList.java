/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PrivateStoreManageList
extends L2GameServerPacket {
    private final int _type;
    private final int _sellerId;
    private final long _adena;
    private final boolean _package;
    private final List<TradeItem> _sellList;
    private final Map<Integer, TradeItem> _sellList0;

    public PrivateStoreManageList(int type, Player seller, boolean pkg) {
        ItemInstance[] items;
        this._type = type;
        this._sellerId = seller.getObjectId();
        this._adena = seller.getAdena();
        this._package = pkg;
        this._sellList0 = seller.getSellList(this._package);
        this._sellList = new ArrayList<TradeItem>();
        Iterator<Map.Entry<Integer, TradeItem>> iterator = this._sellList0.entrySet().iterator();
        while (iterator.hasNext()) {
            Map.Entry<Integer, TradeItem> entry = iterator.next();
            TradeItem si = entry.getValue();
            if (si.getCount() <= 0L) {
                iterator.remove();
                continue;
            }
            ItemInstance item = seller.getInventory().getItemByObjectId(si.getObjectId());
            if (item == null) {
                item = seller.getInventory().getItemByItemId(si.getItemId());
            }
            if (item == null || !item.canBePrivateStore(seller) || item.getItemId() == 57) {
                iterator.remove();
                continue;
            }
            si.setCount(Math.min(item.getCount(), si.getCount()));
        }
        block1: for (ItemInstance item : items = seller.getInventory().getItems()) {
            if (!item.canBePrivateStore(seller) || item.getItemId() == 57) continue;
            for (TradeItem si : this._sellList0.values()) {
                if (si.getObjectId() != item.getObjectId()) continue;
                if (si.getCount() == item.getCount()) continue block1;
                TradeItem ti = new TradeItem(item, item.getTemplate().isBlocked(seller, item));
                ti.setCount(item.getCount() - si.getCount());
                this._sellList.add(ti);
                continue block1;
            }
            this._sellList.add(new TradeItem(item, item.getTemplate().isBlocked(seller, item)));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        if (this._type == 1) {
            this.writeD(this._sellerId);
            this.writeD(this._package ? 1 : 0);
            this.writeQ(this._adena);
            this.writeD(this._sellList0.size());
            for (TradeItem si : this._sellList0.values()) {
                this.writeItemInfo(si);
                this.writeQ(si.getOwnersPrice());
                this.writeQ(si.getStorePrice());
            }
            this.writeD(this._sellList.size());
        } else if (this._type == 2) {
            this.writeD(this._sellList.size());
            this.writeD(this._sellList.size());
            for (TradeItem si : this._sellList) {
                this.writeItemInfo(si);
                this.writeQ(si.getStorePrice());
            }
        }
    }
}

