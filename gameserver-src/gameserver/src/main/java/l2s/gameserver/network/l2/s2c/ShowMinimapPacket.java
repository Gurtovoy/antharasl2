/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ShowMinimapPacket
extends L2GameServerPacket {
    private int _mapId;

    public ShowMinimapPacket(Player player, int mapId) {
        this._mapId = mapId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._mapId);
        this.writeC(0);
    }
}

