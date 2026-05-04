/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.templates.HennaTemplate;

public class HennaUnequipInfoPacket
extends L2GameServerPacket {
    private final HennaTemplate _hennaTemplate;
    private final Player _player;

    public HennaUnequipInfoPacket(HennaTemplate hennaTemplate, Player player) {
        this._hennaTemplate = hennaTemplate;
        this._player = player;
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._hennaTemplate.getSymbolId());
        this.writeD(this._hennaTemplate.getDyeId());
        this.writeQ(this._hennaTemplate.getRemoveCount());
        this.writeQ(this._hennaTemplate.getRemovePrice());
        this.writeD(this._hennaTemplate.isForThisClass(this._player));
        this.writeQ(this._player.getAdena());
        this.writeD(this._player.getINT());
        this.writeC(this._player.getINT() - this._hennaTemplate.getStatINT());
        this.writeD(this._player.getSTR());
        this.writeC(this._player.getSTR() - this._hennaTemplate.getStatSTR());
        this.writeD(this._player.getCON());
        this.writeC(this._player.getCON() - this._hennaTemplate.getStatCON());
        this.writeD(this._player.getMEN());
        this.writeC(this._player.getMEN() - this._hennaTemplate.getStatMEN());
        this.writeD(this._player.getDEX());
        this.writeC(this._player.getDEX() - this._hennaTemplate.getStatDEX());
        this.writeD(this._player.getWIT());
        this.writeC(this._player.getWIT() - this._hennaTemplate.getStatWIT());
        this.writeD(0);
        this.writeC(0);
        this.writeD(0);
        this.writeC(0);
        this.writeD(this._hennaTemplate.getPeriod());
    }
}

