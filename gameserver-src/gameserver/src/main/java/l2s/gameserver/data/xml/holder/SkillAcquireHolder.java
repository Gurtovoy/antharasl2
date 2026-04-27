/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.iterator.TIntObjectIterator
 *  gnu.trove.map.TIntObjectMap
 *  gnu.trove.map.hash.TIntIntHashMap
 *  gnu.trove.map.hash.TIntObjectHashMap
 *  gnu.trove.set.hash.TIntHashSet
 *  l2s.commons.data.xml.AbstractHolder
 */
package l2s.gameserver.data.xml.holder;

import gnu.trove.iterator.TIntObjectIterator;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntIntHashMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.hash.TIntHashSet;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import java.util.TreeMap;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.utils.MulticlassUtils;

public final class SkillAcquireHolder
extends AbstractHolder {
    private static final SkillAcquireHolder _instance = new SkillAcquireHolder();
    private TIntObjectMap<Set<SkillLearn>> _normalSkillTree = new TIntObjectHashMap();
    private TIntObjectMap<Set<SkillLearn>> _generalSkillTree = new TIntObjectHashMap();
    private TIntObjectMap<Set<SkillLearn>> _multiclassCheckSkillTree = new TIntObjectHashMap();
    private TIntObjectMap<TIntObjectMap<Set<SkillLearn>>> _multiclassLearnSkillTree = new TIntObjectHashMap();
    private Set<SkillLearn> _fishingSkillTree = new HashSet<SkillLearn>();
    private Set<SkillLearn> _pledgeSkillTree = new HashSet<SkillLearn>();
    private Set<SkillLearn> _subUnitSkillTree = new HashSet<SkillLearn>();
    private Set<SkillLearn> _heroSkillTree = new HashSet<SkillLearn>();
    private Set<SkillLearn> _gmSkillTree = new HashSet<SkillLearn>();
    private Set<SkillLearn> _customSkillTree = new HashSet<SkillLearn>();

    public static SkillAcquireHolder getInstance() {
        return _instance;
    }

    private Collection<SkillLearn> getSkills(Player player, ClassId classId, AcquireType type, Clan clan, SubUnit subUnit) {
        Collection<SkillLearn> skills;
        switch (type) {
            case NORMAL: {
                skills = (Collection)this._normalSkillTree.get(player.getActiveClassId());
                if (skills != null) break;
                this.info("Skill tree for class " + player.getActiveClassId() + " is not defined !");
                return Collections.emptyList();
            }
            case FISHING: {
                skills = this._fishingSkillTree;
                if (skills != null) break;
                this.info("Fishing skill tree is not defined !");
                return Collections.emptyList();
            }
            case CLAN: {
                Set<SkillLearn> skills2 = this._pledgeSkillTree;
                if (skills2 == null) {
                    this.info("Pledge skill tree is not defined !");
                    return Collections.emptyList();
                }
                return this.checkLearnsConditions(null, clan, skills2, 0, AcquireType.CLAN);
            }
            case SUB_UNIT: {
                Set<SkillLearn> skills3 = this._subUnitSkillTree;
                if (skills3 == null) {
                    this.info("Sub-unit skill tree is not defined !");
                    return Collections.emptyList();
                }
                return this.checkLearnsConditions(null, clan, skills3, 0, AcquireType.SUB_UNIT);
            }
            case HERO: {
                skills = this._heroSkillTree;
                if (skills != null) break;
                this.info("Hero skill tree is not defined !");
                return Collections.emptyList();
            }
            case GM: {
                skills = this._gmSkillTree;
                if (skills != null) break;
                return Collections.emptyList();
            }
            case CUSTOM: {
                skills = this._customSkillTree;
                if (skills != null) break;
                return Collections.emptyList();
            }
            case MULTICLASS: {
                if (Config.MULTICLASS_SYSTEM_ENABLED) {
                    if (classId != null) {
                        TIntObjectMap map = (TIntObjectMap)this._multiclassLearnSkillTree.get(player.getActiveClassId());
                        if (map == null) {
                            this.info("Skill tree for learn multiclass " + player.getActiveClassId() + " is not defined !");
                            return Collections.emptyList();
                        }
                        skills = (Collection)map.get(classId.getId());
                        if (skills != null) break;
                        this.info("Skill tree for learn multiclass " + player.getActiveClassId() + ":" + classId.getId() + " is not defined !");
                        return Collections.emptyList();
                    }
                    skills = (Collection)this._multiclassCheckSkillTree.get(player.getActiveClassId());
                    if (skills != null) break;
                    this.info("Skill tree for check multiclass " + player.getActiveClassId() + " is not defined !");
                    return Collections.emptyList();
                }
                return Collections.emptyList();
            }
            default: {
                return Collections.emptyList();
            }
        }
        if (player == null) {
            return skills;
        }
        return this.checkLearnsConditions(player, player == null ? null : player.getClan(), skills, player.getLevel(), type);
    }

    public Collection<SkillLearn> getAvailableSkills(Player player, AcquireType type) {
        return this.getAvailableSkills(player, null, type, player == null ? null : player.getClan(), null);
    }

    public Collection<SkillLearn> getAvailableSkills(Player player, AcquireType type, SubUnit subUnit) {
        return this.getAvailableSkills(player, null, type, player == null ? null : player.getClan(), subUnit);
    }

    public Collection<SkillLearn> getAvailableSkills(Player player, ClassId classId, AcquireType type, Clan clan, SubUnit subUnit) {
        Collection<SkillLearn> skills = this.getSkills(player, classId, type, clan, subUnit);
        switch (type) {
            case CLAN: {
                Collection<SkillEntry> clanSkills = clan.getSkills();
                return this.getAvaliableList(skills, clanSkills.toArray(new SkillEntry[clanSkills.size()]));
            }
            case SUB_UNIT: {
                Collection<SkillEntry> subUnitSkills = subUnit.getSkills();
                return this.getAvaliableList(skills, subUnitSkills.toArray(new SkillEntry[subUnitSkills.size()]));
            }
        }
        if (player == null) {
            return skills;
        }
        return this.getAvaliableList(skills, player.getAllSkillsArray());
    }

    private Collection<SkillLearn> getAvaliableList(Collection<SkillLearn> skillLearns, SkillEntry[] skills) {
        TIntIntHashMap skillLvls = new TIntIntHashMap();
        for (SkillEntry skillEntry : skills) {
            if (skillEntry == null) continue;
            skillLvls.put(skillEntry.getId(), skillEntry.getLevel());
        }
        TreeMap<Integer, SkillLearn> skillLearnMap = new TreeMap<Integer, SkillLearn>();
        for (SkillLearn temp : skillLearns) {
            int skillId = temp.getId();
            int skillLvl = temp.getLevel();
            if ((skillLvls.containsKey(skillId) || skillLvl != 1) && (!skillLvls.containsKey(skillId) || skillLvl - skillLvls.get(skillId) != 1)) continue;
            skillLearnMap.put(temp.getId(), temp);
        }
        return skillLearnMap.values();
    }

    public Collection<SkillLearn> getAvailableNextLevelsSkills(Player player, AcquireType type) {
        return this.getAvailableNextLevelsSkills(player, null, type, player == null ? null : player.getClan(), null);
    }

    public Collection<SkillLearn> getAvailableNextLevelsSkills(Player player, AcquireType type, SubUnit subUnit) {
        return this.getAvailableNextLevelsSkills(player, null, type, player == null ? null : player.getClan(), subUnit);
    }

    public Collection<SkillLearn> getAvailableNextLevelsSkills(Player player, ClassId classId, AcquireType type, Clan clan, SubUnit subUnit) {
        Collection<SkillLearn> skills = this.getSkills(player, classId, type, clan, subUnit);
        switch (type) {
            case CLAN: {
                Collection<SkillEntry> clanSkills = clan.getSkills();
                return this.getAvailableNextLevelsList(skills, clanSkills.toArray(new SkillEntry[clanSkills.size()]));
            }
            case SUB_UNIT: {
                Collection<SkillEntry> subUnitSkills = subUnit.getSkills();
                return this.getAvailableNextLevelsList(skills, subUnitSkills.toArray(new SkillEntry[subUnitSkills.size()]));
            }
        }
        if (player == null) {
            return skills;
        }
        return this.getAvailableNextLevelsList(skills, player.getAllSkillsArray());
    }

    private Collection<SkillLearn> getAvailableNextLevelsList(Collection<SkillLearn> skillLearns, SkillEntry[] skills) {
        TIntIntHashMap skillLvls = new TIntIntHashMap();
        for (SkillEntry skillEntry : skills) {
            if (skillEntry == null) continue;
            skillLvls.put(skillEntry.getId(), skillEntry.getLevel());
        }
        HashSet<SkillLearn> skillLearnsList = new HashSet<SkillLearn>();
        for (SkillLearn temp : skillLearns) {
            int skillId = temp.getId();
            int skillLvl = temp.getLevel();
            if (skillLvls.containsKey(skillId) && (!skillLvls.containsKey(skillId) || skillLvl <= skillLvls.get(skillId))) continue;
            skillLearnsList.add(temp);
        }
        return skillLearnsList;
    }

    public Collection<SkillLearn> getAvailableMaxLvlSkills(Player player, AcquireType type) {
        return this.getAvailableMaxLvlSkills(player, null, type, player == null ? null : player.getClan(), null);
    }

    public Collection<SkillLearn> getAvailableMaxLvlSkills(Player player, AcquireType type, SubUnit subUnit) {
        return this.getAvailableMaxLvlSkills(player, null, type, player == null ? null : player.getClan(), subUnit);
    }

    public Collection<SkillLearn> getAvailableMaxLvlSkills(Player player, ClassId classId, AcquireType type, Clan clan, SubUnit subUnit) {
        Collection<SkillLearn> skills = this.getSkills(player, classId, type, clan, subUnit);
        switch (type) {
            case CLAN: {
                Collection<SkillEntry> clanSkills = clan.getSkills();
                return this.getAvaliableMaxLvlSkillList(skills, clanSkills.toArray(new SkillEntry[clanSkills.size()]));
            }
            case SUB_UNIT: {
                Collection<SkillEntry> subUnitSkills = subUnit.getSkills();
                return this.getAvaliableMaxLvlSkillList(skills, subUnitSkills.toArray(new SkillEntry[subUnitSkills.size()]));
            }
        }
        if (player == null) {
            return skills;
        }
        return this.getAvaliableMaxLvlSkillList(skills, player.getAllSkillsArray());
    }

    private Collection<SkillLearn> getAvaliableMaxLvlSkillList(Collection<SkillLearn> skillLearns, SkillEntry[] skills) {
        TreeMap<Integer, SkillLearn> skillLearnMap = new TreeMap<Integer, SkillLearn>();
        for (SkillLearn temp : skillLearns) {
            int skillId = temp.getId();
            if (skillLearnMap.containsKey(skillId) && temp.getLevel() <= ((SkillLearn)skillLearnMap.get(skillId)).getLevel()) continue;
            skillLearnMap.put(skillId, temp);
        }
        for (SkillEntry skillEntry : skills) {
            SkillLearn temp;
            int skillId = skillEntry.getId();
            if (!skillLearnMap.containsKey(skillId) || (temp = (SkillLearn)skillLearnMap.get(skillId)) == null || temp.getLevel() > skillEntry.getLevel()) continue;
            skillLearnMap.remove(skillId);
        }
        return skillLearnMap.values();
    }

    private Collection<Skill> getLearnedList(Collection<SkillLearn> skillLearns, SkillEntry[] skills) {
        TIntHashSet skillLvls = new TIntHashSet();
        for (SkillLearn temp : skillLearns) {
            skillLvls.add(SkillHolder.getInstance().getHashCode(temp.getId(), temp.getLevel()));
        }
        HashSet<Skill> learned = new HashSet<Skill>();
        for (SkillEntry skillEntry : skills) {
            if (skillEntry == null || !skillLvls.contains(skillEntry.hashCode())) continue;
            learned.add(skillEntry.getTemplate());
        }
        return learned;
    }

    public Collection<SkillLearn> getAcquirableSkillListByClass(Player player) {
        TreeMap<Integer, SkillLearn> skillListMap = new TreeMap<Integer, SkillLearn>();
        Collection skills = (Collection)this._normalSkillTree.get(player.getActiveClassId());
        Collection<SkillLearn> currentLvlSkills = this.getAvaliableList(skills, player.getAllSkillsArray());
        currentLvlSkills = this.checkLearnsConditions(player, player == null ? null : player.getClan(), currentLvlSkills, player.getLevel(), AcquireType.NORMAL);
        for (SkillLearn temp : currentLvlSkills) {
            if (temp.isFreeAutoGet(AcquireType.NORMAL)) continue;
            skillListMap.put(temp.getId(), temp);
        }
        Collection<SkillLearn> nextLvlsSkills = this.getAvaliableList(skills, player.getAllSkillsArray());
        nextLvlsSkills = this.checkLearnsConditions(player, player == null ? null : player.getClan(), nextLvlsSkills, player.getMaxLevel(), AcquireType.NORMAL);
        for (SkillLearn temp : nextLvlsSkills) {
            if (temp.isFreeAutoGet(AcquireType.NORMAL) || skillListMap.containsKey(temp.getId())) continue;
            skillListMap.put(temp.getId(), temp);
        }
        return skillListMap.values();
    }

    public SkillLearn getSkillLearn(Player player, int id, int level, AcquireType type) {
        return this.getSkillLearn(player, null, id, level, type);
    }

    public SkillLearn getSkillLearn(Player player, ClassId classId, int id, int level, AcquireType type) {
        Collection<SkillLearn> skills;
        switch (type) {
            case NORMAL: {
                skills = (Collection)this._normalSkillTree.get(player.getActiveClassId());
                break;
            }
            case FISHING: {
                skills = this._fishingSkillTree;
                break;
            }
            case CLAN: {
                Set<SkillLearn> skills2 = this._pledgeSkillTree;
                for (SkillLearn temp : skills2) {
                    if (temp.getLevel() != level || temp.getId() != id) continue;
                    return temp;
                }
                return null;
            }
            case SUB_UNIT: {
                Set<SkillLearn> skills3 = this._subUnitSkillTree;
                for (SkillLearn temp : skills3) {
                    if (temp.getLevel() != level || temp.getId() != id) continue;
                    return temp;
                }
                return null;
            }
            case GENERAL: {
                skills = (Collection)this._generalSkillTree.get(player.getActiveClassId());
                break;
            }
            case HERO: {
                skills = this._heroSkillTree;
                break;
            }
            case GM: {
                skills = this._gmSkillTree;
                break;
            }
            case CUSTOM: {
                skills = this._customSkillTree;
                break;
            }
            case MULTICLASS: {
                if (Config.MULTICLASS_SYSTEM_ENABLED) {
                    if (classId != null) {
                        TIntObjectMap map = (TIntObjectMap)this._multiclassLearnSkillTree.get(player.getActiveClassId());
                        if (map == null) {
                            return null;
                        }
                        skills = (Collection)map.get(classId.getId());
                        break;
                    }
                    skills = (Collection)this._multiclassCheckSkillTree.get(player.getActiveClassId());
                    break;
                }
                return null;
            }
            default: {
                return null;
            }
        }
        if (skills == null) {
            return null;
        }
        for (SkillLearn temp : skills) {
            if (!temp.isOfRace(player.getRace()) || temp.getLevel() != level || temp.getId() != id) continue;
            return temp;
        }
        return null;
    }

    public boolean isSkillPossible(Player player, Skill skill, AcquireType type) {
        return this.isSkillPossible(player, null, skill, type);
    }

    public boolean isSkillPossible(Player player, ClassId classId, Skill skill, AcquireType type) {
        switch (type) {
            case CLAN: 
            case SUB_UNIT: {
                if (player.getClan() != null) break;
                return false;
            }
            case HERO: {
                if (player.isHero() && player.isBaseClassActive()) break;
                return false;
            }
            case GM: {
                if (player.isGM()) break;
                return false;
            }
            case MULTICLASS: {
                if (Config.MULTICLASS_SYSTEM_ENABLED) break;
                return false;
            }
        }
        SkillLearn learn = this.getSkillLearn(player, classId, skill.getId(), skill.getLevel(), type);
        if (learn == null) {
            return false;
        }
        return learn.testCondition(player);
    }

    public boolean isSkillPossible(Player player, Skill skill) {
        for (AcquireType aq : AcquireType.VALUES) {
            if (!this.isSkillPossible(player, skill, aq)) continue;
            return true;
        }
        return false;
    }

    public boolean containsInTree(Skill skill, AcquireType type) {
        Set<SkillLearn> skills;
        switch (type) {
            case NORMAL: {
                skills = new HashSet<SkillLearn>();
                for (Set temp : this._normalSkillTree.valueCollection()) {
                    skills.addAll(temp);
                }
                break;
            }
            case FISHING: {
                skills = this._fishingSkillTree;
                break;
            }
            case CLAN: {
                skills = this._pledgeSkillTree;
                break;
            }
            case SUB_UNIT: {
                skills = this._subUnitSkillTree;
                break;
            }
            case GENERAL: {
                skills = new HashSet<SkillLearn>();
                for (Set temp : this._generalSkillTree.valueCollection()) {
                    skills.addAll(temp);
                }
                break;
            }
            case HERO: {
                skills = this._heroSkillTree;
                break;
            }
            case GM: {
                skills = this._gmSkillTree;
                break;
            }
            case CUSTOM: {
                skills = this._customSkillTree;
                break;
            }
            case MULTICLASS: {
                if (Config.MULTICLASS_SYSTEM_ENABLED) {
                    skills = new HashSet<SkillLearn>();
                    for (Set temp : this._multiclassCheckSkillTree.valueCollection()) {
                        skills.addAll(temp);
                    }
                    break;
                }
                return false;
            }
            default: {
                return false;
            }
        }
        for (SkillLearn learn : skills) {
            if (learn.getId() != skill.getId() || learn.getLevel() != skill.getLevel()) continue;
            return true;
        }
        return false;
    }

    public boolean checkLearnCondition(Player player, Clan clan, SkillLearn skillLearn, int level, AcquireType type) {
        if (skillLearn == null) {
            return false;
        }
        if (type == AcquireType.CLAN || type == AcquireType.SUB_UNIT) {
            if (clan == null) {
                return false;
            }
            return skillLearn.getMinLevel() <= clan.getLevel();
        }
        if (player == null) {
            return true;
        }
        if (skillLearn.getMinLevel() > level) {
            return false;
        }
        if (!skillLearn.isOfRace(player.getRace())) {
            return false;
        }
        return skillLearn.testCondition(player);
    }

    private Collection<SkillLearn> checkLearnsConditions(Player player, Clan clan, Collection<SkillLearn> skillLearns, int level, AcquireType type) {
        if (skillLearns == null) {
            return null;
        }
        HashSet<SkillLearn> skills = new HashSet<SkillLearn>();
        for (SkillLearn skillLearn : skillLearns) {
            if (!this.checkLearnCondition(player, clan, skillLearn, level, type)) continue;
            skills.add(skillLearn);
        }
        return skills;
    }

    public void addAllNormalSkillLearns(int classId, Set<SkillLearn> s) {
        HashSet<SkillLearn> set = (HashSet<SkillLearn>)this._normalSkillTree.get(classId);
        if (set == null) {
            set = new HashSet<SkillLearn>();
            this._normalSkillTree.put(classId, set);
        }
        set.addAll(s);
    }

    public void initNormalSkillLearns() {
        TIntObjectHashMap map = new TIntObjectHashMap(this._normalSkillTree);
        this._normalSkillTree.clear();
        for (ClassId classId : ClassId.VALUES) {
            if (classId.isDummy()) continue;
            Set skills = (Set)map.get(classId.getId());
            if (skills == null) {
                this.info("Not found NORMAL skill learn for class " + classId.getId());
                continue;
            }
            this._normalSkillTree.put(classId.getId(), skills);
            ClassId secondparent = classId.getParent(1);
            if (secondparent == classId.getParent(0)) {
                secondparent = null;
            }
            ClassId tempClassId = classId.getParent(0);
            while (tempClassId != null) {
                if (this._normalSkillTree.containsKey(tempClassId.getId())) {
                    skills.addAll((Collection)this._normalSkillTree.get(tempClassId.getId()));
                }
                if ((tempClassId = tempClassId.getParent(0)) != null || secondparent == null) continue;
                tempClassId = secondparent;
                secondparent = secondparent.getParent(1);
            }
        }
        if (Config.MULTICLASS_SYSTEM_ENABLED) {
            for (ClassId classId : ClassId.VALUES) {
                if (classId.isDummy()) continue;
                TIntObjectHashMap multiMap = new TIntObjectHashMap();
                HashSet multiSet = new HashSet();
                for (ClassId sameLevelClassId : ClassId.VALUES) {
                    if (!MulticlassUtils.checkMulticlass(classId, sameLevelClassId)) continue;
                    HashSet<SkillLearn> skills = new HashSet<SkillLearn>();
                    block4: for (SkillLearn sl : (Set<SkillLearn>)this._normalSkillTree.get(sameLevelClassId.getId())) {
                        long costItemCount;
                        int costItemId;
                        double costItemCountModifierBasedOnSp;
                        int costItemIdBasedOnSp;
                        double spModifier;
                        for (SkillLearn temp : (Set<SkillLearn>)this._normalSkillTree.get(classId.getId())) {
                            if (sl.getId() != temp.getId() || sl.getLevel() != temp.getLevel()) continue;
                            continue block4;
                        }
                        if (sl.getClassLevel() == ClassLevel.FIRST) {
                            spModifier = Config.MULTICLASS_SYSTEM_1ST_CLASS_SP_MODIFIER;
                            costItemIdBasedOnSp = Config.MULTICLASS_SYSTEM_1ST_CLASS_COST_ITEM_ID_BASED_ON_SP;
                            costItemCountModifierBasedOnSp = Config.MULTICLASS_SYSTEM_1ST_CLASS_COST_ITEM_COUNT_MODIFIER_BASED_ON_SP;
                            costItemId = Config.MULTICLASS_SYSTEM_1ST_CLASS_COST_ITEM_ID;
                            costItemCount = Config.MULTICLASS_SYSTEM_1ST_CLASS_COST_ITEM_COUNT;
                        } else if (sl.getClassLevel() == ClassLevel.SECOND) {
                            spModifier = Config.MULTICLASS_SYSTEM_2ND_CLASS_SP_MODIFIER;
                            costItemIdBasedOnSp = Config.MULTICLASS_SYSTEM_2ND_CLASS_COST_ITEM_ID_BASED_ON_SP;
                            costItemCountModifierBasedOnSp = Config.MULTICLASS_SYSTEM_2ND_CLASS_COST_ITEM_COUNT_MODIFIER_BASED_ON_SP;
                            costItemId = Config.MULTICLASS_SYSTEM_2ND_CLASS_COST_ITEM_ID;
                            costItemCount = Config.MULTICLASS_SYSTEM_2ND_CLASS_COST_ITEM_COUNT;
                        } else if (sl.getClassLevel() == ClassLevel.THIRD) {
                            spModifier = Config.MULTICLASS_SYSTEM_3RD_CLASS_SP_MODIFIER;
                            costItemIdBasedOnSp = Config.MULTICLASS_SYSTEM_3RD_CLASS_COST_ITEM_ID_BASED_ON_SP;
                            costItemCountModifierBasedOnSp = Config.MULTICLASS_SYSTEM_3RD_CLASS_COST_ITEM_COUNT_MODIFIER_BASED_ON_SP;
                            costItemId = Config.MULTICLASS_SYSTEM_3RD_CLASS_COST_ITEM_ID;
                            costItemCount = Config.MULTICLASS_SYSTEM_3RD_CLASS_COST_ITEM_COUNT;
                        } else {
                            spModifier = Config.MULTICLASS_SYSTEM_NON_CLASS_SP_MODIFIER;
                            costItemIdBasedOnSp = Config.MULTICLASS_SYSTEM_NON_CLASS_COST_ITEM_ID_BASED_ON_SP;
                            costItemCountModifierBasedOnSp = Config.MULTICLASS_SYSTEM_NON_CLASS_COST_ITEM_COUNT_MODIFIER_BASED_ON_SP;
                            costItemId = Config.MULTICLASS_SYSTEM_NON_CLASS_COST_ITEM_ID;
                            costItemCount = Config.MULTICLASS_SYSTEM_NON_CLASS_COST_ITEM_COUNT;
                        }
                        SkillLearn skillLearn = new SkillLearn(sl.getId(), sl.getLevel(), sl.getMinLevel(), (int)((double)Math.max(1, sl.getCost()) * spModifier), sl.getItemId(), sl.getItemCount(), false, sl.getRace(), sl.getClassLevel());
                        if (costItemIdBasedOnSp > 0 && costItemCountModifierBasedOnSp > 0.0) {
                            skillLearn.addAdditionalRequiredItem(costItemIdBasedOnSp, Math.max(1L, (long)((double)skillLearn.getCost() * costItemCountModifierBasedOnSp)));
                        }
                        if (costItemId > 0 && costItemCount > 0L) {
                            skillLearn.addAdditionalRequiredItem(costItemId, costItemCount);
                        }
                        skills.add(skillLearn);
                    }
                    multiMap.put(sameLevelClassId.getId(), skills);
                    multiSet.addAll(skills);
                }
                this._multiclassCheckSkillTree.put(classId.getId(), multiSet);
                this._multiclassLearnSkillTree.put(classId.getId(), multiMap);
            }
        }
    }

    public void addAllGeneralSkillLearns(int classId, Set<SkillLearn> s) {
        HashSet<SkillLearn> set = (HashSet<SkillLearn>)this._generalSkillTree.get(classId);
        if (set == null) {
            set = new HashSet<SkillLearn>();
            this._generalSkillTree.put(classId, set);
        }
        set.addAll(s);
    }

    public void initGeneralSkillLearns() {
        TIntObjectHashMap map = new TIntObjectHashMap(this._generalSkillTree);
        Set globalList = (Set)map.remove(-1);
        this._generalSkillTree.clear();
        for (ClassId classId : ClassId.VALUES) {
            if (classId.isDummy()) continue;
            HashSet tempList = (HashSet)map.get(classId.getId());
            if (tempList == null) {
                tempList = new HashSet();
            }
            HashSet skills = new HashSet();
            this._generalSkillTree.put(classId.getId(), skills);
            ClassId secondparent = classId.getParent(1);
            if (secondparent == classId.getParent(0)) {
                secondparent = null;
            }
            ClassId tempClassId = classId.getParent(0);
            while (tempClassId != null) {
                if (this._generalSkillTree.containsKey(tempClassId.getId())) {
                    tempList.addAll((Collection)this._generalSkillTree.get(tempClassId.getId()));
                }
                if ((tempClassId = tempClassId.getParent(0)) != null || secondparent == null) continue;
                tempClassId = secondparent;
                secondparent = secondparent.getParent(1);
            }
            tempList.addAll(globalList);
            skills.addAll(tempList);
        }
    }

    public void addAllFishingLearns(Set<SkillLearn> s) {
        this._fishingSkillTree.addAll(s);
    }

    public void addAllSubUnitLearns(Set<SkillLearn> s) {
        this._subUnitSkillTree.addAll(s);
    }

    public void addAllPledgeLearns(Set<SkillLearn> s) {
        this._pledgeSkillTree.addAll(s);
    }

    public void addAllHeroLearns(Set<SkillLearn> s) {
        this._heroSkillTree.addAll(s);
    }

    public void addAllGMLearns(Set<SkillLearn> s) {
        this._gmSkillTree.addAll(s);
    }

    public void addAllCustomLearns(Set<SkillLearn> s) {
        this._customSkillTree.addAll(s);
    }

    public void log() {
        this.info("load " + this.sizeTroveMap(this._normalSkillTree) + " normal learns for " + this._normalSkillTree.size() + " classes.");
        this.info("load " + this.sizeTroveMap(this._generalSkillTree) + " general skills learns for " + this._generalSkillTree.size() + " classes.");
        this.info("load " + this._fishingSkillTree.size() + " fishing learns.");
        this.info("load " + this._pledgeSkillTree.size() + " pledge learns.");
        this.info("load " + this._subUnitSkillTree.size() + " sub unit learns.");
        this.info("load " + this._heroSkillTree.size() + " hero skills learns.");
        this.info("load " + this._gmSkillTree.size() + " GM skills learns.");
        this.info("load " + this._customSkillTree.size() + " custom skills learns.");
    }

    public int size() {
        return 0;
    }

    public void clear() {
        this._normalSkillTree.clear();
        this._fishingSkillTree.clear();
        this._pledgeSkillTree.clear();
        this._subUnitSkillTree.clear();
        this._generalSkillTree.clear();
        this._heroSkillTree.clear();
        this._gmSkillTree.clear();
        this._customSkillTree.clear();
    }

    private int sizeTroveMapMap(TIntObjectMap<TIntObjectMap<Set<SkillLearn>>> a) {
        int i = 0;
        TIntObjectIterator iterator = a.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            i += this.sizeTroveMap((TIntObjectMap<Set<SkillLearn>>)((TIntObjectMap)iterator.value()));
        }
        return i;
    }

    private int sizeTroveMap(TIntObjectMap<Set<SkillLearn>> a) {
        int i = 0;
        TIntObjectIterator iterator = a.iterator();
        while (iterator.hasNext()) {
            iterator.advance();
            i += ((Set)iterator.value()).size();
        }
        return i;
    }
}

