package l2s.gameserver.model.actor.instances.player;

public class PremiumItem {
    private final int _receiveTime;
    private final int _itemId;
    private long _itemCount;
    private final String _sender;

    public PremiumItem(int receiveTime, int itemId, long itemCount, String sender) {
        this._receiveTime = receiveTime;
        this._itemId = itemId;
        this._itemCount = itemCount;
        this._sender = sender;
    }

    public PremiumItem(int itemId, long itemCount, String sender) {
        this((int)(System.currentTimeMillis() / 1000L), itemId, itemCount, sender);
    }

    public int getReceiveTime() {
        return this._receiveTime;
    }

    public int getItemId() {
        return this._itemId;
    }

    public void setItemCount(long value) {
        this._itemCount = value;
    }

    public long getItemCount() {
        return this._itemCount;
    }

    public String getSender() {
        return this._sender;
    }

    public String toString() {
        return "PremiumItem[receiveTime=" + this._receiveTime + ", itemId=" + this._itemId + ", itemCount=" + this._itemCount + ", sender=" + this._sender + "]";
    }
}

