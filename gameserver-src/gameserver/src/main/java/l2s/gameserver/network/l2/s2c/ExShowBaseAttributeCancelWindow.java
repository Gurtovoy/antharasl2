/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExShowBaseAttributeCancelWindow
extends L2GameServerPacket {
    private final List<ItemInstance> _items = new ArrayList<ItemInstance>();

    public ExShowBaseAttributeCancelWindow(Player activeChar) {
        for (ItemInstance item : activeChar.getInventory().getItems()) {
            if (item.getAttributeElement() == Element.NONE || !item.canBeEnchanted() || ExShowBaseAttributeCancelWindow.getAttributeRemovePrice(item) == 0L) continue;
            this._items.add(item);
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._items.size());
        for (ItemInstance item : this._items) {
            this.writeD(item.getObjectId());
            this.writeQ(ExShowBaseAttributeCancelWindow.getAttributeRemovePrice(item));
        }
    }

    public static long getAttributeRemovePrice(ItemInstance item) {
        switch (item.getGrade()) {
            case S: {
                return item.getTemplate().getType2() == 0 ? 50000L : 40000L;
            }
            case S80: {
                return item.getTemplate().getType2() == 0 ? 100000L : 80000L;
            }
            case S84: {
                return item.getTemplate().getType2() == 0 ? 200000L : 160000L;
            }
            case R: {
                return item.getTemplate().getType2() == 0 ? 250000L : 240000L;
            }
            case R95: {
                return item.getTemplate().getType2() == 0 ? 300000L : 280000L;
            }
            case R99: {
                return item.getTemplate().getType2() == 0 ? 350000L : 320000L;
            }
        }
        return 0L;
    }
}

