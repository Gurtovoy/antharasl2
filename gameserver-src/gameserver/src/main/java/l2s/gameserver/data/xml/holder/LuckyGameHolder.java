package l2s.gameserver.data.xml.holder;

import java.util.HashMap;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.luckygame.LuckyGameData;
import l2s.gameserver.templates.luckygame.LuckyGameType;

public final class LuckyGameHolder
extends AbstractHolder {
    private static final LuckyGameHolder _instance = new LuckyGameHolder();
    private final Map<LuckyGameType, LuckyGameData> _data = new HashMap<LuckyGameType, LuckyGameData>();

    public static LuckyGameHolder getInstance() {
        return _instance;
    }

    public void addData(LuckyGameData data) {
        if (this._data.containsKey((Object)data.getType())) {
            this.warn("Conflict while parsing lucky game data! Dublicate game data by type: " + (Object)((Object)data.getType()));
            return;
        }
        if (data.getCommonRewards().isEmpty()) {
            this.warn("Lucky game dont have common rewards type: " + (Object)((Object)data.getType()));
        }
        this._data.put(data.getType(), data);
    }

    public LuckyGameData getData(LuckyGameType type) {
        return this._data.get(type);
    }

    public int size() {
        return this._data.size();
    }

    public void clear() {
        this._data.clear();
    }
}

