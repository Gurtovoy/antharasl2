package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.npc.BuyListTemplate;

public class ShopPreviewListPacket
extends L2GameServerPacket {
    private final int _listId;
    private final List<ItemInfo> _itemList;
    private final long _money;

    public ShopPreviewListPacket(BuyListTemplate list, Player player) {
        this._listId = list.getListId();
        this._money = player.getAdena();
        List<TradeItem> tradeList = list.getItems();
        this._itemList = new ArrayList<ItemInfo>(tradeList.size());
        for (TradeItem item : tradeList) {
            if (!item.getItem().isEquipable() || !item.getItem().isArmor() && !item.getItem().isWeapon()) continue;
            this._itemList.add(item);
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(5056);
        this.writeQ(this._money);
        this.writeD(this._listId);
        this.writeH(this._itemList.size());
        for (ItemInfo item : this._itemList) {
            if (!item.getItem().isEquipable()) continue;
            this.writeD(item.getItemId());
            this.writeH(item.getItem().getType2());
            this.writeQ(item.getItem().isEquipable() ? item.getItem().getBodyPart() : 0L);
            this.writeQ(ShopPreviewListPacket.getWearPrice(item.getItem()));
        }
    }

    public static int getWearPrice(ItemTemplate item) {
        switch (item.getGrade()) {
            case D: {
                return 50;
            }
            case C: {
                return 100;
            }
            case B: {
                return 200;
            }
            case A: {
                return 500;
            }
            case S: {
                return 1000;
            }
            case S80: {
                return 2000;
            }
        }
        return 10;
    }
}

