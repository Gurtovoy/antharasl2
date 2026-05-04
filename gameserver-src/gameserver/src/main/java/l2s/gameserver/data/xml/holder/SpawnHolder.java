package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.spawn.SpawnTemplate;

public final class SpawnHolder
extends AbstractHolder {
    private static final SpawnHolder _instance = new SpawnHolder();
    private Map<String, List<SpawnTemplate>> _spawns = new HashMap<String, List<SpawnTemplate>>();

    public static SpawnHolder getInstance() {
        return _instance;
    }

    public void addSpawn(String group, SpawnTemplate spawn) {
        List<SpawnTemplate> spawns = this._spawns.get(group);
        if (spawns == null) {
            spawns = new ArrayList<SpawnTemplate>();
            this._spawns.put(group, spawns);
        }
        spawns.add(spawn);
    }

    public List<SpawnTemplate> getSpawn(String name) {
        List<SpawnTemplate> template = this._spawns.get(name);
        return template == null ? Collections.emptyList() : template;
    }

    public int size() {
        int i = 0;
        for (List<SpawnTemplate> l : this._spawns.values()) {
            i += l.size();
        }
        return i;
    }

    public void clear() {
        this._spawns.clear();
    }

    public Map<String, List<SpawnTemplate>> getSpawns() {
        return this._spawns;
    }
}

