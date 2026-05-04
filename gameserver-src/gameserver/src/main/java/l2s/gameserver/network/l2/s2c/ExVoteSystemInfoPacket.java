/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExVoteSystemInfoPacket
extends L2GameServerPacket {
    private int _receivedRec;
    private int _givingRec;
    private int _time;
    private int _bonusPercent;
    private boolean _showTimer;

    public ExVoteSystemInfoPacket(Player player) {
        this._receivedRec = player.getRecomLeft();
        this._givingRec = player.getRecomHave();
        this._time = 0;
        this._bonusPercent = 0;
        this._showTimer = false;
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._receivedRec);
        this.writeD(this._givingRec);
        this.writeD(this._time);
        this.writeD(this._bonusPercent);
        this.writeD(this._showTimer ? 1 : 0);
    }
}

