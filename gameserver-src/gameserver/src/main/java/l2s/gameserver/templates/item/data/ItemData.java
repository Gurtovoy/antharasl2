package l2s.gameserver.templates.item.data;

public class ItemData {
    private final int _id;
    private final long _count;

    public ItemData(int id, long count) {
        this._id = id;
        this._count = count;
    }

    public int getId() {
        return this._id;
    }

    public long getCount() {
        return this._count;
    }
}

