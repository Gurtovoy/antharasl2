/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collection;
import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.model.clansearch.ClanSearchPlayer;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPledgeWaitingList
extends L2GameServerPacket {
    private final Collection<ClanSearchPlayer> _applicants;

    public ExPledgeWaitingList(int clanId) {
        this._applicants = ClanSearchManager.getInstance().applicantsCollection(clanId);
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._applicants.size());
        for (ClanSearchPlayer applicant : this._applicants) {
            this.writeD(applicant.getCharId());
            this.writeS(applicant.getName());
            this.writeD(applicant.getClassId());
            this.writeD(applicant.getLevel());
        }
    }
}

