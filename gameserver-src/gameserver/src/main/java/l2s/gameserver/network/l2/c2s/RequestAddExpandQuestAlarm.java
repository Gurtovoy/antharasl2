/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.QuestHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.Quest;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExQuestNpcLogList;

public class RequestAddExpandQuestAlarm
extends L2GameClientPacket {
    private int _questId;

    @Override
    protected boolean readImpl() throws Exception {
        this._questId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() throws Exception {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Quest quest = QuestHolder.getInstance().getQuest(this._questId);
        if (quest == null) {
            return;
        }
        QuestState state = player.getQuestState(quest);
        if (state == null) {
            return;
        }
        player.sendPacket((IBroadcastPacket)new ExQuestNpcLogList(state));
    }
}

