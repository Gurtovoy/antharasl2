/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.templates.HennaTemplate;

public final class HennaHolder
extends AbstractHolder {
    private static final HennaHolder _instance = new HennaHolder();
    private TIntObjectHashMap<HennaTemplate> _hennas = new TIntObjectHashMap();

    public static HennaHolder getInstance() {
        return _instance;
    }

    public void addHenna(HennaTemplate h) {
        this._hennas.put(h.getSymbolId(), h);
    }

    public HennaTemplate getHenna(int symbolId) {
        return (HennaTemplate)this._hennas.get(symbolId);
    }

    public List<HennaTemplate> generateList(Player player) {
        ArrayList<HennaTemplate> list = new ArrayList<HennaTemplate>();
        TIntObjectIterator iterator = this._hennas.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            HennaTemplate h = (HennaTemplate)iterator.value();
            list.add(h);
        }
        return list;
    }

    public int size() {
        return this._hennas.size();
    }

    public void clear() {
        this._hennas.clear();
    }
}

