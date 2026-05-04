package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Henna;
import l2s.gameserver.model.actor.instances.player.HennaList;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.HennaTemplate;

public class HennaUnequipListPacket
extends L2GameServerPacket {
    private final Player _player;
    private final long _adena;
    private final HennaList _hennaList;

    public HennaUnequipListPacket(Player player) {
        this._player = player;
        this._adena = player.getAdena();
        this._hennaList = player.getHennaList();
    }

    @Override
    protected final void writeImpl() {
        this.writeQ(this._adena);
        this.writeD(this._hennaList.getFreeSize());
        this.writeD(this._hennaList.size());
        for (Henna henna : this._hennaList.values(true)) {
            HennaTemplate template = henna.getTemplate();
            this.writeD(template.getSymbolId());
            this.writeD(template.getDyeId());
            this.writeQ(template.getRemoveCount());
            this.writeQ(template.getRemovePrice());
            this.writeD(template.isForThisClass(this._player) ? 1 : 0);
        }
    }
}

