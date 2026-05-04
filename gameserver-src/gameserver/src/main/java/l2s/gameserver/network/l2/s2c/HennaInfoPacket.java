package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.Henna;
import l2s.gameserver.model.actor.instances.player.HennaList;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class HennaInfoPacket
extends L2GameServerPacket {
    private final Player _player;
    private final HennaList _hennaList;

    public HennaInfoPacket(Player player) {
        this._player = player;
        this._hennaList = player.getHennaList();
    }

    @Override
    protected final void writeImpl() {
        this.writeH(this._hennaList.getINT());
        this.writeH(this._hennaList.getSTR());
        this.writeH(this._hennaList.getCON());
        this.writeH(this._hennaList.getMEN());
        this.writeH(this._hennaList.getDEX());
        this.writeH(this._hennaList.getWIT());
        this.writeH(0);
        this.writeH(0);
        this.writeD(3);
        this.writeD(this._hennaList.size());
        for (Henna henna : this._hennaList.values(false)) {
            this.writeD(henna.getTemplate().getSymbolId());
            this.writeD(this._hennaList.isActive(henna));
        }
        Henna henna = this._hennaList.getPremiumHenna();
        if (henna != null) {
            this.writeD(henna.getTemplate().getSymbolId());
            this.writeD(henna.getLeftTime());
            this.writeD(this._hennaList.isActive(henna));
        } else {
            this.writeD(0);
            this.writeD(0);
            this.writeD(0);
        }
    }
}

