package l2s.gameserver.templates.fish;

public final class FishRewardTemplate {
    private final int _minLevel;
    private final int _maxLevel;
    private final long _exp;
    private final long _sp;

    public FishRewardTemplate(int minLevel, int maxLevel, long exp, long sp) {
        this._minLevel = minLevel;
        this._maxLevel = maxLevel;
        this._exp = exp;
        this._sp = sp;
    }

    public int getMinLevel() {
        return this._minLevel;
    }

    public int getMaxLevel() {
        return this._maxLevel;
    }

    public long getExp() {
        return this._exp;
    }

    public long getSp() {
        return this._sp;
    }
}

