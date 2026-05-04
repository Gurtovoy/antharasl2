/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.model.items.Warehouse;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PrivateStoreBuyManageList
extends L2GameServerPacket {
    private final int _type;
    private final int _buyerId;
    private final long _adena;
    private final List<TradeItem> _buyList0;
    private final List<TradeItem> _buyList;

    public PrivateStoreBuyManageList(int type, Player buyer) {
        this._type = type;
        this._buyerId = buyer.getObjectId();
        this._adena = buyer.getAdena();
        this._buyList0 = buyer.getBuyList();
        this._buyList = new ArrayList<TradeItem>();
        ItemInstance[] items = buyer.getInventory().getItems();
        Arrays.sort(items, Warehouse.ItemClassComparator.getInstance());
        for (ItemInstance item : items) {
            if (!item.canBePrivateStore(buyer) || item.getItemId() == 57) continue;
            TradeItem bi = new TradeItem(item, item.getTemplate().isBlocked(buyer, item));
            this._buyList.add(bi);
            bi.setObjectId(0);
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        if (this._type == 1) {
            this.writeD(this._buyerId);
            this.writeQ(this._adena);
            this.writeD(this._buyList0.size());
            for (TradeItem bi : this._buyList0) {
                this.writeItemInfo(bi);
                this.writeQ(bi.getOwnersPrice());
                this.writeQ(bi.getStorePrice());
                this.writeQ(bi.getCount());
            }
            this.writeD(this._buyList.size());
        } else if (this._type == 2) {
            this.writeD(this._buyList.size());
            this.writeD(this._buyList.size());
            for (TradeItem bi : this._buyList) {
                this.writeItemInfo(bi);
                this.writeQ(bi.getStorePrice());
            }
        }
    }
}

