/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.pet;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.model.base.MountType;
import l2s.gameserver.model.base.PetType;
import l2s.gameserver.templates.item.data.RewardItemData;
import l2s.gameserver.templates.pet.PetLevelData;
import l2s.gameserver.templates.pet.PetSkillData;

public class PetData {
    private final int _npcId;
    private final int _controlItemId;
    private final int[] _syncLevels;
    private final List<PetSkillData> _skills;
    private final TIntObjectMap<PetLevelData> _lvlData;
    private final PetType _type;
    private final MountType _mountType;
    private int _minLvl = Integer.MAX_VALUE;
    private int _maxLvl = 0;
    private final List<RewardItemData> _expirationRewardItems = new ArrayList<RewardItemData>();

    public PetData(int npcId, int controlItemId, int[] syncLevels, PetType type, MountType mountType) {
        this._npcId = npcId;
        this._controlItemId = controlItemId;
        this._syncLevels = syncLevels;
        this._skills = new ArrayList<PetSkillData>();
        this._lvlData = new TIntObjectHashMap();
        this._type = type;
        this._mountType = mountType;
    }

    public int getNpcId() {
        return this._npcId;
    }

    public int getControlItemId() {
        return this._controlItemId;
    }

    public void addSkill(PetSkillData skill) {
        this._skills.add(skill);
    }

    public PetSkillData[] getSkills() {
        return this._skills.toArray(new PetSkillData[this._skills.size()]);
    }

    public void addLvlData(int lvl, PetLevelData lvlData) {
        if (this._minLvl > lvl) {
            this._minLvl = lvl;
        }
        if (this._maxLvl < lvl - 1) {
            this._maxLvl = lvl - 1;
        }
        this._lvlData.put(lvl, lvlData);
    }

    public PetLevelData getLvlData(int level) {
        return (PetLevelData)this._lvlData.get(Math.max(this._minLvl, Math.min(this._maxLvl, level)));
    }

    public int getMaxMeal(int level) {
        return this.getLvlData(level).getMaxMeal();
    }

    public long getExp(int level) {
        return this.getLvlData(level).getExp();
    }

    public int getExpType(int level) {
        return this.getLvlData(level).getExpType();
    }

    public int getBattleMealConsume(int level) {
        return this.getLvlData(level).getBattleMealConsume();
    }

    public int getNormalMealConsume(int level) {
        return this.getLvlData(level).getNormalMealConsume();
    }

    public double getPAtk(int level) {
        return this.getLvlData(level).getPAtk();
    }

    public double getPDef(int level) {
        return this.getLvlData(level).getPDef();
    }

    public double getMAtk(int level) {
        return this.getLvlData(level).getMAtk();
    }

    public double getMDef(int level) {
        return this.getLvlData(level).getMDef();
    }

    public double getHP(int level) {
        return this.getLvlData(level).getHP();
    }

    public double getMP(int level) {
        return this.getLvlData(level).getMP();
    }

    public double getHPRegen(int level) {
        return this.getLvlData(level).getHPRegen();
    }

    public double getMPRegen(int level) {
        return this.getLvlData(level).getMPRegen();
    }

    public int[] getFood(int level) {
        return this.getLvlData(level).getFood();
    }

    public int getHungryLimit(int level) {
        return this.getLvlData(level).getHungryLimit();
    }

    public int getSoulshotCount(int level) {
        return this.getLvlData(level).getSoulshotCount();
    }

    public int getSpiritshotCount(int level) {
        return this.getLvlData(level).getSpiritshotCount();
    }

    public int getMaxLoad(int level) {
        return this.getLvlData(level).getMaxLoad();
    }

    public PetType getType() {
        return this._type;
    }

    public boolean isOfType(PetType type) {
        return this._type == type;
    }

    public MountType getMountType() {
        return this._mountType;
    }

    public int getMinLvl() {
        return this._minLvl;
    }

    public int getMaxLvl() {
        return this._maxLvl;
    }

    public int getFormId(int level) {
        for (int i = 0; i < this._syncLevels.length; ++i) {
            if (level < this._syncLevels[i]) continue;
            return i + 1;
        }
        return 0;
    }

    public void addExpirationRewardItem(RewardItemData item) {
        this._expirationRewardItems.add(item);
    }

    public RewardItemData[] getExpirationRewardItems() {
        return this._expirationRewardItems.toArray(new RewardItemData[this._expirationRewardItems.size()]);
    }
}

