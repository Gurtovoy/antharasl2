/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInfo;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExRpItemLink
extends L2GameServerPacket {
    private ItemInfo _item;

    public ExRpItemLink(ItemInfo item) {
        this._item = item;
    }

    @Override
    protected final void writeImpl() {
        this.writeItemInfo(this._item);
    }
}

