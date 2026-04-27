/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.napile.primitive.sets.IntSet
 *  org.napile.primitive.sets.impl.HashIntSet
 */
package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.pledge.Clan;
import org.napile.primitive.sets.IntSet;
import org.napile.primitive.sets.impl.HashIntSet;

public class CMGSiegeClanObject
extends SiegeClanObject {
    private IntSet _players = new HashIntSet();
    private long _param;

    public CMGSiegeClanObject(String type, Clan clan, long param, long date) {
        super(type, clan, param, date);
        this._param = param;
    }

    public CMGSiegeClanObject(String type, Clan clan, long param) {
        super(type, clan, param);
        this._param = param;
    }

    public void addPlayer(int objectId) {
        this._players.add(objectId);
    }

    @Override
    public long getParam() {
        return this._param;
    }

    @Override
    public boolean isParticle(Player player) {
        return this._players.contains(player.getObjectId());
    }

    @Override
    public void setEvent(boolean start, SiegeEvent<?, ?> event) {
        for (int i : this._players.toArray()) {
            Player player = GameObjectsStorage.getPlayer(i);
            if (player == null) continue;
            if (start) {
                player.addEvent(event);
            } else {
                player.removeEvent(event);
            }
            player.broadcastCharInfo();
        }
    }

    public void setParam(long param) {
        this._param = param;
    }

    public IntSet getPlayers() {
        return this._players;
    }
}

