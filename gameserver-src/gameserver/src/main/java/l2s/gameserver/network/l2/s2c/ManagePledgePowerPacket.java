/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.RankPrivs;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.PledgeReceiveUpdatePower;

public class ManagePledgePowerPacket
extends L2GameServerPacket {
    private int _action;
    private int _clanId;
    private int privs;

    public ManagePledgePowerPacket(Player player, int action, int rank) {
        this._clanId = player.getClanId();
        this._action = action;
        RankPrivs temp = player.getClan().getRankPrivs(rank);
        this.privs = temp == null ? 0 : temp.getPrivs();
        player.sendPacket((IBroadcastPacket)new PledgeReceiveUpdatePower(this.privs));
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._clanId);
        this.writeD(this._action);
        this.writeD(this.privs);
    }
}

