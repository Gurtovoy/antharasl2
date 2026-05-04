/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.HennaTemplate;

public class HennaItemInfoPacket
extends L2GameServerPacket {
    private final int _str;
    private final int _con;
    private final int _dex;
    private final int _int;
    private final int _wit;
    private final int _men;
    private final long _adena;
    private final HennaTemplate _hennaTemplate;
    private final boolean _available;

    public HennaItemInfoPacket(HennaTemplate hennaTemplate, Player player) {
        this._hennaTemplate = hennaTemplate;
        this._adena = player.getAdena();
        this._str = player.getSTR();
        this._dex = player.getDEX();
        this._con = player.getCON();
        this._int = player.getINT();
        this._wit = player.getWIT();
        this._men = player.getMEN();
        this._available = this._hennaTemplate.isForThisClass(player);
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._hennaTemplate.getSymbolId());
        this.writeD(this._hennaTemplate.getDyeId());
        this.writeQ(this._hennaTemplate.getDrawCount());
        this.writeQ(this._hennaTemplate.getDrawPrice());
        this.writeD(this._available);
        this.writeQ(this._adena);
        this.writeD(this._int);
        this.writeH(this._int + this._hennaTemplate.getStatINT());
        this.writeD(this._str);
        this.writeH(this._str + this._hennaTemplate.getStatSTR());
        this.writeD(this._con);
        this.writeH(this._con + this._hennaTemplate.getStatCON());
        this.writeD(this._men);
        this.writeH(this._men + this._hennaTemplate.getStatMEN());
        this.writeD(this._dex);
        this.writeH(this._dex + this._hennaTemplate.getStatDEX());
        this.writeD(this._wit);
        this.writeH(this._wit + this._hennaTemplate.getStatWIT());
        this.writeD(0);
        this.writeH(0);
        this.writeD(0);
        this.writeH(0);
        this.writeD(this._hennaTemplate.getPeriod());
    }
}

