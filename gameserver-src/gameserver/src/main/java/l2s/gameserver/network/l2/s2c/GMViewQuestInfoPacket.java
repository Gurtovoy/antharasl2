package l2s.gameserver.network.l2.s2c;

import gnu.trove.iterator.TIntIntIterator;
import gnu.trove.map.TIntIntMap;
import gnu.trove.map.hash.TIntIntHashMap;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class GMViewQuestInfoPacket
extends L2GameServerPacket {
    private final String _characterName;
    private final TIntIntMap _quests = new TIntIntHashMap();

    public GMViewQuestInfoPacket(Player targetCharacter) {
        this._characterName = targetCharacter.getName();
        for (QuestState quest : targetCharacter.getAllQuestsStates()) {
            if (!quest.getQuest().isVisible(targetCharacter) || !quest.isStarted()) continue;
            this._quests.put(quest.getQuest().getId(), quest.getCondsMask());
        }
    }

    @Override
    protected final void writeImpl() {
        this.writeS(this._characterName);
        this.writeH(this._quests.size());
        TIntIntIterator iterator = this._quests.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            this.writeD(iterator.key());
            this.writeD(iterator.value());
        }
        this.writeH(0);
    }
}

