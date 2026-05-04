package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class GMViewItemListPacket
extends L2GameServerPacket {
    private final int _type;
    private int _size;
    private ItemInstance[] _items;
    private int _limit;
    private String _name;
    private Player _player;

    public GMViewItemListPacket(int type, Player cha, ItemInstance[] items, int size) {
        this._type = type;
        this._size = size;
        this._items = items;
        this._name = cha.getName();
        this._limit = cha.getInventoryLimit();
        this._player = cha;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        if (this._type == 1) {
            this.writeS(this._name);
            this.writeD(this._limit);
            this.writeD(this._size);
        } else if (this._type == 2) {
            this.writeD(this._size);
            this.writeD(this._size);
            for (ItemInstance temp : this._items) {
                if (temp.getTemplate().isQuest()) continue;
                this.writeItemInfo(this._player, temp);
            }
        }
    }
}

