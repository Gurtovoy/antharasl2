/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExBR_PremiumStatePacket
extends L2GameServerPacket {
    private int _objectId;
    private int _state;

    public ExBR_PremiumStatePacket(Player activeChar, boolean state) {
        this._objectId = activeChar.getObjectId();
        this._state = state ? 1 : 0;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objectId);
        this.writeC(this._state);
    }
}

