package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExUserInfoFishing
extends L2GameServerPacket {
    private Player _activeChar;

    public ExUserInfoFishing(Player character) {
        this._activeChar = character;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._activeChar.getObjectId());
        if (this._activeChar.getFishing().isInProcess()) {
            this.writeC(1);
            this.writeD(this._activeChar.getFishing().getHookLocation().getX());
            this.writeD(this._activeChar.getFishing().getHookLocation().getY());
            this.writeD(this._activeChar.getFishing().getHookLocation().getZ());
        } else {
            this.writeC(0);
        }
    }
}

