package l2s.gameserver.network.l2.s2c;

import java.util.Collections;
import java.util.Set;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExMpccPartymasterList
extends L2GameServerPacket {
    private Set<String> _members = Collections.emptySet();

    public ExMpccPartymasterList(Set<String> s) {
        this._members = s;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._members.size());
        for (String t : this._members) {
            this.writeS(t);
        }
    }
}

