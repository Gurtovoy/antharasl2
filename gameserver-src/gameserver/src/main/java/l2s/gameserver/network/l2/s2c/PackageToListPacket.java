/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Collections;
import java.util.Map;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class PackageToListPacket
extends L2GameServerPacket {
    private Map<Integer, String> _characters = Collections.emptyMap();

    public PackageToListPacket(Player player) {
        this._characters = player.getAccountChars();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._characters.size());
        for (Map.Entry<Integer, String> entry : this._characters.entrySet()) {
            this.writeD(entry.getKey());
            this.writeS(entry.getValue());
        }
    }
}

