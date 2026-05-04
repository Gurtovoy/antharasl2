package l2s.gameserver.templates;

import gnu.trove.map.TIntIntMap;
import gnu.trove.set.TIntSet;
import l2s.gameserver.model.Player;

public class HennaTemplate {
    private final int _symbolId;
    private final int _dyeId;
    private final int _dyeLvl;
    private final long _drawPrice;
    private final long _drawCount;
    private final long _removePrice;
    private final long _removeCount;
    private final int _statINT;
    private final int _statSTR;
    private final int _statCON;
    private final int _statMEN;
    private final int _statDEX;
    private final int _statWIT;
    private final TIntSet _classes;
    private final TIntIntMap _skills;
    private final int _period;

    public HennaTemplate(int symbolId, int dyeId, int dyeLvl, long drawPrice, long drawCount, long removePrice, long removeCount, int wit, int intA, int con, int str, int dex, int men, TIntSet classes, TIntIntMap skills, int period) {
        this._symbolId = symbolId;
        this._dyeId = dyeId;
        this._dyeLvl = dyeLvl;
        this._drawPrice = drawPrice;
        this._drawCount = drawCount;
        this._removePrice = removePrice;
        this._removeCount = removeCount;
        this._statINT = intA;
        this._statSTR = str;
        this._statCON = con;
        this._statMEN = men;
        this._statDEX = dex;
        this._statWIT = wit;
        this._classes = classes;
        this._skills = skills;
        this._period = period;
    }

    public int getSymbolId() {
        return this._symbolId;
    }

    public int getDyeId() {
        return this._dyeId;
    }

    public int getDyeLvl() {
        return this._dyeLvl;
    }

    public long getDrawPrice() {
        return this._drawPrice;
    }

    public long getDrawCount() {
        return this._drawCount;
    }

    public long getRemovePrice() {
        return this._removePrice;
    }

    public long getRemoveCount() {
        return this._removeCount;
    }

    public int getStatINT() {
        return this._statINT;
    }

    public int getStatSTR() {
        return this._statSTR;
    }

    public int getStatCON() {
        return this._statCON;
    }

    public int getStatMEN() {
        return this._statMEN;
    }

    public int getStatDEX() {
        return this._statDEX;
    }

    public int getStatWIT() {
        return this._statWIT;
    }

    public boolean isForThisClass(Player player) {
        return this._classes.contains(player.getActiveClassId());
    }

    public TIntIntMap getSkills() {
        return this._skills;
    }

    public int getPeriod() {
        return this._period;
    }
}

