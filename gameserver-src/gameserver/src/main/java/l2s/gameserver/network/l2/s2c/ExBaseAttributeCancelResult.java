/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.base.Element;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBaseAttributeCancelResult
extends L2GameServerPacket {
    private boolean _result;
    private int _objectId;
    private Element _element;

    public ExBaseAttributeCancelResult(boolean result, ItemInstance item, Element element) {
        this._result = result;
        this._objectId = item.getObjectId();
        this._element = element;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._result);
        this.writeD(this._objectId);
        this.writeD(this._element.getId());
    }
}

