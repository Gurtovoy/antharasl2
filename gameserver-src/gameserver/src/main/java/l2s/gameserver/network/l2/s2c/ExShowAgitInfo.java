/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.entity.residence.clanhall.NormalClanHall;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.tables.ClanTable;

public class ExShowAgitInfo
extends L2GameServerPacket {
    private final List<AgitInfo> _infos;

    public ExShowAgitInfo() {
        List<NormalClanHall> clanHalls = ResidenceHolder.getInstance().getResidenceList(NormalClanHall.class);
        this._infos = new ArrayList<AgitInfo>(clanHalls.size());
        clanHalls.forEach(clanHall -> {
            int ch_id = clanHall.getId();
            int getType = clanHall.getClanHallType().ordinal();
            Clan clan = ClanTable.getInstance().getClan(clanHall.getOwnerId());
            String clan_name = clanHall.getOwnerId() == 0 || clan == null ? "" : clan.getName();
            String leader_name = clanHall.getOwnerId() == 0 || clan == null ? "" : clan.getLeaderName();
            this._infos.add(new AgitInfo(clan_name, leader_name, ch_id, getType));
        });
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._infos.size());
        this._infos.forEach(info -> {
            this.writeD(info.ch_id);
            this.writeS(info.clan_name);
            this.writeS(info.leader_name);
            this.writeD(info.getType);
        });
    }

    static class AgitInfo {
        public String clan_name;
        public String leader_name;
        public int ch_id;
        public int getType;

        public AgitInfo(String clan_name, String leader_name, int ch_id, int lease) {
            this.clan_name = clan_name;
            this.leader_name = leader_name;
            this.ch_id = ch_id;
            this.getType = lease;
        }
    }
}

