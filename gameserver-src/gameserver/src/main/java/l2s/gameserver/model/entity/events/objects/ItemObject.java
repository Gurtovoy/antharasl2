/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.objects;

public class ItemObject {
    private final int _itemId;
    private final long _count;

    public ItemObject(int itemId, long count) {
        this._itemId = itemId;
        this._count = count;
    }

    public int getItemId() {
        return this._itemId;
    }

    public long getCount() {
        return this._count;
    }
}

