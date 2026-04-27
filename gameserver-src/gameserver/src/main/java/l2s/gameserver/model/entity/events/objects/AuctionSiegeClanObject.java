/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.pledge.Clan;

public class AuctionSiegeClanObject
extends SiegeClanObject {
    private long _bid;

    public AuctionSiegeClanObject(String type, Clan clan, long param) {
        this(type, clan, param, System.currentTimeMillis());
    }

    public AuctionSiegeClanObject(String type, Clan clan, long param, long date) {
        super(type, clan, param, date);
        this._bid = param;
    }

    @Override
    public long getParam() {
        return this._bid;
    }

    public void setParam(long param) {
        this._bid = param;
    }
}

