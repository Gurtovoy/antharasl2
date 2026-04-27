/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.HashMap;
import java.util.Map;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PartyMemberPositionPacket
extends L2GameServerPacket {
    private final Map<Integer, Location> positions = new HashMap<Integer, Location>();

    public PartyMemberPositionPacket add(Player actor) {
        this.positions.put(actor.getObjectId(), actor.getLoc());
        return this;
    }

    public int size() {
        return this.positions.size();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.positions.size());
        for (Map.Entry<Integer, Location> e : this.positions.entrySet()) {
            this.writeD(e.getKey());
            this.writeD(e.getValue().x);
            this.writeD(e.getValue().y);
            this.writeD(e.getValue().z);
        }
    }
}

