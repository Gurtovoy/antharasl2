/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.player;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.util.Rnd;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.StartItem;
import l2s.gameserver.templates.player.PCTemplate;

public final class PlayerTemplate
extends PCTemplate {
    private final Race _race;
    private final Sex _sex;
    private final int _minINT;
    private final int _minSTR;
    private final int _minCON;
    private final int _minMEN;
    private final int _minDEX;
    private final int _minWIT;
    private final int _maxINT;
    private final int _maxSTR;
    private final int _maxCON;
    private final int _maxMEN;
    private final int _maxDEX;
    private final int _maxWIT;
    private final double _baseSafeFallHeight;
    private final double _baseBreathBonus;
    private final List<Location> _startLocs = new ArrayList<Location>();
    private final List<StartItem> _startItems = new ArrayList<StartItem>();

    public PlayerTemplate(StatsSet set, Race race, Sex sex) {
        super(set);
        this._race = race;
        this._sex = sex;
        this._minINT = set.getInteger("minINT", 1);
        this._minSTR = set.getInteger("minSTR", 1);
        this._minCON = set.getInteger("minCON", 1);
        this._minMEN = set.getInteger("minMEN", 1);
        this._minDEX = set.getInteger("minDEX", 1);
        this._minWIT = set.getInteger("minWIT", 1);
        this._maxINT = set.getInteger("maxINT", 100);
        this._maxSTR = set.getInteger("maxSTR", 100);
        this._maxCON = set.getInteger("maxCON", 100);
        this._maxMEN = set.getInteger("maxMEN", 100);
        this._maxDEX = set.getInteger("maxDEX", 100);
        this._maxWIT = set.getInteger("maxWIT", 100);
        this._baseSafeFallHeight = set.getDouble("baseSafeFallHeight");
        this._baseBreathBonus = set.getDouble("baseBreathBonus");
    }

    public Race getRace() {
        return this._race;
    }

    public Sex getSex() {
        return this._sex;
    }

    public int getMinINT() {
        return this._minINT;
    }

    public int getMinSTR() {
        return this._minSTR;
    }

    public int getMinCON() {
        return this._minCON;
    }

    public int getMinMEN() {
        return this._minMEN;
    }

    public int getMinDEX() {
        return this._minDEX;
    }

    public int getMinWIT() {
        return this._minWIT;
    }

    public int getMaxINT() {
        return this._maxINT;
    }

    public int getMaxSTR() {
        return this._maxSTR;
    }

    public int getMaxCON() {
        return this._maxCON;
    }

    public int getMaxMEN() {
        return this._maxMEN;
    }

    public int getMaxDEX() {
        return this._maxDEX;
    }

    public int getMaxWIT() {
        return this._maxWIT;
    }

    public double getBaseBreathBonus() {
        return this._baseBreathBonus;
    }

    public double getBaseSafeFallHeight() {
        return this._baseSafeFallHeight;
    }

    public void addStartItem(StartItem item) {
        this._startItems.add(item);
    }

    public StartItem[] getStartItems() {
        return this._startItems.toArray(new StartItem[this._startItems.size()]);
    }

    public void addStartLocation(Location loc) {
        this._startLocs.add(loc);
    }

    public Location getStartLocation() {
        return this._startLocs.get(Rnd.get((int)this._startLocs.size()));
    }
}

