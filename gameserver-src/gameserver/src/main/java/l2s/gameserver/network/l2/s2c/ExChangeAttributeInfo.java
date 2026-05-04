package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExChangeAttributeInfo
extends L2GameServerPacket {
    private int _crystalItemId;
    private int _attributes;
    private int _itemObjId;

    public ExChangeAttributeInfo(int crystalItemId, ItemInstance item) {
        this._crystalItemId = crystalItemId;
        this._attributes = 0;
        for (Element e : Element.VALUES) {
            if (e == item.getAttackElement()) continue;
            this._attributes |= e.getMask();
        }
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._crystalItemId);
        this.writeD(this._attributes);
        this.writeD(this._itemObjId);
    }
}

