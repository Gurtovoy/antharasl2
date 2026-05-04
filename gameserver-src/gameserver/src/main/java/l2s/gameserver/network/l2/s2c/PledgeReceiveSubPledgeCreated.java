/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PledgeReceiveSubPledgeCreated
extends L2GameServerPacket {
    private int type;
    private String _name;
    private String leader_name;

    public PledgeReceiveSubPledgeCreated(SubUnit subPledge) {
        this.type = subPledge.getType();
        this._name = subPledge.getName();
        this.leader_name = subPledge.getLeaderName();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(1);
        this.writeD(this.type);
        this.writeS(this._name);
        this.writeS(this.leader_name);
    }
}

