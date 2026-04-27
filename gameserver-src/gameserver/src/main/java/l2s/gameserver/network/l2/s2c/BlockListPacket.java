/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Block;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class BlockListPacket
extends L2GameServerPacket {
    private Block[] _blockList;

    public BlockListPacket(Player player) {
        this._blockList = player.getBlockList().values();
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._blockList.length);
        for (Block b : this._blockList) {
            this.writeS(b.getName());
            this.writeS(b.getMemo());
        }
    }
}

