/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.napile.primitive.sets.impl.HashIntSet
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import org.napile.primitive.sets.impl.HashIntSet;

public class PrivateStoreBuyList
extends L2GameServerPacket {
    private final int _buyerId;
    private final long _adena;
    private List<TradeItem> _sellList;

    public PrivateStoreBuyList(Player seller, Player buyer) {
        this._adena = seller.getAdena();
        this._buyerId = buyer.getObjectId();
        this._sellList = new ArrayList<TradeItem>();
        ItemInstance[] items = seller.getInventory().getItems();
        HashIntSet addedItems = new HashIntSet();
        for (TradeItem bi : buyer.getBuyList()) {
            TradeItem si = null;
            for (ItemInstance item : items) {
                if (item.getItemId() != bi.getItemId() || !item.canBePrivateStore(seller) || addedItems.contains(item.getObjectId()) || (item.isArmor() || item.isAccessory() || item.isWeapon()) && item.getEnchantLevel() != bi.getEnchantLevel()) continue;
                si = new TradeItem(item);
                si.setOwnersPrice(bi.getOwnersPrice());
                si.setCount(bi.getCount());
                si.setCurrentValue(Math.min(bi.getCount(), item.getCount()));
                addedItems.add(item.getObjectId());
                break;
            }
            if (si == null) {
                si = new TradeItem();
                si.setItemId(bi.getItemId());
                si.setOwnersPrice(bi.getOwnersPrice());
                si.setCount(bi.getCount());
                si.setEnchantLevel(bi.getEnchantLevel());
                si.setCurrentValue(0L);
            }
            this._sellList.add(si);
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._buyerId);
        this.writeQ(this._adena);
        this.writeD(70);
        this.writeD(this._sellList.size());
        for (TradeItem si : this._sellList) {
            this.writeItemInfo(si, si.getCurrentValue());
            this.writeD(si.getObjectId());
            this.writeQ(si.getOwnersPrice());
            this.writeQ(si.getStorePrice());
            this.writeQ(si.getCount());
        }
    }
}

