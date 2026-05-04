package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.item.support.AppearanceStone;

public class AppearanceStoneHolder
extends AbstractHolder {
    private static final AppearanceStoneHolder _instance = new AppearanceStoneHolder();
    private TIntObjectMap<AppearanceStone> _stones = new TIntObjectHashMap();

    public static AppearanceStoneHolder getInstance() {
        return _instance;
    }

    public void addAppearanceStone(AppearanceStone stone) {
        this._stones.put(stone.getItemId(), stone);
    }

    public AppearanceStone getAppearanceStone(int id) {
        return (AppearanceStone)this._stones.get(id);
    }

    public int size() {
        return this._stones.size();
    }

    public void clear() {
        this._stones.clear();
    }
}

