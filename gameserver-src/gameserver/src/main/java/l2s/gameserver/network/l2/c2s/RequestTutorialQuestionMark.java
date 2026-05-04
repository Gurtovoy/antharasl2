/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestTutorialQuestionMark
extends L2GameClientPacket {
    private boolean _quest = false;
    private int _tutorialId = 0;

    @Override
    protected boolean readImpl() {
        this._quest = this.readC() > 0;
        this._tutorialId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        for (QuestState qs : player.getAllQuestsStates()) {
            qs.getQuest().notifyTutorialEvent("QM", this._quest, String.valueOf(this._tutorialId), qs);
        }
    }
}

