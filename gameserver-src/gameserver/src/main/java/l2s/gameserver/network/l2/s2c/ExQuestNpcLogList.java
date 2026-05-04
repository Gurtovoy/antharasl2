/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.model.quest.QuestNpcLogInfo;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExQuestNpcLogList
extends L2GameServerPacket {
    private int _questId;
    private List<int[]> _logList = Collections.emptyList();

    public ExQuestNpcLogList(QuestState state) {
        int npcStringId;
        int[] i;
        this._questId = state.getQuest().getId();
        int cond = state.getCond();
        this._logList = new ArrayList<int[]>();
        List<QuestNpcLogInfo> vars = state.getQuest().getNpcLogList(cond);
        if (vars != null) {
            for (QuestNpcLogInfo entry : vars) {
                i = new int[3];
                npcStringId = entry.getNpcStringId();
                if (npcStringId == 0) {
                    i[0] = entry.getNpcIds()[0] + 1000000;
                    i[1] = 0;
                } else {
                    i[0] = npcStringId;
                    i[1] = 1;
                }
                i[2] = state.getInt(entry.getVarName());
                this._logList.add(i);
            }
        }
        if ((vars = state.getQuest().getItemsLogList(cond)) != null) {
            for (QuestNpcLogInfo entry : vars) {
                i = new int[3];
                npcStringId = entry.getNpcStringId();
                if (npcStringId == 0) {
                    i[0] = entry.getNpcIds()[0];
                    i[1] = 0;
                } else {
                    i[0] = npcStringId;
                    i[1] = 1;
                }
                for (int itemId : entry.getNpcIds()) {
                    i[2] = i[2] + (int)state.getQuestItemsCount(itemId);
                }
                i[2] = Math.min(i[2], entry.getMaxCount());
                this._logList.add(i);
            }
        }
        if ((vars = state.getQuest().getCustomLogList(cond)) != null) {
            for (QuestNpcLogInfo entry : vars) {
                int npcStringId2 = entry.getNpcStringId();
                if (npcStringId2 == 0) continue;
                int[] i2 = new int[]{npcStringId2, 1, state.getInt(entry.getVarName())};
                this._logList.add(i2);
            }
        }
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._questId);
        this.writeC(this._logList.size());
        for (int i = 0; i < this._logList.size(); ++i) {
            int[] values = this._logList.get(i);
            this.writeD(values[0]);
            this.writeC(values[1]);
            this.writeD(values[2]);
        }
    }
}

