/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExRegistWaitingSubstituteOk
extends L2GameServerPacket {
    private final Player _partyLeader;

    public ExRegistWaitingSubstituteOk(Player player) {
        this._partyLeader = player;
    }

    @Override
    protected void writeImpl() {
    }
}

