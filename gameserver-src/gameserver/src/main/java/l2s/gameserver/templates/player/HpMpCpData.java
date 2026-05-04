package l2s.gameserver.templates.player;

public final class HpMpCpData {
    private final double _hp;
    private final double _mp;
    private final double _cp;

    public HpMpCpData(double hp, double mp, double cp) {
        this._hp = hp;
        this._mp = mp;
        this._cp = cp;
    }

    public double getHP() {
        return this._hp;
    }

    public double getMP() {
        return this._mp;
    }

    public double getCP() {
        return this._cp;
    }
}

