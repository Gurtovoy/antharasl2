/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExOneDayReceiveRewardList;

public class RequestOneDayRewardReceive
extends L2GameClientPacket {
    private int _missionId;

    @Override
    protected boolean readImpl() {
        this._missionId = this.readH();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.getDailyMissionList().complete(this._missionId)) {
            activeChar.sendPacket((IBroadcastPacket)new ExOneDayReceiveRewardList(activeChar));
        }
    }
}

