/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class DeleteObjectPacket
extends L2GameServerPacket {
    private int _objectId;

    public DeleteObjectPacket(GameObject obj) {
        this._objectId = obj.getObjectId();
    }

    public DeleteObjectPacket(int objId) {
        this._objectId = objId;
    }

    @Override
    protected boolean canWrite() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        return activeChar != null && activeChar.getObjectId() != this._objectId;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objectId);
        this.writeC(1);
    }

    @Override
    public String getType() {
        return super.getType() + " " + GameObjectsStorage.findObject(this._objectId) + " (" + this._objectId + ")";
    }
}

