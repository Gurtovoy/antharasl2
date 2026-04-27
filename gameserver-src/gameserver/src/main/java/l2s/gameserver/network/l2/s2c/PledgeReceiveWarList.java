/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeReceiveWarList
extends L2GameServerPacket {
    private Clan _clan;
    private int _state;
    private int _page;

    public PledgeReceiveWarList(Clan clan, int state, int page) {
        this._clan = clan;
        this._page = page;
        this._state = state;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._page);
        Collection<ClanWar> wars = this._clan.getWars().valueCollection();
        this.writeD(wars.size());
        for (ClanWar war : wars) {
            this.writeS(war.getOpposingClan(this._clan).getName());
            this.writeD(war.getClanWarState(this._clan).ordinal());
            this.writeD(war.getPeriodDuration());
            this.writeD(war.getPointDiff(this._clan));
            this.writeD(war.calculateWarProgress(this._clan).ordinal());
            this.writeD(war.getKillToStart());
        }
    }
}

