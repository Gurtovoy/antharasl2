/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExReplyPostItemList
extends L2GameServerPacket {
    private final int _type;
    private final List<ItemInfo> _itemsList = new ArrayList<ItemInfo>();

    public ExReplyPostItemList(int type, Player activeChar) {
        ItemInstance[] items;
        this._type = type;
        for (ItemInstance item : items = activeChar.getInventory().getItems()) {
            if (!item.canBeTraded(activeChar)) continue;
            this._itemsList.add(new ItemInfo(item, item.getTemplate().isBlocked(activeChar, item)));
        }
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._type);
        this.writeD(this._itemsList.size());
        if (this._type == 2) {
            this.writeD(this._itemsList.size());
            for (ItemInfo item : this._itemsList) {
                this.writeItemInfo(item);
            }
        }
    }
}

