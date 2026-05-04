/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.fish.FishRewardsTemplate;
import l2s.gameserver.templates.fish.LureTemplate;
import l2s.gameserver.templates.fish.RodTemplate;

public class FishDataHolder
extends AbstractHolder {
    private static final FishDataHolder _instance = new FishDataHolder();
    private final TIntObjectMap<LureTemplate> _lures = new TIntObjectHashMap();
    private final TIntObjectMap<FishRewardsTemplate> _rewards = new TIntObjectHashMap();
    private final TIntObjectMap<RodTemplate> _rods = new TIntObjectHashMap();

    public static FishDataHolder getInstance() {
        return _instance;
    }

    public void addLure(LureTemplate lure) {
        this._lures.put(lure.getId(), lure);
    }

    public LureTemplate getLure(int id) {
        return (LureTemplate)this._lures.get(id);
    }

    public void addRewards(FishRewardsTemplate rewards) {
        this._rewards.put(rewards.getType(), rewards);
    }

    public FishRewardsTemplate getRewards(int type) {
        return (FishRewardsTemplate)this._rewards.get(type);
    }

    public void addRod(RodTemplate rod) {
        this._rods.put(rod.getId(), rod);
    }

    public RodTemplate getRod(int id) {
        return (RodTemplate)this._rods.get(id);
    }

    public void log() {
        this.info("load " + this._lures.size() + " lure(s).");
        this.info("load " + this._rewards.size() + " lure reward(s).");
        this.info("load " + this._rods.size() + " rod(s).");
    }

    public int size() {
        return 0;
    }

    public void clear() {
        this._lures.clear();
        this._rewards.clear();
        this._rods.clear();
    }
}

