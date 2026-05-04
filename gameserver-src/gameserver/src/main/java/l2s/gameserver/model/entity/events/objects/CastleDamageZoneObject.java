/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.model.entity.events.objects.ZoneObject;

public class CastleDamageZoneObject
extends ZoneObject {
    private final long _price;

    public CastleDamageZoneObject(String name, long price) {
        super(name);
        this._price = price;
    }

    public long getPrice() {
        return this._price;
    }
}

