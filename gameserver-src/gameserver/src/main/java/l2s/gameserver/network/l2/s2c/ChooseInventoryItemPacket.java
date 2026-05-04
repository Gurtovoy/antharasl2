package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ChooseInventoryItemPacket
extends L2GameServerPacket {
    private int ItemID;

    public ChooseInventoryItemPacket(int id) {
        this.ItemID = id;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this.ItemID);
    }
}

