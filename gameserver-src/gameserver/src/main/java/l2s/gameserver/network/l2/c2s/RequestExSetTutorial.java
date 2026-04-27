/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestExSetTutorial
extends L2GameClientPacket {
    private int _event = 0;

    @Override
    protected boolean readImpl() {
        this._event = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        for (QuestState qs : player.getAllQuestsStates()) {
            qs.getQuest().notifyTutorialEvent("CE", false, String.valueOf(this._event), qs);
        }
    }
}

