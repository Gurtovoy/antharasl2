/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Servitor;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExPartyPetWindowDelete
extends L2GameServerPacket {
    private int _summonObjectId;
    private int _ownerObjectId;
    private int _type;
    private String _summonName;

    public ExPartyPetWindowDelete(Servitor summon) {
        this._summonObjectId = summon.getObjectId();
        this._summonName = summon.getName();
        this._type = summon.getServitorType();
        this._ownerObjectId = summon.getPlayer().getObjectId();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._summonObjectId);
        this.writeD(this._type);
        this.writeD(this._ownerObjectId);
        this.writeS(this._summonName);
    }
}

