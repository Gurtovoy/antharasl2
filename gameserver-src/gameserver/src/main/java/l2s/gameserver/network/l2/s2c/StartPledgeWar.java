package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class StartPledgeWar
extends L2GameServerPacket {
    private String _pledgeName;
    private String _char;

    public StartPledgeWar(String pledge, String charName) {
        this._pledgeName = pledge;
        this._char = charName;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._char);
        this.writeS(this._pledgeName);
    }
}

