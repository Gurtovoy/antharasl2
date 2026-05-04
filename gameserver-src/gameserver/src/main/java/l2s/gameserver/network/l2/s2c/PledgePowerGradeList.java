/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.pledge.RankPrivs;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgePowerGradeList
extends L2GameServerPacket {
    private RankPrivs[] _privs;

    public PledgePowerGradeList(RankPrivs[] privs) {
        this._privs = privs;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._privs.length);
        for (RankPrivs element : this._privs) {
            this.writeD(element.getRank());
            this.writeD(element.getParty());
        }
    }
}

