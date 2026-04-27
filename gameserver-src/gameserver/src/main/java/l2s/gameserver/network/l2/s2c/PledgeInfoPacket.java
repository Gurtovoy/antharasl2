/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.Config;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeInfoPacket
extends L2GameServerPacket {
    private int clan_id;
    private String clan_name;
    private String ally_name;

    public PledgeInfoPacket(Clan clan) {
        this.clan_id = clan.getClanId();
        this.clan_name = clan.getName();
        this.ally_name = clan.getAlliance() == null ? "" : clan.getAlliance().getAllyName();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(Config.REQUEST_ID);
        this.writeD(this.clan_id);
        this.writeS(this.clan_name);
        this.writeS(this.ally_name);
    }
}

