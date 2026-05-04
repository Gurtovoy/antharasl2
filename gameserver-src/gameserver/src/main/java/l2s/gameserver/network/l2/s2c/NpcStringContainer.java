package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public abstract class NpcStringContainer
extends L2GameServerPacket {
    private final NpcString _npcString;
    private final String[] _parameters;

    protected NpcStringContainer(NpcString npcString, String ... arg) {
        this._npcString = npcString;
        this._parameters = arg;
    }

    protected void writeElements() {
        this.writeD(this._npcString.getId());
        for (String st : this._parameters) {
            this.writeS(st);
        }
    }
}

