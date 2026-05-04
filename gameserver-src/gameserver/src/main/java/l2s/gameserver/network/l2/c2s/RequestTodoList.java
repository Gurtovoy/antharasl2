/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ExConnectedTimeAndGettableReward;
import l2s.gameserver.network.l2.s2c.ExOneDayReceiveRewardList;
import l2s.gameserver.network.l2.s2c.ExTodoListInzone;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestTodoList
extends L2GameClientPacket {
    private int _tab;
    private boolean _showAllLevels;

    @Override
    protected boolean readImpl() {
        this._tab = this.readC();
        this._showAllLevels = this.readC() > 0;
        return true;
    }

    @Override
    protected void runImpl() {
        switch (this._tab) {
            case 1: 
            case 2: {
                this.sendPacket((L2GameServerPacket)new ExTodoListInzone());
                break;
            }
            case 9: {
                Player activeChar = ((GameClient)this.getClient()).getActiveChar();
                if (activeChar == null) {
                    this.sendPacket((L2GameServerPacket)new ExOneDayReceiveRewardList());
                    break;
                }
                this.sendPacket(ExConnectedTimeAndGettableReward.STATIC);
                this.sendPacket((L2GameServerPacket)new ExOneDayReceiveRewardList(activeChar));
                break;
            }
        }
    }
}

