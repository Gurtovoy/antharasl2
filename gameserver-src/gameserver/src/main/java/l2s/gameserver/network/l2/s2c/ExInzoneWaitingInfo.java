/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.iterator.TIntIntIterator
 *  gnu.trove.map.TIntIntMap
 *  gnu.trove.map.hash.TIntIntHashMap
 */
package l2s.gameserver.network.l2.s2c;

import gnu.trove.iterator.TIntIntIterator;
import gnu.trove.map.TIntIntMap;
import gnu.trove.map.hash.TIntIntHashMap;
import l2s.gameserver.data.xml.holder.InstantZoneHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExInzoneWaitingInfo
extends L2GameServerPacket {
    private final boolean _openWindow;
    private int _currentInzoneID = -1;
    private TIntIntMap _instanceTimes;

    public ExInzoneWaitingInfo(Player player, boolean openWindow) {
        this._openWindow = openWindow;
        this._instanceTimes = new TIntIntHashMap();
        if (player.getActiveReflection() != null) {
            this._currentInzoneID = player.getActiveReflection().getInstancedZoneId();
        }
        for (int i : player.getInstanceReuses().keySet()) {
            int limit = InstantZoneHolder.getInstance().getMinutesToNextEntrance(i, player);
            if (limit <= 0) continue;
            this._instanceTimes.put(i, limit * 60);
        }
    }

    @Override
    protected void writeImpl() {
        this.writeC(this._openWindow);
        this.writeD(this._currentInzoneID);
        this.writeD(this._instanceTimes.size());
        TIntIntIterator iterator = this._instanceTimes.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            this.writeD(iterator.key());
            this.writeD(iterator.value());
        }
    }
}

