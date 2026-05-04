package l2s.gameserver.templates.fish;

public final class RodTemplate {
    private final int _id;
    private final double _durationModifier;
    private final double _rewardModifier;
    private final int _shotConsumeCount;

    public RodTemplate(int id, double durationModifier, double rewardModifier, int shotConsumeCount) {
        this._id = id;
        this._durationModifier = durationModifier;
        this._rewardModifier = rewardModifier;
        this._shotConsumeCount = shotConsumeCount;
    }

    public int getId() {
        return this._id;
    }

    public double getDurationModifier() {
        return this._durationModifier;
    }

    public double getRewardModifier() {
        return this._rewardModifier;
    }

    public int getShotConsumeCount() {
        return this._shotConsumeCount;
    }
}

