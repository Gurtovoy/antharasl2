package l2s.gameserver.templates.item.support;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;

public class EnchantVariation {
    private final int _id;
    private final TIntObjectMap<EnchantLevel> _levels = new TIntObjectHashMap();
    private int _maxLvl;

    public EnchantVariation(int id) {
        this._id = id;
    }

    public int getId() {
        return this._id;
    }

    public void addLevel(EnchantLevel level) {
        if (this._maxLvl < level.getLevel()) {
            this._maxLvl = level.getLevel();
        }
        this._levels.put(level.getLevel(), level);
    }

    public EnchantLevel getLevel(int lvl) {
        if (lvl > this._maxLvl) {
            return (EnchantLevel)this._levels.get(this._maxLvl);
        }
        return (EnchantLevel)this._levels.get(lvl);
    }

    public static class EnchantLevel {
        private int _lvl;
        private double _baseChance;
        private double _magicWeaponChance;
        private double _fullBodyChance;
        private boolean _succVisualEffect;

        public EnchantLevel(int lvl, double baseChance, double magicWeaponChance, double fullBodyChance, boolean succVisualEffect) {
            this._lvl = lvl;
            this._baseChance = baseChance;
            this._magicWeaponChance = magicWeaponChance;
            this._fullBodyChance = fullBodyChance;
            this._succVisualEffect = succVisualEffect;
        }

        public int getLevel() {
            return this._lvl;
        }

        public double getBaseChance() {
            return this._baseChance;
        }

        public double getMagicWeaponChance() {
            return this._magicWeaponChance;
        }

        public double getFullBodyChance() {
            return this._fullBodyChance;
        }

        public boolean haveSuccessVisualEffect() {
            return this._succVisualEffect;
        }
    }
}

