/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExUISettingPacket
extends L2GameServerPacket {
    private final byte[] data;

    public ExUISettingPacket(Player player) {
        this.data = player.getKeyBindings();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this.data.length);
        this.writeB(this.data);
    }
}

