package l2s.gameserver.network.l2.s2c;

import java.util.Map;
import l2s.gameserver.model.items.Inventory;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ShopPreviewInfoPacket
extends L2GameServerPacket {
    private Map<Integer, Integer> _itemlist;

    public ShopPreviewInfoPacket(Map<Integer, Integer> itemlist) {
        this._itemlist = itemlist;
    }

    @Override
    protected void writeImpl() {
        this.writeD(38);
        for (int PAPERDOLL_ID : Inventory.PAPERDOLL_ORDER) {
            this.writeD(this.getFromList(PAPERDOLL_ID));
        }
    }

    private int getFromList(int key) {
        return this._itemlist.get(key) != null ? this._itemlist.get(key) : 0;
    }
}

