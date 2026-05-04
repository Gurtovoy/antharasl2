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
import l2s.gameserver.network.l2.s2c.CastleSiegeDefenderListPacket;

public class RequestCastleSiegeDefenderList
extends L2GameClientPacket {
    private int _unitId;

    @Override
    protected boolean readImpl() {
        this._unitId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Castle castle = ResidenceHolder.getInstance().getResidence(Castle.class, this._unitId);
        if (castle == null) {
            return;
        }
        player.sendPacket((IBroadcastPacket)new CastleSiegeDefenderListPacket(castle));
    }
}

