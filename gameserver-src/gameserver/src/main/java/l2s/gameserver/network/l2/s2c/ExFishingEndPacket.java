/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExFishingEndPacket
extends L2GameServerPacket {
    public static final int FAIL = 0;
    public static final int WIN = 1;
    public static final int CANCELED = 2;
    private final int _charId;
    private final int _type;

    public ExFishingEndPacket(Player character, int type) {
        this._charId = character.getObjectId();
        this._type = type;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._charId);
        this.writeC(this._type);
    }
}

