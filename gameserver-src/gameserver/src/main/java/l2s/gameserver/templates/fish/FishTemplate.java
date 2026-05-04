/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.fish;

public final class FishTemplate {
    private final int _id;
    private final double _chance;
    private final int _duration;
    private final int _rewardType;

    public FishTemplate(int id, double chance, int duration, int rewardType) {
        this._id = id;
        this._chance = chance;
        this._duration = duration;
        this._rewardType = rewardType;
    }

    public int getId() {
        return this._id;
    }

    public double getChance() {
        return this._chance;
    }

    public int getDuration() {
        return this._duration;
    }

    public int getRewardType() {
        return this._rewardType;
    }
}

