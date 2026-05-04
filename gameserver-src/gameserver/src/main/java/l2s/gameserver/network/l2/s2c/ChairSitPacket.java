/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.StaticObjectInstance;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ChairSitPacket
extends L2GameServerPacket {
    private int _objectId;
    private int _staticObjectId;

    public ChairSitPacket(Player player, StaticObjectInstance throne) {
        this._objectId = player.getObjectId();
        this._staticObjectId = throne.getUId();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeD(this._staticObjectId);
    }
}

