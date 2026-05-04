/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Collection;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.quest.Quest;

public final class QuestHolder
extends AbstractHolder {
    private static QuestHolder _instance = new QuestHolder();
    private TIntObjectMap<Quest> _quests = new TIntObjectHashMap();

    public static QuestHolder getInstance() {
        return _instance;
    }

    public Quest getQuest(int id) {
        return (Quest)this._quests.get(id);
    }

    public void addQuest(Quest quest) {
        if (this._quests.containsKey(quest.getId())) {
            this.warn("Cannot added quest (ID[" + quest.getId() + "], CLASS[" + quest.getClass().getSimpleName() + ".java]). Quets with this ID already have!");
            return;
        }
        this._quests.put(quest.getId(), quest);
    }

    public Collection<Quest> getQuests() {
        return this._quests.valueCollection();
    }

    public int size() {
        return this._quests.size();
    }

    public void clear() {
        this._quests.clear();
    }
}

