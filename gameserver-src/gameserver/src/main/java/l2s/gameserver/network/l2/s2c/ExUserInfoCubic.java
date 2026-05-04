package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExUserInfoCubic
extends L2GameServerPacket {
    private final int _objectId;
    private final int _agationId;
    private final Cubic[] _cubics;

    public ExUserInfoCubic(Player character) {
        this._objectId = character.getObjectId();
        this._cubics = character.getCubics().toArray(new Cubic[character.getCubics().size()]);
        this._agationId = character.getAgathionNpcId();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._objectId);
        this.writeH(this._cubics.length);
        for (Cubic cubic : this._cubics) {
            this.writeH(cubic == null ? 0 : cubic.getId());
        }
        this.writeD(this._agationId);
    }
}

