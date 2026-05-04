/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.LockType;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ItemListPacket
extends L2GameServerPacket {
    private final int _size;
    private final ItemInstance[] _items;
    private final boolean _showWindow;
    private final int _type;
    private LockType _lockType;
    private int[] _lockItems;
    private Player _player;
    private final int _specialItemCount = 0;

    public ItemListPacket(int type, Player player, int size, ItemInstance[] items, boolean showWindow, LockType lockType, int[] lockItems) {
        this._type = type;
        this._player = player;
        this._size = size;
        this._items = items;
        this._showWindow = showWindow;
        this._lockType = lockType;
        this._lockItems = lockItems;
    }

    @Override
    protected final void writeImpl() {
        this.writeC(this._type);
        if (this._type == 1) {
            this.writeH(this._showWindow);
            this.writeH(0);
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

