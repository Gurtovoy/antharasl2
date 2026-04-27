/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.ArrayUtils
 *  org.apache.commons.lang3.StringUtils
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.TreeIntObjectMap
 */
package l2s.gameserver.templates;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.StatTemplate;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.templates.item.data.RewardItemData;
import l2s.gameserver.utils.Language;
import org.apache.commons.lang3.StringUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;

public class PremiumAccountTemplate
extends StatTemplate {
    public static final PremiumAccountTemplate DEFAULT_ACCOUNT_TEMPLATE = new PremiumAccountTemplate(0, StatsSet.EMPTY);
    private final int _type;
    private final int _nameColor;
    private final int _titleColor;
    private final double _expRate;
    private final double _spRate;
    private final double _adenaRate;
    private final double _dropRate;
    private final double _spoilRate;
    private final double _questDropRate;
    private final double _questRewardRate;
    private final double _fishingExpRate;
    private final double _fishingSpRate;
    private final double _dropChanceModifier;
    private final double _dropCountModifier;
    private final double _spoilChanceModifier;
    private final double _spoilCountModifier;
    private final double _enchantChanceBonus;
    private final double _craftChanceBonus;
    private final int _worldChatMinLevel;
    private final Map<Language, String> _names = new HashMap<Language, String>();
    private final List<ItemData> _giveItemsOnStart = new ArrayList<ItemData>();
    private final List<ItemData> _takeItemsOnEnd = new ArrayList<ItemData>();
    private final IntObjectMap<List<ItemData>> _fees = new TreeIntObjectMap();
    private final List<RewardItemData> _rewards = new ArrayList<RewardItemData>();
    private SkillEntry[] _skills = SkillEntry.EMPTY_ARRAY;

    public PremiumAccountTemplate(int type, StatsSet set) {
        this._type = type;
        String color = set.getString("name_color", null);
        this._nameColor = StringUtils.isEmpty((CharSequence)color) ? -1 : Integer.decode("0x" + color);
        color = set.getString("title_color", null);
        this._titleColor = StringUtils.isEmpty((CharSequence)color) ? -1 : Integer.decode("0x" + color);
        this._expRate = set.getDouble("exp_rate", 1.0);
        this._spRate = set.getDouble("sp_rate", 1.0);
        this._adenaRate = set.getDouble("adena_rate", 1.0);
        this._dropRate = set.getDouble("drop_rate", 1.0);
        this._spoilRate = set.getDouble("spoil_rate", 1.0);
        this._questDropRate = set.getDouble("quest_drop_rate", 1.0);
        this._questRewardRate = set.getDouble("quest_reward_rate", 1.0);
        this._fishingExpRate = set.getDouble("fishing_exp_rate", 1.0);
        this._fishingSpRate = set.getDouble("fishing_sp_rate", 1.0);
        this._dropChanceModifier = set.getDouble("drop_chance_modifier", 1.0);
        this._dropCountModifier = set.getDouble("drop_count_modifier", 1.0);
        this._spoilChanceModifier = set.getDouble("spoil_chance_modifier", 1.0);
        this._spoilCountModifier = set.getDouble("spoil_count_modifier", 1.0);
        this._enchantChanceBonus = set.getDouble("enchant_chance_bonus", 0.0);
        this._craftChanceBonus = set.getDouble("craft_chance_bonus", 0.0);
        this._worldChatMinLevel = set.getInteger("world_chat_min_level", -1);
    }

    public int getType() {
        return this._type;
    }

    public int getNameColor() {
        return this._nameColor;
    }

    public int getTitleColor() {
        return this._titleColor;
    }

    public double getExpRate() {
        return this._expRate;
    }

    public double getSpRate() {
        return this._spRate;
    }

    public double getAdenaRate() {
        return this._adenaRate;
    }

    public double getDropRate() {
        return this._dropRate;
    }

    public double getSpoilRate() {
        return this._spoilRate;
    }

    public double getQuestDropRate() {
        return this._questDropRate;
    }

    public double getQuestRewardRate() {
        return this._questRewardRate;
    }

    public double getFishingExpRate() {
        return this._fishingExpRate;
    }

    public double getFishingSpRate() {
        return this._fishingSpRate;
    }

    public double getDropChanceModifier() {
        return this._dropChanceModifier;
    }

    public double getDropCountModifier() {
        return this._dropCountModifier;
    }

    public double getSpoilChanceModifier() {
        return this._spoilChanceModifier;
    }

    public double getSpoilCountModifier() {
        return this._spoilCountModifier;
    }

    public double getEnchantChanceBonus() {
        return this._enchantChanceBonus;
    }

    public double getCraftChanceBonus() {
        return this._craftChanceBonus;
    }

    public int getWorldChatMinLevel() {
        return this._worldChatMinLevel;
    }

    public void addName(Language lang, String name) {
        this._names.put(lang, name);
    }

    public String getName(Language lang) {
        String name = this._names.get(lang);
        if (name == null) {
            Language secondLang = lang;
            while (secondLang != secondLang.getSecondLanguage() && Config.AVAILABLE_LANGUAGES.contains(secondLang) && (name = this._names.get((secondLang = secondLang.getSecondLanguage()))) == null) {
            }
            if (name == null) {
                Language l;
                Language[] languageArray = Language.VALUES;
                int n = languageArray.length;
                for (int i = 0; !(i >= n || Config.AVAILABLE_LANGUAGES.contains((l = languageArray[i])) && (name = this._names.get(l)) != null); ++i) {
                }
            }
        }
        if (name == null) {
            return "Type: " + this.getType();
        }
        return name;
    }

    public void addGiveItemOnStart(ItemData item) {
        this._giveItemsOnStart.add(item);
    }

    public List<ItemData> getGiveItemsOnStart() {
        return this._giveItemsOnStart;
    }

    public void addTakeItemOnEnd(ItemData item) {
        this._takeItemsOnEnd.add(item);
    }

    public List<ItemData> getTakeItemsOnEnd() {
        return this._takeItemsOnEnd;
    }

    public void addFee(int delay, ItemData item) {
        ArrayList<ItemData> items = (ArrayList<ItemData>)this._fees.get(delay);
        if (items == null) {
            items = new ArrayList<ItemData>();
            this._fees.put(delay, items);
        }
        items.add(item);
    }

    public int[] getFeeDelays() {
        return this._fees.keySet().toArray();
    }

    public List<ItemData> getFeeItems(int delay) {
        List items = (List)this._fees.get(delay);
        if (items == null) {
            return null;
        }
        return items;
    }

    public void attachSkill(SkillEntry skill) {
        this._skills = (SkillEntry[])ArrayUtils.add((Object[])this._skills, (Object)skill);
    }

    public SkillEntry[] getAttachedSkills() {
        return this._skills;
    }

    public final Func[] getStatFuncs() {
        return this.getStatFuncs(this);
    }

    public void addReward(RewardItemData reward) {
        this._rewards.add(reward);
    }

    public List<RewardItemData> getRewards() {
        return this._rewards;
    }

    public void onAdd(Player player) {
        SkillEntry[] skills;
        double currentHpRatio = player.getCurrentHpRatio();
        double currentMpRatio = player.getCurrentMpRatio();
        double currentCpRatio = player.getCurrentCpRatio();
        player.addTriggers(this);
        player.getStat().addFuncs(this.getStatFuncs());
        for (SkillEntry skill : skills = this.getAttachedSkills()) {
            player.addSkill(skill);
        }
        if (skills.length > 0) {
            player.sendSkillList();
        }
        player.setCurrentHp((double)player.getMaxHp() * currentHpRatio, false);
        player.setCurrentMp((double)player.getMaxMp() * currentMpRatio);
        player.setCurrentCp((double)player.getMaxCp() * currentCpRatio);
        player.updateStats();
    }

    public void onRemove(Player player) {
        SkillEntry[] skills;
        double currentHpRatio = player.getCurrentHpRatio();
        double currentMpRatio = player.getCurrentMpRatio();
        double currentCpRatio = player.getCurrentCpRatio();
        player.getStat().removeFuncsByOwner(this);
        player.removeTriggers(this);
        for (SkillEntry skill : skills = this.getAttachedSkills()) {
            player.removeSkill(skill);
        }
        if (skills.length > 0) {
            player.sendSkillList();
        }
        player.setCurrentHp((double)player.getMaxHp() * currentHpRatio, false);
        player.setCurrentMp((double)player.getMaxMp() * currentMpRatio);
        player.setCurrentCp((double)player.getMaxCp() * currentCpRatio);
        player.updateStats();
    }
}

