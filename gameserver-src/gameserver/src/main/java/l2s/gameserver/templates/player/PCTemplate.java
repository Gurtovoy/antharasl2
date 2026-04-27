/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 */
package l2s.gameserver.templates.player;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import l2s.gameserver.templates.CreatureTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.player.HpMpCpData;

public abstract class PCTemplate
extends CreatureTemplate {
    private final int _baseChestDef;
    private final int _baseLegsDef;
    private final int _baseHelmetDef;
    private final int _baseBootsDef;
    private final int _baseGlovesDef;
    private final int _basePendantDef;
    private final int _baseCloakDef;
    private final int _baseREarDef;
    private final int _baseLEarDef;
    private final int _baseRRingDef;
    private final int _baseLRingDef;
    private final int _baseNecklaceDef;
    private final double _baseRideRunSpd;
    private final double _baseRideWalkSpd;
    protected final TIntObjectMap<HpMpCpData> _regenData = new TIntObjectHashMap();

    public PCTemplate(StatsSet set) {
        super(set);
        this._baseChestDef = set.getInteger("baseChestDef");
        this._baseLegsDef = set.getInteger("baseLegsDef");
        this._baseHelmetDef = set.getInteger("baseHelmetDef");
        this._baseBootsDef = set.getInteger("baseBootsDef");
        this._baseGlovesDef = set.getInteger("baseGlovesDef");
        this._basePendantDef = set.getInteger("basePendantDef");
        this._baseCloakDef = set.getInteger("baseCloakDef");
        this._baseREarDef = set.getInteger("baseREarDef");
        this._baseLEarDef = set.getInteger("baseLEarDef");
        this._baseRRingDef = set.getInteger("baseRRingDef");
        this._baseLRingDef = set.getInteger("baseLRingDef");
        this._baseNecklaceDef = set.getInteger("baseNecklaceDef");
        this._baseRideRunSpd = set.getDouble("baseRideRunSpd");
        this._baseRideWalkSpd = set.getDouble("baseRideWalkSpd");
    }

    public int getBaseChestDef() {
        return this._baseChestDef;
    }

    public int getBaseLegsDef() {
        return this._baseLegsDef;
    }

    public int getBaseHelmetDef() {
        return this._baseHelmetDef;
    }

    public int getBaseBootsDef() {
        return this._baseBootsDef;
    }

    public int getBaseGlovesDef() {
        return this._baseGlovesDef;
    }

    public int getBasePendantDef() {
        return this._basePendantDef;
    }

    public int getBaseCloakDef() {
        return this._baseCloakDef;
    }

    public int getBaseREarDef() {
        return this._baseREarDef;
    }

    public int getBaseLEarDef() {
        return this._baseLEarDef;
    }

    public int getBaseRRingDef() {
        return this._baseRRingDef;
    }

    public int getBaseLRingDef() {
        return this._baseLRingDef;
    }

    public int getBaseNecklaceDef() {
        return this._baseNecklaceDef;
    }

    public double getBaseRideRunSpd() {
        return this._baseRideRunSpd;
    }

    public double getBaseRideWalkSpd() {
        return this._baseRideWalkSpd;
    }

    public void addRegenData(int level, HpMpCpData data) {
        this._regenData.put(level, data);
    }

    @Override
    public double getBaseHpReg(int level) {
        HpMpCpData data = (HpMpCpData)this._regenData.get(level);
        if (data == null) {
            return 0.0;
        }
        return data.getHP();
    }

    @Override
    public double getBaseMpReg(int level) {
        HpMpCpData data = (HpMpCpData)this._regenData.get(level);
        if (data == null) {
            return 0.0;
        }
        return data.getMP();
    }

    @Override
    public double getBaseCpReg(int level) {
        HpMpCpData data = (HpMpCpData)this._regenData.get(level);
        if (data == null) {
            return 0.0;
        }
        return data.getCP();
    }
}

