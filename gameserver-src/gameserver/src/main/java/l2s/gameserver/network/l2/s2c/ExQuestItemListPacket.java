package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.LockType;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExQuestItemListPacket
extends L2GameServerPacket {
    private int _size;
    private ItemInstance[] _items;
    private final int _type;
    private LockType _lockType;
    private int[] _lockItems;

    public ExQuestItemListPacket(int type, int size, ItemInstance[] t, LockType lockType, int[] lockItems) {
        this._type = type;
        this._size = size;
        this._items = t;
        this._lockType = lockType;
        this._lockItems = lockItems;
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._type);
        if (this._type == 1) {
            this.writeH(0);
            this.writeD(this._size);
        } else if (this._type == 2) {
            this.writeD(this._size);
            this.writeD(this._size);
            for (ItemInstance temp : this._items) {
                if (!temp.getTemplate().isQuest()) continue;
                this.writeItemInfo(temp);
            }
        }
    }
}

