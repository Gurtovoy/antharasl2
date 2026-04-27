/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates;

import l2s.gameserver.model.base.BaseStats;

public final class BaseStatsBonus {
    private final double _int;
    private final double _str;
    private final double _con;
    private final double _men;
    private final double _dex;
    private final double _wit;

    public BaseStatsBonus(double _int, double str, double con, double men, double dex, double wit) {
        this._int = _int;
        this._str = str;
        this._con = con;
        this._men = men;
        this._dex = dex;
        this._wit = wit;
    }

    public double getINT() {
        return this._int;
    }

    public double getSTR() {
        return this._str;
    }

    public double getCON() {
        return this._con;
    }

    public double getMEN() {
        return this._men;
    }

    public double getDEX() {
        return this._dex;
    }

    public double getWIT() {
        return this._wit;
    }

    public double get(BaseStats stat) {
        switch (stat) {
            case STR: {
                return this._str;
            }
            case DEX: {
                return this._dex;
            }
            case CON: {
                return this._con;
            }
            case INT: {
                return this._int;
            }
            case WIT: {
                return this._wit;
            }
            case MEN: {
                return this._men;
            }
        }
        return 1.0;
    }
}

