/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class NickNameChangedPacket
extends L2GameServerPacket {
    private final int objectId;
    private final String title;

    public NickNameChangedPacket(Creature cha) {
        this.objectId = cha.getObjectId();
        this.title = cha.getTitle();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this.objectId);
        this.writeS(this.title);
    }
}

