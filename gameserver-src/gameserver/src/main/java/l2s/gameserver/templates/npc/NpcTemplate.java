/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.templates.npc;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.lang.reflect.Constructor;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.ai.NpcAI;
import l2s.gameserver.data.string.NpcNameHolder;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.listener.hooks.ListenerHook;
import l2s.gameserver.listener.hooks.ListenerHookType;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.RaidBossInstance;
import l2s.gameserver.model.instances.ReflectionBossInstance;
import l2s.gameserver.model.quest.Quest;
import l2s.gameserver.model.quest.QuestEventType;
import l2s.gameserver.model.reward.RewardList;
import l2s.gameserver.scripts.Scripts;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.templates.CreatureTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.TeleportLocation;
import l2s.gameserver.templates.npc.Faction;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.npc.RandomActions;
import l2s.gameserver.templates.npc.WalkerRoute;
import l2s.gameserver.templates.skill.EffectTemplate;
import org.apache.commons.lang3.ArrayUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NpcTemplate
extends CreatureTemplate {
    private static final Logger _log = LoggerFactory.getLogger(NpcTemplate.class);
    @SuppressWarnings("unchecked")
    public static final Constructor<NpcInstance> DEFAULT_TYPE_CONSTRUCTOR = (Constructor<NpcInstance>)(Constructor<?>)NpcInstance.class.getConstructors()[0];
    @SuppressWarnings("unchecked")
    public static final Constructor<NpcAI> DEFAULT_AI_CONSTRUCTOR = (Constructor<NpcAI>)(Constructor<?>)NpcAI.class.getConstructors()[0];
    private static final Map<String, Constructor<NpcAI>> AI_CONSTRUCTORS = new HashMap<String, Constructor<NpcAI>>();
    private final int _npcId;
    public final String name;
    public final String title;
    public int level;
    public final long rewardExp;
    public final long rewardSp;
    public int aggroRange;
    public final int rhand;
    public final int lhand;
    public final double rateHp;
    private Faction faction = Faction.NONE;
    public final int displayId;
    private final ShotsType _shots;
    public boolean isRaid = false;
    private StatsSet _AIParams;
    private int race = 0;
    private final int _castleId;
    private List<RewardList> _rewardList = Collections.emptyList();
    private TIntObjectMap<List<TeleportLocation>> _teleportList = new TIntObjectHashMap(1);
    private List<MinionData> _minions = Collections.emptyList();
    private Map<QuestEventType, Set<Quest>> _questEvents = Collections.emptyMap();
    private TIntObjectMap<Skill> _skills = new TIntObjectHashMap();
    private Skill[] _damageSkills = Skill.EMPTY_ARRAY;
    private Skill[] _dotSkills = Skill.EMPTY_ARRAY;
    private Skill[] _debuffSkills = Skill.EMPTY_ARRAY;
    private Skill[] _buffSkills = Skill.EMPTY_ARRAY;
    private Skill[] _stunSkills = Skill.EMPTY_ARRAY;
    private Skill[] _healSkills = Skill.EMPTY_ARRAY;
    private Class<NpcInstance> _classType = NpcInstance.class;
    private Constructor<NpcInstance> _constructorType = DEFAULT_TYPE_CONSTRUCTOR;
    private final String _htmRoot;
    private TIntObjectMap<WalkerRoute> _walkerRoute = new TIntObjectHashMap();
    private RandomActions _randomActions = null;
    public final int _enchantEffect;
    private final int _baseRandDam;
    private final int _baseReuseDelay;
    private final double _basePHitModify;
    private final double _basePAvoidModify;
    private final double _baseHitTimeFactor;
    private final int _baseSafeHeight;
    private final String _aiType;
    private final Map<ListenerHookType, Set<ListenerHook>> _listenerHooks = new HashMap<ListenerHookType, Set<ListenerHook>>();
    private boolean isNoClan;

    public NpcTemplate(StatsSet set) {
        super(set);
        this._npcId = set.getInteger("npcId");
        this.displayId = set.getInteger("displayId");
        this.name = set.getString("name");
        this.title = set.getString("title");
        this.level = set.getInteger("level");
        this.rewardExp = set.getLong("rewardExp");
        this.rewardSp = set.getLong("rewardSp");
        this.aggroRange = set.getInteger("aggroRange");
        this.rhand = set.getInteger("rhand", 0);
        this.lhand = set.getInteger("lhand", 0);
        this.rateHp = set.getDouble("baseHpRate");
        this._htmRoot = set.getString("htm_root", null);
        this._shots = (ShotsType)set.getEnum("shots", ShotsType.class, ShotsType.NONE);
        this._castleId = set.getInteger("castle_id", 0);
        this._AIParams = (StatsSet)((Object)set.getObject("aiParams", (Object)StatsSet.EMPTY));
        this._enchantEffect = set.getInteger("enchant_effect", 0);
        this._baseRandDam = set.getInteger("baseRandDam", 5 + (int)Math.sqrt(this.level));
        this._baseReuseDelay = set.getInteger("baseReuseDelay", 0);
        this._basePHitModify = set.getDouble("basePHitModify", 0.0);
        this._basePAvoidModify = set.getDouble("basePAvoidModify", 0.0);
        this._baseHitTimeFactor = set.getDouble("baseHitTimeFactor", 0.0);
        this._baseSafeHeight = set.getInteger("baseSafeHeight", 100);
        this.setType(set.getString("type", null));
        this._aiType = set.getString("ai_type", "NpcAI");
    }

    public Class<? extends NpcInstance> getInstanceClass() {
        return this._classType;
    }

    public Constructor<? extends NpcInstance> getInstanceConstructor() {
        return this._constructorType;
    }

    public boolean isInstanceOf(Class<?> _class) {
        return _class.isAssignableFrom(this.getInstanceClass());
    }

    public NpcInstance getNewInstance(MultiValueSet<String> set) {
        try {
            return this._constructorType.newInstance(IdFactory.getInstance().getNextId(), this, set);
        }
        catch (Exception e) {
            _log.error("Unable to create instance of NPC " + this._npcId, (Throwable)e);
            return null;
        }
    }

    public NpcInstance getNewInstance() {
        return this.getNewInstance(StatsSet.EMPTY);
    }

    public NpcAI getNewAI(NpcInstance npc) {
        String ai = npc.getParameter("ai_type", this._aiType);
        Constructor<NpcAI> constructorAI = AI_CONSTRUCTORS.get(ai);
        if (constructorAI == null) {
            Class<?> classAI = null;
            try {
                classAI = Class.forName("l2s.gameserver.ai." + ai);
            }
            catch (ClassNotFoundException e) {
                classAI = Scripts.getInstance().getClasses().get("ai." + ai);
            }
            if (classAI == null) {
                classAI = NpcAI.class;
                _log.error("Not found ai class for ai: " + ai + ". NpcId: " + npc.getNpcId());
            }
            @SuppressWarnings("unchecked")
            Constructor<NpcAI> tmpAI = (Constructor<NpcAI>)(Constructor<?>)classAI.getConstructors()[0];
            constructorAI = tmpAI;
            if (classAI.isAnnotationPresent(Deprecated.class)) {
                _log.error("Ai type: " + ai + ", is deprecated. NpcId: " + npc.getNpcId());
            }
            AI_CONSTRUCTORS.put(ai, constructorAI);
        }
        try {
            return constructorAI.newInstance(npc);
        }
        catch (Exception e) {
            _log.error("Unable to create ai of NPC " + npc.getNpcId(), (Throwable)e);
            return new NpcAI(npc);
        }
    }

    protected void setType(String type) {
        Class<?> classType = null;
        try {
            classType = Class.forName("l2s.gameserver.model.instances." + type + "Instance");
        }
        catch (ClassNotFoundException e) {
            classType = Scripts.getInstance().getClasses().get("npc.model." + type + "Instance");
        }
        if (classType == null) {
            _log.error("Not found type class for type: " + type + ". NpcId: " + this._npcId);
        }
        if (this._npcId == 0) {
            try {
                classType = Class.forName("l2s.gameserver.model.instances.NpcInstance");
            }
            catch (ClassNotFoundException classNotFoundException) {
                // empty catch block
            }
            @SuppressWarnings("unchecked")
            Class<NpcInstance> ct1 = (Class<NpcInstance>)classType;
            this._classType = ct1;
            @SuppressWarnings("unchecked")
            Constructor<NpcInstance> con1 = (Constructor<NpcInstance>)(Constructor<?>)this._classType.getConstructors()[0];
            this._constructorType = con1;
        } else {
            @SuppressWarnings("unchecked")
            Class<NpcInstance> ct2 = (Class<NpcInstance>)classType;
            this._classType = ct2;
            @SuppressWarnings("unchecked")
            Constructor<NpcInstance> con2 = (Constructor<NpcInstance>)(Constructor<?>)this._classType.getConstructors()[0];
            this._constructorType = con2;
        }
        if (this._classType.isAnnotationPresent(Deprecated.class)) {
            _log.error("Npc type: " + type + ", is deprecated. NpcId: " + this._npcId);
        }
        this.isRaid = this.isInstanceOf(RaidBossInstance.class) && !this.isInstanceOf(ReflectionBossInstance.class);
    }

    public void addTeleportList(int id, List<TeleportLocation> list) {
        this._teleportList.put(id, list);
    }

    public List<TeleportLocation> getTeleportList(int id) {
        return (List)this._teleportList.get(id);
    }

    public TIntObjectMap<List<TeleportLocation>> getTeleportList() {
        return this._teleportList;
    }

    public void addRewardList(RewardList rewardList) {
        if (this._rewardList.isEmpty()) {
            this._rewardList = new CopyOnWriteArrayList<RewardList>();
        }
        this._rewardList.add(rewardList);
    }

    public void removeRewardList(RewardList rewardList) {
        this._rewardList.remove(rewardList);
    }

    public Collection<RewardList> getRewards() {
        return this._rewardList;
    }

    public void addMinion(MinionData minion) {
        if (this._minions.isEmpty()) {
            this._minions = new ArrayList<MinionData>(1);
        }
        this._minions.add(minion);
    }

    public void setFaction(Faction faction) {
        this.faction = faction;
    }

    public Faction getFaction() {
        return this.faction;
    }

    public void addSkill(Skill skill) {
        this._skills.put(skill.getId(), skill);
        if (skill.isNotUsedByAI() || skill.getTargetType() == Skill.SkillTargetType.TARGET_NONE || skill.getSkillType() == Skill.SkillType.NOTDONE || !skill.isActive()) {
            return;
        }
        switch (skill.getSkillType()) {
            case PDAM: 
            case MANADAM: 
            case MDAM: 
            case DRAIN: 
            case DRAIN_SOUL: {
                boolean added = false;
                for (EffectTemplate eff : skill.getEffectTemplates(EffectUseType.NORMAL)) {
                    String effName = eff.getName();
                    if (effName.equalsIgnoreCase("Stun")) {
                        this._stunSkills = (Skill[])ArrayUtils.add((Object[])this._stunSkills, (Object)skill);
                        added = true;
                        continue;
                    }
                    if (effName.equalsIgnoreCase("t_hp")) {
                        if (!(eff.getValue() < 0.0)) continue;
                        this._dotSkills = (Skill[])ArrayUtils.add((Object[])this._dotSkills, (Object)skill);
                        added = true;
                        continue;
                    }
                    if (!effName.equalsIgnoreCase("ManaDamOverTime") && !effName.equalsIgnoreCase("LDManaDamOverTime")) continue;
                    this._dotSkills = (Skill[])ArrayUtils.add((Object[])this._dotSkills, (Object)skill);
                    added = true;
                }
                if (added) break;
                this._damageSkills = (Skill[])ArrayUtils.add((Object[])this._damageSkills, (Object)skill);
                break;
            }
            case DOT: 
            case MDOT: 
            case POISON: {
                this._dotSkills = (Skill[])ArrayUtils.add((Object[])this._dotSkills, (Object)skill);
                break;
            }
            case DEBUFF: 
            case SLEEP: 
            case ROOT: 
            case PARALYZE: 
            case MUTE: {
                this._debuffSkills = (Skill[])ArrayUtils.add((Object[])this._debuffSkills, (Object)skill);
                break;
            }
            case BUFF: {
                this._buffSkills = (Skill[])ArrayUtils.add((Object[])this._buffSkills, (Object)skill);
                break;
            }
            case STUN: {
                this._stunSkills = (Skill[])ArrayUtils.add((Object[])this._stunSkills, (Object)skill);
                break;
            }
            case HEAL: 
            case HEAL_PERCENT: 
            case HOT: {
                this._healSkills = (Skill[])ArrayUtils.add((Object[])this._healSkills, (Object)skill);
                break;
            }
        }
    }

    public Skill[] getDamageSkills() {
        return this._damageSkills;
    }

    public Skill[] getDotSkills() {
        return this._dotSkills;
    }

    public Skill[] getDebuffSkills() {
        return this._debuffSkills;
    }

    public Skill[] getBuffSkills() {
        return this._buffSkills;
    }

    public Skill[] getStunSkills() {
        return this._stunSkills;
    }

    public Skill[] getHealSkills() {
        return this._healSkills;
    }

    public List<MinionData> getMinionData() {
        return this._minions;
    }

    public TIntObjectMap<Skill> getSkills() {
        return this._skills;
    }

    public void addQuestEvent(QuestEventType eventType, Quest quest) {
        Set<Quest> quests;
        if (this._questEvents.isEmpty()) {
            this._questEvents = new HashMap<QuestEventType, Set<Quest>>();
        }
        if ((quests = this._questEvents.get(eventType)) == null) {
            quests = new HashSet<Quest>();
            this._questEvents.put(eventType, quests);
        }
        quests.add(quest);
    }

    public Set<Quest> getEventQuests(QuestEventType eventType) {
        return this._questEvents.get(eventType);
    }

    public int getRace() {
        return this.race;
    }

    public void setRace(int newrace) {
        this.race = newrace;
    }

    public boolean isUndead() {
        return this.race == 1;
    }

    public String toString() {
        return "Npc template " + this.name + "[" + this._npcId + "]";
    }

    @Override
    public int getId() {
        return this._npcId;
    }

    public String getName() {
        return this.name;
    }

    public final String getName(Player player) {
        String name = NpcNameHolder.getInstance().getNpcName(player, this.getId());
        return name == null ? this.name : name;
    }

    public ShotsType getShots() {
        return this._shots;
    }

    public final StatsSet getAIParams() {
        return this._AIParams;
    }

    public final void setAIParam(String name, Object value) {
        if (this._AIParams == StatsSet.EMPTY) {
            this._AIParams = new StatsSet();
        }
        this._AIParams.set(name, value);
    }

    public int getCastleId() {
        return this._castleId;
    }

    public Map<QuestEventType, Set<Quest>> getQuestEvents() {
        return this._questEvents;
    }

    public String getHtmRoot() {
        return this._htmRoot;
    }

    public void addWalkerRoute(WalkerRoute walkerRoute) {
        if (!walkerRoute.isValid()) {
            return;
        }
        this._walkerRoute.put(walkerRoute.getId(), walkerRoute);
    }

    public WalkerRoute getWalkerRoute(int id) {
        return (WalkerRoute)this._walkerRoute.get(id);
    }

    public void setRandomActions(RandomActions randomActions) {
        this._randomActions = randomActions;
    }

    public RandomActions getRandomActions() {
        return this._randomActions;
    }

    public int getEnchantEffect() {
        return this._enchantEffect;
    }

    @Override
    public int getBaseRandDam() {
        return this._baseRandDam;
    }

    public int getBaseReuseDelay() {
        return this._baseReuseDelay;
    }

    public void addListenerHook(ListenerHookType type, ListenerHook hook) {
        Set<ListenerHook> hooks = this._listenerHooks.get(type);
        if (hooks == null) {
            hooks = new HashSet<ListenerHook>();
            this._listenerHooks.put(type, hooks);
        }
        hooks.add(hook);
    }

    public Set<ListenerHook> getListenerHooks(ListenerHookType type) {
        Set<ListenerHook> hooks = this._listenerHooks.get(type);
        if (hooks == null) {
            return Collections.emptySet();
        }
        return hooks;
    }

    public boolean isNoClan() {
        return this.isNoClan;
    }

    public void setNoClan(boolean noClan) {
        this.isNoClan = noClan;
    }

    public static enum ShotsType {
        NONE,
        SOUL,
        SPIRIT,
        BSPIRIT,
        SOUL_SPIRIT,
        SOUL_BSPIRIT;

    }
}

