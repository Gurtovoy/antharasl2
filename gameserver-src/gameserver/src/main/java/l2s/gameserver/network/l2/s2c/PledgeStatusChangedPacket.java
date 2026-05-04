/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeStatusChangedPacket
extends L2GameServerPacket {
    private final int leader_id;
    private final int clan_id;
    private final int level;
    private final int crestId;
    private final int allyId;

    public PledgeStatusChangedPacket(Clan clan) {
        this.leader_id = clan.getLeaderId();
        this.clan_id = clan.getClanId();
        this.level = clan.getLevel();
        this.crestId = clan.getCrestId();
        this.allyId = clan.getAllyId();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(Config.REQUEST_ID);
        this.writeD(this.leader_id);
        this.writeD(this.clan_id);
        this.writeD(this.crestId);
        this.writeD(this.allyId);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
    }
}

