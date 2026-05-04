package l2s.gameserver.templates.fish;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.templates.fish.FishRewardTemplate;

public final class FishRewardsTemplate {
    private final int _type;
    private final List<FishRewardTemplate> _rewards = new ArrayList<FishRewardTemplate>();

    public FishRewardsTemplate(int type) {
        this._type = type;
    }

    public int getType() {
        return this._type;
    }

    public void addReward(FishRewardTemplate reward) {
        this._rewards.add(reward);
    }

    public List<FishRewardTemplate> getRewards() {
        return this._rewards;
    }
}

