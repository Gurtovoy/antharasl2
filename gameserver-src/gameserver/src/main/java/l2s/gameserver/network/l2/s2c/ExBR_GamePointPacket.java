/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBR_GamePointPacket
extends L2GameServerPacket {
    private int _objectId;
    private long _points;

    public ExBR_GamePointPacket(Player player) {
        this._objectId = player.getObjectId();
        this._points = player.getPremiumPoints();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objectId);
        this.writeQ(this._points);
        this.writeD(0);
    }
}

