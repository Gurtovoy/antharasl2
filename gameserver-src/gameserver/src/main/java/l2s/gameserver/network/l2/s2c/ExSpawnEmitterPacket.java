/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExSpawnEmitterPacket
extends L2GameServerPacket {
    private int _monsterObjId;
    private int _playerObjId;

    public ExSpawnEmitterPacket(NpcInstance monster, Player player) {
        this._playerObjId = player.getObjectId();
        this._monsterObjId = monster.getObjectId();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._monsterObjId);
        this.writeD(this._playerObjId);
        this.writeD(0);
    }
}

