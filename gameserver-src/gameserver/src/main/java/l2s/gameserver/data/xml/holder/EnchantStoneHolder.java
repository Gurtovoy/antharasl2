package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.item.support.EnchantStone;

public final class EnchantStoneHolder
extends AbstractHolder {
    private static final EnchantStoneHolder _instance = new EnchantStoneHolder();
    private TIntObjectMap<EnchantStone> _stones = new TIntObjectHashMap();

    public static EnchantStoneHolder getInstance() {
        return _instance;
    }

    public void addEnchantStone(EnchantStone stone) {
        this._stones.put(stone.getItemId(), stone);
    }

    public EnchantStone getEnchantStone(int id) {
        return (EnchantStone)this._stones.get(id);
    }

    public int size() {
        return this._stones.size();
    }

    public void clear() {
        this._stones.clear();
    }
}

