package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExGMViewQuestItemListPacket
extends L2GameServerPacket {
    private final int _type;
    private int _size;
    private ItemInstance[] _items;
    private int _limit;
    private String _name;

    public ExGMViewQuestItemListPacket(int type, Player player, ItemInstance[] items, int size) {
        this._type = type;
        this._items = items;
        this._size = size;
        this._name = player.getName();
        this._limit = Config.QUEST_INVENTORY_MAXIMUM;
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
                if (!temp.getTemplate().isQuest()) continue;
                this.writeItemInfo(temp);
            }
        }
    }
}

