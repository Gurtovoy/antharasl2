/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.base.ResidenceFunctionType;
import l2s.gameserver.model.entity.residence.ClanHall;
import l2s.gameserver.model.entity.residence.ResidenceFunction;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class AgitDecoInfoPacket
extends L2GameServerPacket {
    private final ClanHall _clanHall;

    public AgitDecoInfoPacket(ClanHall clanHall) {
        this._clanHall = clanHall;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._clanHall.getId());
        for (ResidenceFunctionType type : ResidenceFunctionType.VALUES) {
            ResidenceFunction function = this._clanHall.getActiveFunction(type);
            if (function != null) {
                this.writeC(function.getTemplate().getDepth());
                continue;
            }
            this.writeC(0);
        }
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
        this.writeD(0);
    }
}

