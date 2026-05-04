/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestTutorialPassCmdToServer
extends L2GameClientPacket {
    private String _bypass = null;

    @Override
    protected boolean readImpl() {
        this._bypass = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        for (QuestState qs : player.getAllQuestsStates()) {
            qs.getQuest().notifyTutorialEvent("BYPASS", false, this._bypass, qs);
        }
    }
}

