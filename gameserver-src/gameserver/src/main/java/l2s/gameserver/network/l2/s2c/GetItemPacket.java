package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class GetItemPacket
extends L2GameServerPacket {
    private int _playerId;
    private int _itemObjId;
    private Location _loc;

    public GetItemPacket(ItemInstance item, int playerId) {
        this._itemObjId = item.getObjectId();
        this._loc = item.getLoc();
        this._playerId = playerId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._playerId);
        this.writeD(this._itemObjId);
        this.writeD(this._loc.x);
        this.writeD(this._loc.y);
        this.writeD(this._loc.z);
    }
}

