/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExDuelAskStart
extends L2GameServerPacket {
    String _requestor;
    int _isPartyDuel;

    public ExDuelAskStart(String requestor, int isPartyDuel) {
        this._requestor = requestor;
        this._isPartyDuel = isPartyDuel;
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._requestor);
        this.writeD(this._isPartyDuel);
    }
}

