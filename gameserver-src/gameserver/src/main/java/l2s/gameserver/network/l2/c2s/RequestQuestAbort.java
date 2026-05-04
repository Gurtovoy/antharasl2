package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.QuestHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.Quest;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;

public class RequestQuestAbort
extends L2GameClientPacket {
    private int _questID;

    @Override
    protected boolean readImpl() {
        this._questID = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        Quest quest = QuestHolder.getInstance().getQuest(this._questID);
        if (activeChar == null || quest == null) {
            return;
        }
        if (!quest.canAbortByPacket()) {
            return;
        }
        QuestState qs = activeChar.getQuestState(quest);
        if (qs != null && !qs.isCompleted() && !qs.abortQuest()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THIS_QUEST_CANNOT_BE_DELETED);
        }
    }
}

