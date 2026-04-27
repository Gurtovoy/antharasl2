/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.pledge;

public class ClanChangeLeaderRequest {
    private int _clanId;
    private int _newLeaderId;
    private long _time;

    public ClanChangeLeaderRequest(int clanId, int newLeaderId, long time) {
        this._clanId = clanId;
        this._newLeaderId = newLeaderId;
        this._time = time;
    }

    public int getClanId() {
        return this._clanId;
    }

    public int getNewLeaderId() {
        return this._newLeaderId;
    }

    public long getTime() {
        return this._time;
    }
}

