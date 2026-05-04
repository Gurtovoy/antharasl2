/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.data.xml.holder.HennaHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.HennaTemplate;

public class HennaEquipListPacket
extends L2GameServerPacket {
    private final Player _player;
    private final int _emptySlots;
    private final long _adena;
    private final List<HennaTemplate> _hennas = new ArrayList<HennaTemplate>();

    public HennaEquipListPacket(Player player) {
        this._player = player;
        this._adena = player.getAdena();
        this._emptySlots = player.getHennaList().getFreeSize();
        List<HennaTemplate> list = HennaHolder.getInstance().generateList(player);
        for (HennaTemplate element : list) {
            if (player.getInventory().getItemByItemId(element.getDyeId()) == null) continue;
            this._hennas.add(element);
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeQ(this._adena);
        this.writeD(this._emptySlots);
        this.writeD(this._hennas.size());
        for (HennaTemplate henna : this._hennas) {
            this.writeD(henna.getSymbolId());
            this.writeD(henna.getDyeId());
            this.writeQ(henna.getDrawCount());
            this.writeQ(henna.getDrawPrice());
            this.writeD(henna.isForThisClass(this._player) ? 1 : 0);
        }
    }
}

