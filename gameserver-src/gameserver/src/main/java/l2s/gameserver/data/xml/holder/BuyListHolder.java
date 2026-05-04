package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.Collection;
import java.util.Collections;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.npc.BuyListTemplate;

public final class BuyListHolder
extends AbstractHolder {
    private static final BuyListHolder _instance = new BuyListHolder();
    private final TIntObjectMap<BuyListTemplate> _buyListsByListId = new TIntObjectHashMap();
    private final TIntObjectMap<TIntObjectMap<BuyListTemplate>> _buyListsByNpcId = new TIntObjectHashMap();

    public static BuyListHolder getInstance() {
        return _instance;
    }

    public void addBuyList(BuyListTemplate buyList) {
        this._buyListsByListId.put(buyList.getListId(), buyList);
        TIntObjectMap buyLists = (TIntObjectMap)this._buyListsByNpcId.get(buyList.getNpcId());
        if (buyLists == null) {
            buyLists = new TIntObjectHashMap();
            this._buyListsByNpcId.put(buyList.getNpcId(), buyLists);
        }
        buyLists.put(buyList.getId(), buyList);
    }

    public BuyListTemplate getBuyList(int listId) {
        return (BuyListTemplate)this._buyListsByListId.get(listId);
    }

    public Collection<BuyListTemplate> getBuyLists(int npcId) {
        TIntObjectMap buyLists = (TIntObjectMap)this._buyListsByNpcId.get(npcId);
        if (buyLists == null) {
            return Collections.emptyList();
        }
        return buyLists.valueCollection();
    }

    public BuyListTemplate getBuyList(int npcId, int buyListId) {
        TIntObjectMap buyLists = (TIntObjectMap)this._buyListsByNpcId.get(npcId);
        if (buyLists == null) {
            return null;
        }
        return (BuyListTemplate)buyLists.get(buyListId);
    }

    public int size() {
        return this._buyListsByListId.size();
    }

    public void clear() {
        this._buyListsByListId.clear();
        this._buyListsByNpcId.clear();
    }
}

