/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.CastleSiegeAttackerListPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestCastleSiegeAttackerList
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
        Object residence = ResidenceHolder.getInstance().getResidence(this._unitId);
        if (residence != null) {
            this.sendPacket((L2GameServerPacket)new CastleSiegeAttackerListPacket((Residence)residence));
        }
    }
}

