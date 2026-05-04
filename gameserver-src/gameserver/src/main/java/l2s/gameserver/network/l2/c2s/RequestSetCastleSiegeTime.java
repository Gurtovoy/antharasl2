/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.CastleSiegeInfoPacket;

public class RequestSetCastleSiegeTime
extends L2GameClientPacket {
    private int _id;
    private int _time;

    @Override
    protected boolean readImpl() {
        this._id = this.readD();
        this._time = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Castle castle = ResidenceHolder.getInstance().getResidence(Castle.class, this._id);
        if (castle == null) {
            return;
        }
        if (player.getClan().getCastle() != castle.getId()) {
            return;
        }
        if ((player.getClanPrivileges() & 0x40000) != 262144) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_THE_AUTHORITY_TO_MODIFY_THE_SIEGE_TIME);
            return;
        }
        player.sendPacket((IBroadcastPacket)new CastleSiegeInfoPacket(castle, player));
    }
}

