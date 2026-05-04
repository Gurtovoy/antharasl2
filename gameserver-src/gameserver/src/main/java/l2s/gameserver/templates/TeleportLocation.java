package l2s.gameserver.templates;

import l2s.gameserver.geometry.Location;

public class TeleportLocation
extends Location {
    private final int _itemId;
    private final long _price;
    private final int _name;
    private final int[] _castleIds;
    private final boolean _primeHours;
    private final int _questZoneId;

    public TeleportLocation(int itemId, long price, int name, int[] castleIds, boolean primeHours, int questZoneId) {
        this._itemId = itemId;
        this._price = price;
        this._name = name;
        this._castleIds = castleIds;
        this._primeHours = primeHours;
        this._questZoneId = questZoneId;
    }

    public int getItemId() {
        return this._itemId;
    }

    public long getPrice() {
        return this._price;
    }

    public int getName() {
        return this._name;
    }

    public int[] getCastleIds() {
        return this._castleIds;
    }

    public boolean isPrimeHours() {
        return this._primeHours;
    }

    public int getQuestZoneId() {
        return this._questZoneId;
    }
}

