package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.instancemanager.RaidBossSpawnManager;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExRaidBossSpawnInfo
extends L2GameServerPacket {
    private final int[] _aliveBosses = RaidBossSpawnManager.getInstance().getAliveRaidBosees();

    @Override
    protected final void writeImpl() {
        this.writeD(this._aliveBosses.length);
        for (int bossId : this._aliveBosses) {
            this.writeD(bossId);
        }
    }
}

