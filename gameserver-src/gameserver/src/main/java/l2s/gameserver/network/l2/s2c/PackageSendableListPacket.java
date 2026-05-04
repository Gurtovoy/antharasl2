package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.Warehouse;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PackageSendableListPacket
extends L2GameServerPacket {
    private final int _type;
    private int _targetObjectId;
    private long _adena;
    private List<ItemInfo> _itemList;

    public PackageSendableListPacket(int type, int objectId, Player cha) {
        this._type = type;
        this._adena = cha.getAdena();
        this._targetObjectId = objectId;
        ItemInstance[] items = cha.getInventory().getItems();
        Arrays.sort(items, Warehouse.ItemClassComparator.getInstance());
        this._itemList = new ArrayList<ItemInfo>(items.length);
        for (ItemInstance item : items) {
            if (!item.getTemplate().isFreightable()) continue;
            this._itemList.add(new ItemInfo(item, item.getTemplate().isBlocked(cha, item)));
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        if (this._type == 1) {
            this.writeD(this._targetObjectId);
            this.writeQ(this._adena);
            this.writeD(this._itemList.size());
        } else if (this._type == 2) {
            this.writeD(this._itemList.size());
            this.writeD(this._itemList.size());
            for (ItemInfo item : this._itemList) {
                this.writeItemInfo(item);
                this.writeD(item.getObjectId());
            }
        }
    }
}

