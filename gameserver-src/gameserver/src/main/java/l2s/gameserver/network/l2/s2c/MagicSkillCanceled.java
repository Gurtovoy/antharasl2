/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class MagicSkillCanceled
extends L2GameServerPacket {
    private int _objectId;

    public MagicSkillCanceled(int objectId) {
        this._objectId = objectId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
    }
}

