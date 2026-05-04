package l2s.gameserver.templates.item.support;

public class MerchantGuard {
    private int _itemId;
    private int _npcId;
    private int _max;

    public MerchantGuard(int itemId, int npcId, int max) {
        this._itemId = itemId;
        this._npcId = npcId;
        this._max = max;
    }

    public int getItemId() {
        return this._itemId;
    }

    public int getNpcId() {
        return this._npcId;
    }

    public int getMax() {
        return this._max;
    }
}

