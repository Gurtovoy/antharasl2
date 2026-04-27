package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;

public final class AutobotDataHolder extends AbstractHolder {
    private static final AutobotDataHolder _instance = new AutobotDataHolder();

    private AutobotConfig _config = new AutobotConfig();
    private final Map<Integer, List<BuffInfo>> _classBuffs = new HashMap<Integer, List<BuffInfo>>();
    private final List<EquipmentSet> _equipmentSets = new ArrayList<EquipmentSet>();
    private final List<TeleportLocation> _teleportLocations = new ArrayList<TeleportLocation>();

    public static AutobotDataHolder getInstance() {
        return _instance;
    }

    private AutobotDataHolder() {
    }

    // --- Config ---

    public void setConfig(AutobotConfig config) {
        this._config = config;
    }

    public AutobotConfig getConfig() {
        return this._config;
    }

    // --- Buffs ---

    public void addClassBuffs(int classId, List<BuffInfo> buffs) {
        this._classBuffs.put(classId, buffs);
    }

    public List<BuffInfo> getClassBuffs(int classId) {
        List<BuffInfo> buffs = this._classBuffs.get(classId);
        if (buffs == null) {
            buffs = this._classBuffs.get(0);
        }
        return buffs != null ? buffs : Collections.<BuffInfo>emptyList();
    }

    public Map<Integer, List<BuffInfo>> getAllClassBuffs() {
        return this._classBuffs;
    }

    // --- Equipment ---

    public void addEquipmentSet(EquipmentSet set) {
        this._equipmentSets.add(set);
    }

    public List<EquipmentSet> getEquipmentSets() {
        return this._equipmentSets;
    }

    public EquipmentSet getEquipmentSet(int classId, int level) {
        EquipmentSet best = null;
        for (EquipmentSet set : this._equipmentSets) {
            if (set.getClassId() == classId && level >= set.getMinLevel() && level <= set.getMaxLevel()) {
                if (best == null || set.getMinLevel() > best.getMinLevel()) {
                    best = set;
                }
            }
        }
        if (best == null) {
            for (EquipmentSet set : this._equipmentSets) {
                if (set.getClassId() == 0 && level >= set.getMinLevel() && level <= set.getMaxLevel()) {
                    if (best == null || set.getMinLevel() > best.getMinLevel()) {
                        best = set;
                    }
                }
            }
        }
        return best;
    }

    // --- Teleports ---

    public void addTeleportLocation(TeleportLocation loc) {
        this._teleportLocations.add(loc);
    }

    public List<TeleportLocation> getTeleportLocations() {
        return this._teleportLocations;
    }

    public List<TeleportLocation> getTeleportLocationsByType(String type) {
        List<TeleportLocation> result = new ArrayList<TeleportLocation>();
        for (TeleportLocation loc : this._teleportLocations) {
            if (loc.getType().equalsIgnoreCase(type)) {
                result.add(loc);
            }
        }
        return result;
    }

    // --- AbstractHolder ---

    @Override
    public void log() {
        this.info("loaded " + this._classBuffs.size() + " autobot buff class(es).");
        this.info("loaded " + this._equipmentSets.size() + " autobot equipment set(s).");
        this.info("loaded " + this._teleportLocations.size() + " autobot teleport location(s).");
    }

    @Override
    public int size() {
        return this._classBuffs.size() + this._equipmentSets.size() + this._teleportLocations.size();
    }

    @Override
    public void clear() {
        this._config = new AutobotConfig();
        this._classBuffs.clear();
        this._equipmentSets.clear();
        this._teleportLocations.clear();
    }

    // =============================================
    // Inner data classes
    // =============================================

    public static class AutobotConfig {
        private int thinkIterationMs = 350;
        private String defaultTitle = "";
        private int defaultTargetingRange = 2000;
        private String defaultAttackPlayerType = "NONE";
        private String defaultTargetingPreference = "RANDOM";
        private boolean useManaPots = false;
        private boolean useHealingPots = false;
        private boolean useCpPots = false;
        private double manaPotThreshold = 0.3;
        private double healingPotThreshold = 0.3;
        private double cpPotThreshold = 0.3;
        private int maxActiveBots = 100;
        private int spawnDelayMs = 1000;

        public int getThinkIterationMs() { return thinkIterationMs; }
        public void setThinkIterationMs(int val) { thinkIterationMs = val; }

        public String getDefaultTitle() { return defaultTitle; }
        public void setDefaultTitle(String val) { defaultTitle = val; }

        public int getDefaultTargetingRange() { return defaultTargetingRange; }
        public void setDefaultTargetingRange(int val) { defaultTargetingRange = val; }

        public String getDefaultAttackPlayerType() { return defaultAttackPlayerType; }
        public void setDefaultAttackPlayerType(String val) { defaultAttackPlayerType = val; }

        public String getDefaultTargetingPreference() { return defaultTargetingPreference; }
        public void setDefaultTargetingPreference(String val) { defaultTargetingPreference = val; }

        public boolean isUseManaPots() { return useManaPots; }
        public void setUseManaPots(boolean val) { useManaPots = val; }

        public boolean isUseHealingPots() { return useHealingPots; }
        public void setUseHealingPots(boolean val) { useHealingPots = val; }

        public boolean isUseCpPots() { return useCpPots; }
        public void setUseCpPots(boolean val) { useCpPots = val; }

        public double getManaPotThreshold() { return manaPotThreshold; }
        public void setManaPotThreshold(double val) { manaPotThreshold = val; }

        public double getHealingPotThreshold() { return healingPotThreshold; }
        public void setHealingPotThreshold(double val) { healingPotThreshold = val; }

        public double getCpPotThreshold() { return cpPotThreshold; }
        public void setCpPotThreshold(double val) { cpPotThreshold = val; }

        public int getMaxActiveBots() { return maxActiveBots; }
        public void setMaxActiveBots(int val) { maxActiveBots = val; }

        public int getSpawnDelayMs() { return spawnDelayMs; }
        public void setSpawnDelayMs(int val) { spawnDelayMs = val; }
    }

    public static class BuffInfo {
        private final int skillId;
        private final int skillLevel;

        public BuffInfo(int skillId, int skillLevel) {
            this.skillId = skillId;
            this.skillLevel = skillLevel;
        }

        public int getSkillId() { return skillId; }
        public int getSkillLevel() { return skillLevel; }
    }

    public static class EquipmentSet {
        private final int classId;
        private final int minLevel;
        private final int maxLevel;
        private final Map<String, Integer> slotToItemId;

        public EquipmentSet(int classId, int minLevel, int maxLevel, Map<String, Integer> slotToItemId) {
            this.classId = classId;
            this.minLevel = minLevel;
            this.maxLevel = maxLevel;
            this.slotToItemId = slotToItemId;
        }

        public int getClassId() { return classId; }
        public int getMinLevel() { return minLevel; }
        public int getMaxLevel() { return maxLevel; }
        public Map<String, Integer> getSlotToItemId() { return slotToItemId; }

        public int getItemId(String slot) {
            Integer id = slotToItemId.get(slot);
            return id != null ? id : 0;
        }
    }

    public static class TeleportLocation {
        private final String name;
        private final int x;
        private final int y;
        private final int z;
        private final String type;

        public TeleportLocation(String name, int x, int y, int z, String type) {
            this.name = name;
            this.x = x;
            this.y = y;
            this.z = z;
            this.type = type;
        }

        public String getName() { return name; }
        public int getX() { return x; }
        public int getY() { return y; }
        public int getZ() { return z; }
        public String getType() { return type; }
    }
}
