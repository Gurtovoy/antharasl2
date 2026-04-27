/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.residence;

import l2s.gameserver.Config;
import l2s.gameserver.model.base.ResidenceFunctionType;

public class ResidenceFunctionTemplate
implements Comparable<ResidenceFunctionTemplate> {
    private final int _id;
    private final ResidenceFunctionType _type;
    private final int _level;
    private final int _depth;
    private final int _period;
    private final long _cost;
    private double _hpRegen = 0.0;
    private double _mpRegen = 0.0;
    private double _expRestore = 0.0;

    public ResidenceFunctionTemplate(int id, ResidenceFunctionType type, int level, int depth, int period, long cost) {
        this._id = id;
        this._type = type;
        this._level = level;
        this._depth = depth;
        this._period = period;
        this._cost = cost;
    }

    public int getId() {
        return this._id;
    }

    public ResidenceFunctionType getType() {
        return this._type;
    }

    public int getLevel() {
        return this._level;
    }

    public int getDepth() {
        return this._depth;
    }

    public int getPeriod() {
        return this._period;
    }

    public long getCost() {
        return (long)((double)this._cost * Config.RESIDENCE_LEASE_FUNC_MULTIPLIER);
    }

    public void setHpRegen(double value) {
        this._hpRegen = value;
    }

    public double getHpRegen() {
        return this._hpRegen;
    }

    public void setMpRegen(double value) {
        this._mpRegen = value;
    }

    public double getMpRegen() {
        return this._mpRegen;
    }

    public void setExpRestore(double value) {
        this._expRestore = value;
    }

    public double getExpRestore() {
        return this._expRestore;
    }

    @Override
    public int compareTo(ResidenceFunctionTemplate o) {
        return this.getLevel() - o.getLevel();
    }
}

