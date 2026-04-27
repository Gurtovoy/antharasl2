/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExCuriousHouseMemberUpdate
extends L2GameServerPacket {
    private Player _player;

    public ExCuriousHouseMemberUpdate(Player player) {
        this._player = player;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._player.getObjectId());
        this.writeD(this._player.getMaxHp());
        this.writeD(this._player.getMaxCp());
        this.writeD((int)this._player.getCurrentHp());
        this.writeD((int)this._player.getCurrentCp());
    }
}

