package l2s.gameserver.data.xml.holder;

import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.templates.npc.NpcTemplate;

public final class NpcHolder
extends AbstractHolder {
    private static final NpcHolder _instance = new NpcHolder();
    private TIntObjectHashMap<NpcTemplate> _npcs = new TIntObjectHashMap(20000);
    private TIntObjectHashMap<List<NpcTemplate>> _npcsByLevel;
    private NpcTemplate[] _allTemplates;
    private Map<String, NpcTemplate> _npcsNames;

    public static NpcHolder getInstance() {
        return _instance;
    }

    NpcHolder() {
    }

    public void addTemplate(NpcTemplate template) {
        this._npcs.put(template.getId(), template);
    }

    public NpcTemplate getTemplate(int id) {
        NpcTemplate npc = (NpcTemplate)ArrayUtils.valid((Object[])this._allTemplates, (int)id);
        if (npc == null) {
            this.warn("Not defined npc id : " + id + ", or out of range!", new Exception());
            return null;
        }
        return this._allTemplates[id];
    }

    public NpcTemplate getTemplateByName(String name) {
        return this._npcsNames.get(name.toLowerCase());
    }

    public List<NpcTemplate> getAllOfLevel(int lvl) {
        return (List)this._npcsByLevel.get(lvl);
    }

    public NpcTemplate[] getAll() {
        return (NpcTemplate[])this._npcs.values(new NpcTemplate[this._npcs.size()]);
    }

    private void buildFastLookupTable() {
        this._npcsByLevel = new TIntObjectHashMap();
        this._npcsNames = new HashMap<String, NpcTemplate>();
        int highestId = 0;
        for (int id : this._npcs.keys()) {
            if (id <= highestId) continue;
            highestId = id;
        }
        this._allTemplates = new NpcTemplate[highestId + 1];
        TIntObjectIterator iterator = this._npcs.iterator();
        while (iterator.hasNext()) {
            NpcTemplate npc;
            iterator.advance();
            int npcId = iterator.key();
            this._allTemplates[npcId] = npc = (NpcTemplate)iterator.value();
            ArrayList<NpcTemplate> byLevel = (ArrayList<NpcTemplate>)this._npcsByLevel.get(npc.level);
            if (byLevel == null) {
                byLevel = new ArrayList<NpcTemplate>();
                this._npcsByLevel.put(npcId, byLevel);
            }
            byLevel.add(npc);
            this._npcsNames.put(npc.name.toLowerCase(), npc);
        }
    }

    protected void process() {
        this.buildFastLookupTable();
    }

    public int size() {
        return this._npcs.size();
    }

    public void clear() {
        this._npcsNames.clear();
        this._npcs.clear();
    }
}

