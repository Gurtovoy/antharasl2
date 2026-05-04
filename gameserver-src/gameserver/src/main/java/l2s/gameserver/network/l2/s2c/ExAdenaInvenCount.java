package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExAdenaInvenCount
extends L2GameServerPacket {
    private final long _adena;
    private final int _useInventorySlots;

    public ExAdenaInvenCount(Player player) {
        this._adena = player.getAdena();
        this._useInventorySlots = player.getInventory().getSize();
    }

    @Override
    protected void writeImpl() {
        this.writeQ(this._adena);
        this.writeH(this._useInventorySlots);
    }
}

