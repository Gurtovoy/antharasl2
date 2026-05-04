package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class SpawnItemPacket
extends L2GameServerPacket {
    private int _objectId;
    private int _itemId;
    private int _x;
    private int _y;
    private int _z;
    private int _stackable;
    private long _count;
    private final int _enchantLevel;
    private final boolean _augmented;
    private final int _ensoulCount;

    public SpawnItemPacket(ItemInstance item) {
        this._objectId = item.getObjectId();
        this._itemId = item.getItemId();
        this._x = item.getX();
        this._y = item.getY();
        this._z = item.getZ();
        this._stackable = item.isStackable() ? 1 : 0;
        this._count = item.getCount();
        this._enchantLevel = item.getEnchantLevel();
        this._augmented = item.isAugmented();
        this._ensoulCount = item.getNormalEnsouls().length + item.getSpecialEnsouls().length;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._itemId);
        this.writeD(this._x);
        this.writeD(this._y);
        this.writeD(this._z);
        this.writeD(this._stackable);
        this.writeQ(this._count);
        this.writeD(0);
        this.writeC(this._enchantLevel);
        this.writeC(this._augmented);
        this.writeC(this._ensoulCount);
    }
}

