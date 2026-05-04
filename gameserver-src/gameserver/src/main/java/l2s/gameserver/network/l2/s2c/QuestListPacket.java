package l2s.gameserver.network.l2.s2c;

import gnu.trove.iterator.TIntIntIterator;
import gnu.trove.map.TIntIntMap;
import gnu.trove.map.hash.TIntIntHashMap;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.QuestRepeatType;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class QuestListPacket
extends L2GameServerPacket {
    private static byte[] _completedQuestsMask = new byte[128];
    private static byte[] _unkMask = new byte[128];
    private final TIntIntMap _quests = new TIntIntHashMap();

    public QuestListPacket(Player player) {
        for (QuestState quest : player.getAllQuestsStates()) {
            int byteIndex;
            if (quest.getQuest().isVisible(player) && quest.isStarted()) {
                this._quests.put(quest.getQuest().getId(), quest.getCondsMask());
                continue;
            }
            if (!quest.isCompleted() || quest.getQuest().getRepeatType() != QuestRepeatType.ONETIME) continue;
            int questId = quest.getQuest().getId();
            if (questId >= 10000) {
                questId -= 10000;
            }
            int n = byteIndex = questId / 8;
            _completedQuestsMask[n] = (byte)(_completedQuestsMask[n] | 1 << questId - byteIndex * 8);
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeH(this._quests.size());
        TIntIntIterator iterator = this._quests.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            this.writeD(iterator.key());
            this.writeD(iterator.value());
        }
        this.writeB(_completedQuestsMask);
        this.writeB(_unkMask);
    }
}

