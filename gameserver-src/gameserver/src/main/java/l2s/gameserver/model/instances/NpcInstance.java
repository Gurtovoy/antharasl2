package l2s.gameserver.model.instances;

import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Set;
import java.util.StringTokenizer;
import java.util.TreeSet;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.geometry.Circle;
import l2s.commons.geometry.Shape;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.NpcAI;
import l2s.gameserver.data.QuestHolder;
import l2s.gameserver.data.htm.HtmCache;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.MultiSellHolder;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.handler.bypass.BypassHolder;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.instancemanager.EventTriggersManager;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.NpcListener;
import l2s.gameserver.listener.hooks.ListenerHook;
import l2s.gameserver.listener.hooks.ListenerHookType;
import l2s.gameserver.model.AggroList;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.MinionList;
import l2s.gameserver.model.MinionSpawner;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.World;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.listener.NpcListenerList;
import l2s.gameserver.model.actor.recorder.NpcStatsChangeRecorder;
import l2s.gameserver.model.actor.stat.NpcStat;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.model.base.MountType;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.ClanHall;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.model.instances.RaidBossInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.model.quest.Quest;
import l2s.gameserver.model.quest.QuestEventType;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.model.reward.RewardList;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.c2s.RequestItemEnsoul;
import l2s.gameserver.network.l2.c2s.RequestTryEnSoulExtraction;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.AcquireSkillDonePacket;
import l2s.gameserver.network.l2.s2c.AutoAttackStartPacket;
import l2s.gameserver.network.l2.s2c.ExAcquirableSkillListByClass;
import l2s.gameserver.network.l2.s2c.ExChangeNPCState;
import l2s.gameserver.network.l2.s2c.ExEnSoulExtractionShow;
import l2s.gameserver.network.l2.s2c.ExShowBaseAttributeCancelWindow;
import l2s.gameserver.network.l2.s2c.ExShowEnsoulWindow;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.MoveToPawnPacket;
import l2s.gameserver.network.l2.s2c.NpcInfoPacket;
import l2s.gameserver.network.l2.s2c.NpcInfoState;
import l2s.gameserver.network.l2.s2c.PackageToListPacket;
import l2s.gameserver.network.l2.s2c.RadarControlPacket;
import l2s.gameserver.network.l2.s2c.SocialActionPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.network.l2.s2c.updatetype.NpcInfoType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.taskmanager.DecayTaskManager;
import l2s.gameserver.taskmanager.LazyPrecisionTaskManager;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.TeleportLocation;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.npc.BuyListTemplate;
import l2s.gameserver.templates.npc.Faction;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.utils.HtmlUtils;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.MapUtils;
import l2s.gameserver.utils.ReflectionUtils;
import l2s.gameserver.utils.WarehouseFunctions;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class NpcInstance
extends Creature {
    public static final int BASE_CORPSE_TIME = 7;
    public static final String CORPSE_TIME = "corpse_time";
    public static final String NO_CHAT_WINDOW = "noChatWindow";
    public static final String NO_RANDOM_WALK = "noRandomWalk";
    public static final String NO_RANDOM_ANIMATION = "noRandomAnimation";
    public static final String NO_SHIFT_CLICK = "noShiftClick";
    public static final String NO_LETHAL = "noLethal";
    public static final String TARGETABLE = "targetable";
    public static final String SHOW_NAME = "show_name";
    public static final String NO_SLEEP_MODE = "no_sleep_mode";
    public static final String IS_IMMORTAL = "is_immortal";
    public static final String EVENT_TRIGGER_ID = "event_trigger_id";
    public static final String STATE_ID_VAR = "state_id";
    private static final Logger _log = LoggerFactory.getLogger(NpcInstance.class);
    private int _personalAggroRange = -1;
    private int _level = 0;
    private long _deathTime = 0L;
    protected int _spawnAnimation = 2;
    private long _spawnTime = 0L;
    private int _currentLHandId;
    private int _currentRHandId;
    private double _collisionHeightModifier = 1.0;
    private double _collisionRadiusModifier = 1.0;
    private int npcState = 0;
    protected boolean _hasRandomAnimation;
    protected boolean _hasRandomWalk;
    protected boolean _hasChatWindow;
    private Future<?> _decayTask;
    private Future<?> _animationTask;
    private AggroList _aggroList;
    private boolean _noLethal;
    private boolean _showName;
    private boolean _noShiftClick;
    private Castle _nearestCastle;
    private ClanHall _nearestClanHall;
    private NpcString _nameNpcString = NpcString.NONE;
    private NpcString _titleNpcString = NpcString.NONE;
    private Spawner _spawn;
    private Location _spawnedLoc = new Location();
    private SpawnRange _spawnRange;
    private boolean _spawnLeaderDepends = true;
    private HardReference<NpcInstance> _masterRef = null;
    private MinionList _minionList = null;
    private MultiValueSet<String> _parameters = StatsSet.EMPTY;
    private final int _enchantEffect;
    private final boolean _isNoSleepMode;
    private final int _corpseTime;
    private final boolean _isImmortal;
    private String _ownerName = "";
    private HardReference<Player> _ownerRef = HardReferences.emptyRef();
    private final TIntSet _eventTriggers = new TIntHashSet();
    private final String _supportSpawnGroup;
    private List<RewardList> _rewardLists = null;
    private boolean _geoControlEnabled;
    private final int _geoRadius;
    private final int _geoHeight;
    private final boolean _immobilized;
    private final boolean deathImmune;
    protected boolean _unAggred = false;
    private int _displayId = 0;
    private ScheduledFuture<?> _broadcastCharInfoTask;
    protected long _lastSocialAction;
    private boolean _isBusy;
    private String _busyMessage = "";
    private boolean _isUnderground = false;

    public NpcInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template);
        if (template == null) {
            throw new NullPointerException("No template for Npc. Please check your datapack is setup correctly.");
        }
        this.setParameters(template.getAIParams());
        this.setParameters(set);
        this._hasRandomAnimation = !this.getParameter(NO_RANDOM_ANIMATION, false) && Config.MAX_NPC_ANIMATION > 0;
        this._hasRandomWalk = !this.getParameter(NO_RANDOM_WALK, false);
        this._noShiftClick = this.getParameter(NO_SHIFT_CLICK, this.isPeaceNpc());
        this._noLethal = this.getParameter(NO_LETHAL, false);
        this.setHasChatWindow(!this.getParameter(NO_CHAT_WINDOW, false));
        this.setTargetable(this.getParameter(TARGETABLE, true));
        this.setShowName(this.getParameter(SHOW_NAME, true));
        this.npcState = this.getParameter(STATE_ID_VAR, 0);
        this._isImmortal = this.getParameter(IS_IMMORTAL, false);
        for (Skill skill : template.getSkills().valueCollection()) {
            this.addSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill));
        }
        this.setName(template.name);
        this.setTitle(template.title);
        this.setLHandId(this.getTemplate().lhand);
        this.setRHandId(this.getTemplate().rhand);
        this._aggroList = new AggroList(this);
        this.setFlying(this.getParameter("isFlying", false));
        int enchant = Math.min(127, this.getTemplate().getEnchantEffect());
        if (enchant == 0 && Config.NPC_RANDOM_ENCHANT) {
            enchant = Rnd.get((int)0, (int)18);
        }
        this._enchantEffect = enchant;
        this._isNoSleepMode = this.getParameter(NO_SLEEP_MODE, false);
        this._corpseTime = this.getParameter(CORPSE_TIME, 7);
        this._supportSpawnGroup = this.getParameter("support_spawn_group", null);
        this._geoControlEnabled = this.getParameter("geodata_enabled", false);
        this._geoRadius = this.getParameter("geodata_radius", (int)this.getTemplate().getCollisionRadius());
        this._geoHeight = this.getParameter("geodata_height", (int)this.getTemplate().getCollisionHeight());
        this._immobilized = this.getParameter("is_immobilized", false);
        this.deathImmune = this.getParameter("death_immune", false);
    }

    @SuppressWarnings("unchecked")
    public HardReference<NpcInstance> getRef() {
        return (HardReference<NpcInstance>) super.getRef();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public NpcAI getAI() {
        if (this._ai == null) {
            NpcInstance npcInstance = this;
            synchronized (npcInstance) {
                if (this._ai == null) {
                    this._ai = this.getTemplate().getNewAI(this);
                }
            }
        }
        return (NpcAI)this._ai;
    }

    public Location getSpawnedLoc() {
        return this.getLeader() != null && this.isSpawnLeaderDepends() ? this.getLeader().getLoc() : this._spawnedLoc;
    }

    public void setSpawnedLoc(Location loc) {
        this._spawnedLoc = loc;
    }

    public int getRightHandItem() {
        return this._currentRHandId;
    }

    public int getLeftHandItem() {
        return this._currentLHandId;
    }

    public void setLHandId(int newWeaponId) {
        this._currentLHandId = newWeaponId;
    }

    public void setRHandId(int newWeaponId) {
        this._currentRHandId = newWeaponId;
    }

    @Override
    protected void onReduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean isDot) {
        Creature damager = attacker;
        if (attacker.isConfused()) {
            block0: for (Abnormal abnormal : attacker.getAbnormalList()) {
                for (EffectHandler effect : abnormal.getEffects()) {
                    if (!effect.getName().equalsIgnoreCase("Discord")) continue;
                    damager = abnormal.getEffector();
                    continue block0;
                }
            }
        }
        this.getAggroList().addDamageHate(damager, (int)Math.min(damage, this.getCurrentHp()), 0);
        super.onReduceCurrentHp(damage, attacker, skill, awake, standUp, directHp, isDot);
    }

    @Override
    protected void onDeath(Creature killer) {
        this._deathTime = System.currentTimeMillis();
        if (this.isMonster() && ((MonsterInstance)this).isSpoiled()) {
            this.startDecay(20000L);
        } else {
            this.startDecay((long)this._corpseTime * 1000L);
        }
        this.setLHandId(this.getTemplate().lhand);
        this.setRHandId(this.getTemplate().rhand);
        this.getAI().stopAITask();
        this.stopAttackStanceTask();
        this.stopRandomAnimation();
        if (this.getLeader() != null) {
            this.getLeader().notifyMinionDied(this);
        }
        if (this.hasMinions()) {
            this.getMinionList().onMasterDeath();
        }
        for (ListenerHook hook : this.getTemplate().getListenerHooks(ListenerHookType.NPC_KILL)) {
            if (killer == null || killer.getPlayer() == null) continue;
            hook.onNpcKill(this, killer.getPlayer());
        }
        for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.NPC_KILL)) {
            if (killer == null || killer.getPlayer() == null) continue;
            hook.onNpcKill(this, killer.getPlayer());
        }
        super.onDeath(killer);
        this.broadcastPacket(new NpcInfoState(this));
    }

    public final long getDeathTime() {
        return this._deathTime;
    }

    public AggroList getAggroList() {
        return this._aggroList;
    }

    public void setLeader(NpcInstance leader) {
        this._masterRef = leader == null ? null : leader.getRef();
    }

    public NpcInstance getLeader() {
        return this._masterRef == null ? null : (NpcInstance)this._masterRef.get();
    }

    @Override
    public boolean isMinion() {
        return this._masterRef != null;
    }

    public MinionList getMinionList() {
        if (this._minionList == null) {
            this._minionList = new MinionList(this);
        }
        return this._minionList;
    }

    public boolean hasMinions() {
        return this._minionList != null && this._minionList.hasMinions();
    }

    public void notifyMinionDied(NpcInstance minion) {
    }

    public Location getRndMinionPosition() {
        int offset = 200;
        int minRadius = (int)this.getCurrentCollisionRadius() + 30;
        for (int i = 0; i < 100; ++i) {
            int x = Rnd.get((int)(minRadius * 2), (int)400);
            int y = Rnd.get((int)x, (int)400);
            y = (int)Math.sqrt(y * y - x * x);
            x = x > 200 + minRadius ? this.getX() + x - 200 : this.getX() - x + minRadius;
            y = y > 200 + minRadius ? this.getY() + y - 200 : this.getY() - y + minRadius;
            int tempz = GeoEngine.getLowerHeight(x, y, this.getZ(), this.getGeoIndex());
            if (Math.abs(this.getZ() - tempz) >= 200 || GeoEngine.getLowerNSWE(x, y, tempz, this.getGeoIndex()) != 15) continue;
            return new Location(x, y, tempz);
        }
        return Location.findPointToStay(this.getX(), this.getY(), this.getZ(), 200, 200, this.getGeoIndex());
    }

    public void onSpawnMinion(NpcInstance minion) {
    }

    @Override
    public boolean setReflection(Reflection reflection) {
        if (!super.setReflection(reflection)) {
            return false;
        }
        if (this.hasMinions()) {
            for (NpcInstance m : this.getMinionList().getAliveMinions()) {
                m.setReflection(reflection);
            }
        }
        return true;
    }

    public void dropItem(Player lastAttacker, int itemId, long itemCount) {
        if (itemCount == 0L || lastAttacker == null) {
            return;
        }
        if (lastAttacker.isFakePlayer()) {
            return;
        }
        for (long i = 0L; i < itemCount; ++i) {
            ItemInstance item = ItemFunctions.createItem(itemId);
            for (Event e : this.getEvents()) {
                item.addEvent(e);
            }
            if (item.isStackable()) {
                i = itemCount;
                item.setCount(itemCount);
            }
            if (this.isRaid()) {
                SystemMessagePacket sm;
                if (itemId == 57) {
                    sm = new SystemMessagePacket(SystemMsg.C1_HAS_DIED_AND_DROPPED_S2_ADENA);
                    sm.addName(this);
                    sm.addLong(item.getCount());
                } else {
                    sm = new SystemMessagePacket(SystemMsg.C1_DIED_AND_DROPPED_S3_S2);
                    sm.addName(this);
                    sm.addItemName(itemId);
                    sm.addLong(item.getCount());
                }
                this.broadcastPacket(sm);
            }
            lastAttacker.doAutoLootOrDrop(item, this);
        }
    }

    public void dropItem(Player lastAttacker, ItemInstance item) {
        if (item.getCount() == 0L) {
            return;
        }
        if (lastAttacker != null && lastAttacker.isFakePlayer()) {
            item.deleteMe();
            return;
        }
        if (this.isRaid()) {
            SystemMessagePacket sm;
            if (item.getItemId() == 57) {
                sm = new SystemMessagePacket(SystemMsg.C1_HAS_DIED_AND_DROPPED_S2_ADENA);
                sm.addName(this);
                sm.addLong(item.getCount());
            } else {
                sm = new SystemMessagePacket(SystemMsg.C1_DIED_AND_DROPPED_S3_S2);
                sm.addName(this);
                sm.addItemName(item.getItemId());
                sm.addLong(item.getCount());
            }
            this.broadcastPacket(sm);
        }
        lastAttacker.doAutoLootOrDrop(item, this);
    }

    @Override
    public boolean isAttackable(Creature attacker) {
        return true;
    }

    @Override
    public boolean isAutoAttackable(Creature attacker) {
        return false;
    }

    public boolean canAttackCharacter(Creature target) {
        return target.isAutoAttackable(this);
    }

    @Override
    protected void onSpawn() {
        int eventTriggerId;
        List<MinionData> minionsData;
        super.onSpawn();
        this.setCurrentHpMp(this.getMaxHp(), this.getMaxMp(), true);
        this._deathTime = 0L;
        this._spawnAnimation = 0;
        this._spawnTime = System.currentTimeMillis();
        this.getAI().notifyEvent(CtrlEvent.EVT_SPAWN);
        this.getListeners().onSpawn();
        for (ListenerHook hook : this.getTemplate().getListenerHooks(ListenerHookType.NPC_SPAWN)) {
            hook.onNpcSpawn(this);
        }
        if (this.getAI().isGlobalAI() || this.getCurrentRegion() != null && this.getCurrentRegion().isActive()) {
            this.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            this.getAI().startAITask();
            this.startRandomAnimation();
        }
        if (!this.hasMinions() && !(minionsData = this.getTemplate().getMinionData()).isEmpty()) {
            for (MinionData minionData : minionsData) {
                this.getMinionList().addMinion(minionData);
            }
        }
        if (this.hasMinions() && !this.isArenaRaid()) {
            ThreadPoolManager.getInstance().schedule(() -> this.getMinionList().spawnMinions(), 1500L);
        }
        if (this.getLeader() != null) {
            this.getLeader().onSpawnMinion(this);
        }
        if (this._supportSpawnGroup != null) {
            this.getReflection().spawnByGroup(this._supportSpawnGroup);
        }
        if ((eventTriggerId = this.getParameter(EVENT_TRIGGER_ID, 0)) != 0) {
            this._eventTriggers.add(eventTriggerId);
        }
        for (int triggerId : this._eventTriggers.toArray()) {
            if (this.getReflection().isMain()) {
                EventTriggersManager.getInstance().addTrigger(MapUtils.regionX(this.getX()), MapUtils.regionY(this.getY()), triggerId);
                continue;
            }
            EventTriggersManager.getInstance().addTrigger(this.getReflection(), triggerId);
        }
    }

    @Override
    protected void onDespawn() {
        this.getAggroList().clear();
        this.stopRandomAnimation();
        this.getAI().stopAITask();
        this.getAI().setIntention(CtrlIntention.AI_INTENTION_IDLE);
        this.getAI().notifyEvent(CtrlEvent.EVT_DESPAWN);
        super.onDespawn();
        if (this._supportSpawnGroup != null) {
            this.getReflection().despawnByGroup(this._supportSpawnGroup);
        }
        for (ListenerHook hook : this.getTemplate().getListenerHooks(ListenerHookType.NPC_DESPAWN)) {
            hook.onNpcDespawn(this);
        }
        for (int triggerId : this._eventTriggers.toArray()) {
            if (this.getReflection().isMain()) {
                EventTriggersManager.getInstance().removeTrigger(MapUtils.regionX(this.getX()), MapUtils.regionY(this.getY()), triggerId);
                continue;
            }
            EventTriggersManager.getInstance().removeTrigger(this.getReflection(), triggerId);
        }
        this._eventTriggers.clear();
    }

    @Override
    public NpcTemplate getTemplate() {
        return (NpcTemplate)super.getTemplate();
    }

    @Override
    public int getNpcId() {
        return this.getTemplate().getId();
    }

    public void setUnAggred(boolean state) {
        this._unAggred = state;
    }

    public boolean isAggressive() {
        return this.getAggroRange() > 0;
    }

    public int getAggroRange() {
        if (this._unAggred) {
            return 0;
        }
        if (this._personalAggroRange >= 0) {
            return this._personalAggroRange;
        }
        return this.getTemplate().aggroRange;
    }

    public void setAggroRange(int aggroRange) {
        this._personalAggroRange = aggroRange;
    }

    public Faction getFaction() {
        return this.getTemplate().getFaction();
    }

    public boolean isInFaction(NpcInstance npc) {
        return this.getFaction().equals(npc.getFaction()) && !this.getFaction().isIgnoreNpcId(npc.getNpcId());
    }

    @Override
    public int getMAtk(Creature target, Skill skill) {
        return (int)((double)super.getMAtk(target, skill) * Config.ALT_NPC_MATK_MODIFIER);
    }

    @Override
    public int getPAtk(Creature target) {
        return (int)((double)super.getPAtk(target) * Config.ALT_NPC_PATK_MODIFIER);
    }

    @Override
    public int getMaxHp() {
        return (int)((double)super.getMaxHp() * Config.ALT_NPC_MAXHP_MODIFIER);
    }

    @Override
    public int getMaxMp() {
        return (int)((double)super.getMaxMp() * Config.ALT_NPC_MAXMP_MODIFIER);
    }

    public long getExpReward() {
        return (long)this.getStat().calc(Stats.EXP_RATE_MULTIPLIER, this.getTemplate().rewardExp, null, null);
    }

    public long getSpReward() {
        return (long)this.getStat().calc(Stats.SP_RATE_MULTIPLIER, this.getTemplate().rewardSp, null, null);
    }

    @Override
    protected void onDelete() {
        NpcInstance leader;
        this.getAI().stopAllTaskAndTimers();
        this.stopDecay();
        if (this._spawn != null) {
            this._spawn.stopRespawn();
        }
        this.setSpawn(null);
        if (this.hasMinions()) {
            this.getMinionList().onMasterDelete();
        }
        if ((leader = this.getLeader()) != null && leader.hasMinions()) {
            leader.getMinionList().onMinionDelete(this);
        }
        super.onDelete();
    }

    public Spawner getSpawn() {
        return this._spawn;
    }

    public void setSpawn(Spawner spawn) {
        this._spawn = spawn;
    }

    public final void decayOrDelete() {
        this.onDecay();
    }

    @Override
    protected void onDecay() {
        super.onDecay();
        this.getListeners().onDecay();
        this.getAbnormalList().stopAll();
        this._spawnAnimation = 2;
        if (!this.hasMinions() || !this.getMinionList().hasAliveMinions()) {
            if (this._spawn != null) {
                this._spawn.decreaseCount(this);
            } else {
                this.deleteMe();
            }
        }
    }

    protected void startDecay(long delay) {
        this.stopDecay();
        this._decayTask = DecayTaskManager.getInstance().addDecayTask(this, delay);
    }

    public void stopDecay() {
        if (this._decayTask != null) {
            this._decayTask.cancel(false);
            this._decayTask = null;
        }
    }

    public void endDecayTask() {
        if (this._decayTask != null) {
            this._decayTask.cancel(false);
            this._decayTask = null;
        }
        this.doDecay();
    }

    @Override
    public boolean isUndead() {
        return this.getTemplate().isUndead();
    }

    public void setLevel(int level) {
        this._level = level;
    }

    @Override
    public int getLevel() {
        return this._level == 0 ? this.getTemplate().level : this._level;
    }

    public void setDisplayId(int displayId) {
        this._displayId = displayId;
    }

    public int getDisplayId() {
        return this._displayId > 0 ? this._displayId : this.getTemplate().displayId;
    }

    @Override
    public ItemInstance getActiveWeaponInstance() {
        return null;
    }

    @Override
    public WeaponTemplate getActiveWeaponTemplate() {
        int weaponId = this.getTemplate().rhand;
        if (weaponId < 1) {
            return null;
        }
        ItemTemplate item = ItemHolder.getInstance().getTemplate(this.getTemplate().rhand);
        if (!(item instanceof WeaponTemplate)) {
            return null;
        }
        return (WeaponTemplate)item;
    }

    @Override
    public ItemInstance getSecondaryWeaponInstance() {
        return null;
    }

    @Override
    public WeaponTemplate getSecondaryWeaponTemplate() {
        int weaponId = this.getTemplate().lhand;
        if (weaponId < 1) {
            return null;
        }
        ItemTemplate item = ItemHolder.getInstance().getTemplate(this.getTemplate().lhand);
        if (!(item instanceof WeaponTemplate)) {
            return null;
        }
        return (WeaponTemplate)item;
    }

    @Override
    public void sendChanges() {
        if (this.isFlying()) {
            return;
        }
        super.sendChanges();
    }

    public void onMenuSelect(Player player, int ask, long reply, int state) {
        for (QuestState qs : player.getAllQuestsStates()) {
            if (qs.getQuest().getId() != ask || qs.isCompleted()) continue;
            if (!qs.getQuest().notifyMenuSelect((int)reply, qs, this)) break;
            return;
        }
        if (ask == -303) {
            Castle castle = this.getCastle(player);
            MultiSellHolder.getInstance().SeparateAndSend((int)reply, player, castle != null ? castle.getSellTaxRate() : 0.0);
        } else if (ask == -1000) {
            if (reply == 1L) {
                this.onBypassFeedback(player, "TerritoryStatus");
            }
        } else if (ask == -1816) {
            this.onBypassFeedback(player, "teleport_fi_to");
        } else if (ask == 255) {
            this.onBypassFeedback(player, "teleport_mdt_to");
        }
        this.getAI().notifyEvent(CtrlEvent.EVT_MENU_SELECTED, player, ask, reply);
        for (ListenerHook hook : this.getTemplate().getListenerHooks(ListenerHookType.NPC_ASK)) {
            hook.onNpcAsk(this, ask, reply, state, player);
        }
        for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.NPC_ASK)) {
            hook.onNpcAsk(this, ask, reply, state, player);
        }
    }

    @Override
    public void broadcastCharInfo() {
        if (!this.isVisible()) {
            return;
        }
        if (this._broadcastCharInfoTask != null) {
            return;
        }
        this._broadcastCharInfoTask = ThreadPoolManager.getInstance().schedule(new BroadcastCharInfoTask(), Config.BROADCAST_CHAR_INFO_INTERVAL);
    }

    @Override
    public void broadcastCharInfoImpl(IUpdateTypeComponent ... components) {
        if (components.length == 0) {
            _log.warn(this.getClass().getSimpleName() + ": Trying broadcast char info without components!", (Throwable)new Exception());
            return;
        }
        for (Player player : World.getAroundObservers(this)) {
            if (this.isInvisible(player)) continue;
            player.sendPacket((IBroadcastPacket)new NpcInfoPacket(this, (Creature)player).update(components));
        }
    }

    public void onRandomAnimation() {
        if (System.currentTimeMillis() - this._lastSocialAction > 10000L) {
            this.broadcastPacket(new SocialActionPacket(this.getObjectId(), 2));
            this._lastSocialAction = System.currentTimeMillis();
        }
    }

    public void startRandomAnimation() {
        if (!this.hasRandomAnimation()) {
            return;
        }
        this._animationTask = LazyPrecisionTaskManager.getInstance().addNpcAnimationTask(this);
    }

    public void stopRandomAnimation() {
        if (this._animationTask != null) {
            this._animationTask.cancel(false);
            this._animationTask = null;
        }
    }

    public boolean hasRandomAnimation() {
        return this._hasRandomAnimation;
    }

    public void setHaveRandomAnim(boolean value) {
        this._hasRandomAnimation = value;
    }

    public boolean hasRandomWalk() {
        return this._hasRandomWalk;
    }

    public void setRandomWalk(boolean value) {
        this._hasRandomWalk = value;
    }

    public Castle getCastle() {
        if (this.getReflection() == ReflectionManager.PARNASSUS && Config.SERVICES_PARNASSUS_NOTAX) {
            return null;
        }
        if (Config.SERVICES_OFFSHORE_NO_CASTLE_TAX && this.getReflection() == ReflectionManager.GIRAN_HARBOR) {
            return null;
        }
        if (Config.SERVICES_OFFSHORE_NO_CASTLE_TAX && this.getReflection() == ReflectionManager.PARNASSUS) {
            return null;
        }
        if (Config.SERVICES_OFFSHORE_NO_CASTLE_TAX && this.isInZone(Zone.ZoneType.offshore)) {
            return null;
        }
        if (this._nearestCastle == null) {
            this._nearestCastle = (Castle)ResidenceHolder.getInstance().getResidence(this.getTemplate().getCastleId());
        }
        return this._nearestCastle;
    }

    public Castle getCastle(Player player) {
        return this.getCastle();
    }

    public ClanHall getClanHall() {
        if (this._nearestClanHall == null) {
            this._nearestClanHall = ResidenceHolder.getInstance().findNearestResidence(ClanHall.class, this.getX(), this.getY(), this.getZ(), this.getReflection(), 32768);
        }
        return this._nearestClanHall;
    }

    @Override
    public void onAction(Player player, boolean shift) {
        if (!this.isTargetable(player)) {
            player.sendActionFailed();
            return;
        }
        if (player.getTarget() != this) {
            player.setTarget(this);
            return;
        }
        if (shift && OnShiftActionHolder.getInstance().callShiftAction(player, NpcInstance.class, this, true)) {
            return;
        }
        if (this.isAutoAttackable(player)) {
            player.getAI().Attack(this, false, shift);
            return;
        }
        if (!player.checkInteractionDistance(this)) {
            if (player.getAI().getIntention() != CtrlIntention.AI_INTENTION_INTERACT) {
                player.getAI().setIntention(CtrlIntention.AI_INTENTION_INTERACT, this, null);
            }
            return;
        }
        if (!Config.ALT_GAME_KARMA_PLAYER_CAN_SHOP && player.isPK() && !player.isGM()) {
            player.sendActionFailed();
            return;
        }
        if (!Config.ALLOW_TALK_WHILE_SITTING && player.isSitting() || player.isActionsDisabled()) {
            player.sendActionFailed();
            return;
        }
        player.sendActionFailed();
        if (player.getMovement().isMoving()) {
            player.getMovement().stopMove();
        }
        player.sendPacket((IBroadcastPacket)new MoveToPawnPacket(player, this, player.getInteractionDistance(this)));
        if (this._isBusy) {
            this.showBusyWindow(player);
        } else if (this.isHasChatWindow()) {
            boolean flag = false;
            Set<Quest> quests = this.getTemplate().getEventQuests(QuestEventType.NPC_FIRST_TALK);
            if (quests != null) {
                for (Quest quest : quests) {
                    QuestState qs = player.getQuestState(quest);
                    if (qs != null && qs.isCompleted() || !quest.notifyFirstTalk(this, player)) continue;
                    flag = true;
                }
            }
            if (!flag) {
                for (ListenerHook hook : this.getTemplate().getListenerHooks(ListenerHookType.NPC_FIRST_TALK)) {
                    if (!hook.onNpcFirstTalk(this, player)) continue;
                    flag = true;
                }
                for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.NPC_FIRST_TALK)) {
                    if (!hook.onNpcFirstTalk(this, player)) continue;
                    flag = true;
                }
            }
            if (!flag && !this.isDead()) {
                this.showChatWindow(player, 0, true, new Object[0]);
                if (Config.NPC_DIALOG_PLAYER_DELAY > 0) {
                    player.setNpcDialogEndTime((int)(System.currentTimeMillis() / 1000L) + Config.NPC_DIALOG_PLAYER_DELAY);
                }
            }
        }
    }

    public void showQuestWindow(Player player, int questId) {
        if (!player.isQuestContinuationPossible(true)) {
            return;
        }
        int count = 0;
        for (QuestState qs : player.getAllQuestsStates()) {
            if (qs == null || !qs.getQuest().isVisible(player) || !qs.isStarted() || qs.getCond() <= 0) continue;
            ++count;
        }
        if (count > 40) {
            this.showChatWindow(player, "quest-limit.htm", false, new Object[0]);
            return;
        }
        try {
            QuestState qs = player.getQuestState(questId);
            if (qs != null) {
                if (qs.isCompleted() && qs.getQuest().notifyCompleted(this, qs)) {
                    return;
                }
                if (qs.getQuest().notifyTalk(this, qs)) {
                    return;
                }
            } else {
                Set<Quest> quests;
                Quest quest = QuestHolder.getInstance().getQuest(questId);
                if (quest != null && (quests = this.getTemplate().getEventQuests(QuestEventType.QUEST_START)) != null && quests.contains(quest) && (qs = quest.newQuestState(player)).getQuest().notifyTalk(this, qs)) {
                    return;
                }
            }
            this.showChatWindow(player, "no-quest.htm", false, new Object[0]);
        }
        catch (Exception e) {
            _log.warn("problem with npc text(QUEST ID[" + questId + "]" + e);
            _log.error("", (Throwable)e);
        }
        player.sendActionFailed();
    }

    public boolean canBypassCheck(Player player) {
        if (player.isDead() || !player.checkInteractionDistance(this)) {
            player.sendActionFailed();
            return false;
        }
        return true;
    }

    public void onBypassFeedback(Player player, String command) {
        block90: {
            try {
                StringTokenizer st = new StringTokenizer(command, "_");
                String cmd = st.nextToken();
                if (command.equalsIgnoreCase("TerritoryStatus")) {
                    HtmlMessage html = new HtmlMessage(this);
                    Castle castle = this.getCastle(player);
                    if (castle != null && castle.getId() > 0) {
                        if (castle.getOwnerId() > 0) {
                            Clan clan = ClanTable.getInstance().getClan(castle.getOwnerId());
                            if (clan != null) {
                                html.setFile("merchant/territorystatus.htm");
                                html.replace("%castlename%", HtmlUtils.htmlResidenceName(castle.getId()));
                                html.replace("%taxpercent%", String.valueOf(castle.getSellTaxPercent()));
                                html.replace("%clanname%", clan.getName());
                                html.replace("%clanleadername%", clan.getLeaderName());
                            } else {
                                html.setFile("merchant/territorystatus_noowner.htm");
                                html.replace("%castlename%", HtmlUtils.htmlResidenceName(castle.getId()));
                            }
                        } else {
                            html.setFile("merchant/territorystatus_noowner.htm");
                            html.replace("%castlename%", HtmlUtils.htmlResidenceName(castle.getId()));
                        }
                    } else {
                        return;
                    }
                    player.sendPacket((IBroadcastPacket)html);
                    break block90;
                }
                if (command.startsWith("QuestEvent")) {
                    StringTokenizer tokenizer = new StringTokenizer(command);
                    tokenizer.nextToken();
                    String questName = tokenizer.nextToken();
                    int questId = Integer.parseInt(questName);
                    if (command.length() > 12 + questName.length()) {
                        player.processQuestEvent(questId, command.substring(12 + questName.length()), this);
                    } else {
                        player.processQuestEvent(questId, "", this);
                    }
                    break block90;
                }
                if (command.startsWith("Quest")) {
                    String quest = command.substring(5).trim();
                    if (quest.length() == 0) {
                        this.showQuestWindow(player);
                    } else {
                        try {
                            int questId = Integer.parseInt(quest);
                            this.showQuestWindow(player, questId);
                        }
                        catch (NumberFormatException nfe) {
                            _log.error("", (Throwable)nfe);
                        }
                    }
                    break block90;
                }
                if (command.startsWith("Chat") || command.startsWith("chat")) {
                    try {
                        int val = Integer.parseInt(command.substring(5));
                        this.showChatWindow(player, val, false, new Object[0]);
                    }
                    catch (NumberFormatException nfe) {
                        String filename = command.substring(5).trim();
                        if (filename.length() == 0) {
                            this.showChatWindow(player, "npcdefault.htm", false, new Object[0]);
                            break block90;
                        }
                        this.showChatWindow(player, filename, false, new Object[0]);
                    }
                    break block90;
                }
                if (command.startsWith("AttributeCancel")) {
                    player.sendPacket((IBroadcastPacket)new ExShowBaseAttributeCancelWindow(player));
                    break block90;
                }
                if (command.startsWith("NpcLocationInfo")) {
                    int val = Integer.parseInt(command.substring(16));
                    List<NpcInstance> npcs = GameObjectsStorage.getNpcs(true, val);
                    if (!npcs.isEmpty()) {
                        player.sendPacket((IBroadcastPacket)new RadarControlPacket(2, 2, npcs.get(0).getLoc()));
                        player.sendPacket((IBroadcastPacket)new RadarControlPacket(0, 1, npcs.get(0).getLoc()));
                    }
                    break block90;
                }
                if (command.startsWith("Multisell") || command.startsWith("multisell")) {
                    String listId = command.substring(9).trim();
                    Castle castle = this.getCastle(player);
                    MultiSellHolder.getInstance().SeparateAndSend(Integer.parseInt(listId), player, castle != null ? castle.getSellTaxRate() : 0.0);
                    break block90;
                }
                if (command.equalsIgnoreCase("ClanSkillList")) {
                    NpcInstance.showClanSkillList(player);
                    break block90;
                }
                if (command.startsWith("SubUnitSkillList")) {
                    NpcInstance.showSubUnitSkillList(player);
                    break block90;
                }
                if (command.startsWith("Link")) {
                    this.showChatWindow(player, command.substring(5), false, new Object[0]);
                    break block90;
                }
                if (cmd.equalsIgnoreCase("teleport")) {
                    if (!st.hasMoreTokens()) {
                        this.errorBypass(command, player);
                        return;
                    }
                    String cmd2 = st.nextToken();
                    if (cmd2.equalsIgnoreCase("list")) {
                        int listId = 1;
                        if (st.hasMoreTokens()) {
                            listId = Integer.parseInt(st.nextToken());
                        }
                        this.showTeleportList(player, listId);
                    } else if (cmd2.equalsIgnoreCase("id")) {
                        int listId = Integer.parseInt(st.nextToken());
                        int teleportNameId = Integer.parseInt(st.nextToken());
                        List<TeleportLocation> list = this.getTemplate().getTeleportList(listId);
                        if (list == null || list.isEmpty()) {
                            this.errorBypass(command, player);
                            return;
                        }
                        TeleportLocation teleportLocation = null;
                        for (TeleportLocation tl : list) {
                            if (tl.getName() != teleportNameId) continue;
                            teleportLocation = tl;
                            break;
                        }
                        if (teleportLocation == null) {
                            this.errorBypass(command, player);
                            return;
                        }
                        long itemCount = this.calcTeleportPrice(player, teleportLocation);
                        if (st.hasMoreTokens()) {
                            itemCount = Long.parseLong(st.nextToken());
                        }
                        this.teleportPlayer(player, teleportLocation, itemCount);
                    } else if (cmd2.equalsIgnoreCase("mdt")) {
                        if (!st.hasMoreTokens()) {
                            this.errorBypass(command, player);
                            return;
                        }
                        String cmd3 = st.nextToken();
                        if (cmd3.equalsIgnoreCase("to")) {
                            player.setVar("@mdt_back_cords", player.getLoc().toXYZString(), -1L);
                            player.teleToLocation(12661, 181687, -3540);
                        } else if (cmd3.equalsIgnoreCase("from")) {
                            String var = player.getVar("@mdt_back_cords");
                            if (var == null || var.isEmpty()) {
                                player.teleToLocation(12902, 181011, -3563);
                                return;
                            }
                            player.teleToLocation(Location.parseLoc(var));
                        }
                    } else if (cmd2.equalsIgnoreCase("fi")) {
                        if (!st.hasMoreTokens()) {
                            this.errorBypass(command, player);
                            return;
                        }
                        String cmd3 = st.nextToken();
                        if (cmd3.equalsIgnoreCase("to")) {
                            player.setVar("@fi_back_cords", player.getLoc().toXYZString(), -1L);
                            switch (Rnd.get((int)4)) {
                                case 1: {
                                    player.teleToLocation(-60695, -56896, -2032);
                                    break;
                                }
                                case 2: {
                                    player.teleToLocation(-59716, -55920, -2032);
                                    break;
                                }
                                case 3: {
                                    player.teleToLocation(-58752, -56896, -2032);
                                    break;
                                }
                                default: {
                                    player.teleToLocation(-59716, -57864, -2032);
                                    break;
                                }
                            }
                        } else if (cmd3.equalsIgnoreCase("from")) {
                            String var = player.getVar("@fi_back_cords");
                            if (var == null || var.isEmpty()) {
                                player.teleToLocation(12902, 181011, -3563);
                                return;
                            }
                            player.teleToLocation(Location.parseLoc(var));
                        }
                    } else {
                        if (st.countTokens() < 2) {
                            this.errorBypass(command, player);
                            return;
                        }
                        int x = Integer.parseInt(cmd2);
                        int y = Integer.parseInt(st.nextToken());
                        int z = Integer.parseInt(st.nextToken());
                        int itemId = 0;
                        if (st.hasMoreTokens()) {
                            itemId = Integer.parseInt(st.nextToken());
                        }
                        int itemCount = 0;
                        if (st.hasMoreTokens()) {
                            itemCount = Integer.parseInt(st.nextToken());
                        }
                        int castleId = 0;
                        if (st.hasMoreTokens()) {
                            castleId = Integer.parseInt(st.nextToken());
                        }
                        int reflectionId = 0;
                        if (st.hasMoreTokens()) {
                            reflectionId = Integer.parseInt(st.nextToken());
                        }
                        this.teleportPlayer(player, x, y, z, itemId, itemCount, new int[]{castleId}, reflectionId);
                    }
                    break block90;
                }
                if (command.startsWith("open_gate")) {
                    int val = Integer.parseInt(command.substring(10));
                    ReflectionUtils.getDoor(val).openMe();
                    player.sendActionFailed();
                    break block90;
                }
                if (command.startsWith("ExitFromQuestInstance")) {
                    Reflection r = player.getReflection();
                    if (r.isDefault()) {
                        return;
                    }
                    r.startCollapseTimer(1, true);
                    player.teleToLocation((ILocation)r.getReturnLoc(), ReflectionManager.MAIN);
                    if (command.length() <= 22) break block90;
                    try {
                        int val = Integer.parseInt(command.substring(22));
                        this.showChatWindow(player, val, false, new Object[0]);
                    }
                    catch (NumberFormatException nfe) {
                        String filename = command.substring(22).trim();
                        if (filename.length() > 0) {
                            this.showChatWindow(player, filename, false, new Object[0]);
                        }
                        break block90;
                    }
                }
                if (cmd.equalsIgnoreCase("WithdrawP")) {
                    WarehouseFunctions.showRetrieveWindow(player);
                } else if (cmd.equalsIgnoreCase("DepositP")) {
                    WarehouseFunctions.showDepositWindow(player);
                } else if (cmd.equalsIgnoreCase("WithdrawC")) {
                    WarehouseFunctions.showWithdrawWindowClan(player);
                } else if (cmd.equalsIgnoreCase("DepositC")) {
                    WarehouseFunctions.showDepositWindowClan(player);
                } else if (cmd.equalsIgnoreCase("deposit_items")) {
                    player.sendPacket((IBroadcastPacket)new PackageToListPacket(player));
                } else if (cmd.equalsIgnoreCase("withdraw_items")) {
                    WarehouseFunctions.showFreightWindow(player);
                } else if (cmd.equalsIgnoreCase("ensoul")) {
                    if (!st.hasMoreTokens()) {
                        this.errorBypass(command, player);
                        return;
                    }
                    String cmd2 = st.nextToken();
                    if (cmd2.equalsIgnoreCase("add")) {
                        player.sendPacket((IBroadcastPacket)ExShowEnsoulWindow.STATIC);
                    } else if (cmd2.equalsIgnoreCase("remove")) {
                        player.sendPacket((IBroadcastPacket)ExEnSoulExtractionShow.STATIC);
                    }
                } else {
                    String word = command.split("\\s+")[0];
                    String args = command.substring(word.length()).trim();
                    Pair<Object, Method> b = BypassHolder.getInstance().getBypass(word);
                    if (b != null) {
                        ((Method)b.getValue()).invoke(b.getKey(), player, this, StringUtils.isEmpty((CharSequence)args) ? new String[]{} : args.split("\\s+"));
                    } else {
                        _log.warn("Unknown command=[" + command + "] npcId:" + this.getTemplate().getId());
                    }
                }
            }
            catch (NumberFormatException nfe) {
                _log.warn("Invalid bypass to Server command parameter! npcId=" + this.getTemplate().getId() + " command=[" + command + "]", (Throwable)nfe);
            }
            catch (Exception sioobe) {
                _log.warn("Incorrect htm bypass! npcId=" + this.getTemplate().getId() + " command=[" + command + "]", (Throwable)sioobe);
            }
        }
    }

    public void errorBypass(String bypass, Player player) {
        player.sendMessage(new CustomMessage("l2s.gameserver.model.instance.NpcInstance.ErrorBypass").addNumber(this.getNpcId()).addString(bypass));
    }

    public boolean teleportPlayer(Player player, int x, int y, int z, int itemId, long itemCount, int[] castleIds, int reflectionId) {
        if (player == null) {
            return false;
        }
        if (player.getMountType() == MountType.WYVERN) {
            return false;
        }
        switch (this.getNpcId()) {
            case 30483: {
                if (player.getLevel() < Config.CRUMA_GATEKEEPER_LVL) break;
                this.showChatWindow(player, "teleporter/" + this.getNpcId() + "-no.htm", false, new Object[0]);
                return false;
            }
            case 32864: 
            case 32865: 
            case 32866: 
            case 32867: 
            case 32868: 
            case 32869: 
            case 32870: {
                if (player.getLevel() >= 80) break;
                this.showChatWindow(player, "teleporter/" + this.getNpcId() + "-no.htm", false, new Object[0]);
                return false;
            }
        }
        if (itemId > 0 && itemCount > 0L && ItemFunctions.getItemCount(player, itemId) < itemCount) {
            if (itemId == 57) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_ADENA);
            } else {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_DO_NOT_HAVE_ENOUGH_REQUIRED_ITEMS);
            }
            return false;
        }
        if (castleIds.length > 0 && player.getReflection().isMain() && !Config.ALT_TELEPORT_TO_TOWN_DURING_SIEGE) {
            for (int castleId : castleIds) {
                Castle castle = ResidenceHolder.getInstance().getResidence(Castle.class, castleId);
                if (castle == null || castle.getSiegeEvent() == null || !((SiegeEvent)((Object)castle.getSiegeEvent())).isInProgress()) continue;
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TELEPORT_TO_A_VILLAGE_THAT_IS_IN_A_SIEGE);
                return false;
            }
        }
        if (itemId > 0 && itemCount > 0L && !ItemFunctions.deleteItem((Playable)player, itemId, itemCount, true)) {
            return false;
        }
        Location pos = Location.findPointToStay(x, y, z, 50, 100, player.getGeoIndex());
        if (reflectionId > -1) {
            Reflection reflection = ReflectionManager.getInstance().get(reflectionId);
            if (reflection == null) {
                _log.warn("Cannot teleport to reflection ID: " + reflectionId + "!");
                return false;
            }
            player.teleToLocation((ILocation)pos, reflection);
        } else {
            player.teleToLocation(pos);
        }
        return true;
    }

    public boolean teleportPlayer(Player player, Location loc, int itemId, long itemCount, int[] castleIds, int reflectionId) {
        return this.teleportPlayer(player, loc.getX(), loc.getY(), loc.getZ(), itemId, itemCount, castleIds, reflectionId);
    }

    public boolean teleportPlayer(Player player, int x, int y, int z, int itemId, long itemCount) {
        return this.teleportPlayer(player, x, y, z, itemId, itemCount, new int[0], -1);
    }

    public boolean teleportPlayer(Player player, Location loc, int itemId, long itemCount) {
        return this.teleportPlayer(player, loc.getX(), loc.getY(), loc.getZ(), itemId, itemCount, new int[0], -1);
    }

    private boolean teleportPlayer(Player player, TeleportLocation loc, long itemCount) {
        return this.teleportPlayer(player, loc, loc.getItemId(), itemCount, loc.getCastleIds(), -1);
    }

    private long calcTeleportPrice(Player player, TeleportLocation loc) {
        if (loc.getItemId() != 57) {
            return loc.getPrice();
        }
        double pricemod = loc.isPrimeHours() && player.getLevel() <= Config.GATEKEEPER_FREE ? 0.0 : Config.GATEKEEPER_MODIFIER;
        return (long)((double)loc.getPrice() * pricemod);
    }

    public void showTeleportList(Player player) {
        this.showTeleportList(player, 1);
    }

    public void showTeleportList(Player player, int listId) {
        StringBuilder sb = new StringBuilder();
        sb.append("&$556;").append("<br><br>");
        List<TeleportLocation> list = this.getTemplate().getTeleportList(listId);
        if (list != null && !list.isEmpty() && player.getPlayerAccess().UseTeleport) {
            long price;
            for (TeleportLocation tl : list) {
                if (tl.getQuestZoneId() <= 0 || tl.getQuestZoneId() != player.getQuestZoneId()) continue;
                if (tl.getItemId() == 57) {
                    price = this.calcTeleportPrice(player, tl);
                    sb.append("<Button ALIGN=LEFT ICON=\"QUEST\" action=\"bypass -h npc_%objectId%_teleport_id_").append(listId).append("_").append(tl.getName()).append("_").append(price).append("\" msg=\"811;F;").append(tl.getName()).append("\">").append(HtmlUtils.htmlNpcString(tl.getName(), new Object[0]));
                    if (price > 0L) {
                        sb.append(" - ").append(price).append(" ").append(HtmlUtils.htmlItemName(57));
                    }
                    sb.append("</button>");
                    continue;
                }
                sb.append("<Button ALIGN=LEFT ICON=\"QUEST\" action=\"bypass -h npc_%objectId%_teleport_id_").append(listId).append("_").append(tl.getName()).append("\" msg=\"811;F;").append(tl.getName()).append("\">").append(HtmlUtils.htmlNpcString(tl.getName(), new Object[0]));
                if (tl.getItemId() > 0 && tl.getPrice() > 0L) {
                    sb.append(" - ").append(tl.getPrice()).append(" ").append(HtmlUtils.htmlItemName(tl.getItemId()));
                }
                sb.append("</button>");
            }
            for (TeleportLocation tl : list) {
                if (tl.getQuestZoneId() > 0 && tl.getQuestZoneId() == player.getQuestZoneId()) continue;
                if (tl.getItemId() == 57) {
                    price = this.calcTeleportPrice(player, tl);
                    sb.append("<Button ALIGN=LEFT ICON=\"TELEPORT\" action=\"bypass -h npc_%objectId%_teleport_id_").append(listId).append("_").append(tl.getName()).append("_").append(price).append("\" msg=\"811;F;").append(tl.getName()).append("\">").append(HtmlUtils.htmlNpcString(tl.getName(), new Object[0]));
                    if (price > 0L) {
                        sb.append(" - ").append(price).append(" ").append(HtmlUtils.htmlItemName(57));
                    }
                    sb.append("</button>");
                    continue;
                }
                sb.append("<Button ALIGN=LEFT ICON=\"TELEPORT\" action=\"bypass -h npc_%objectId%_teleport_id_").append(listId).append("_").append(tl.getName()).append("\" msg=\"811;F;").append(tl.getName()).append("\">").append(HtmlUtils.htmlNpcString(tl.getName(), new Object[0]));
                if (tl.getItemId() > 0 && tl.getPrice() > 0L) {
                    sb.append(" - ").append(tl.getPrice()).append(" ").append(HtmlUtils.htmlItemName(tl.getItemId()));
                }
                sb.append("</button>");
            }
        } else {
            sb.append("No teleports available for you.");
        }
        HtmlMessage html = new HtmlMessage(this);
        html.setHtml(HtmlUtils.bbParse(sb.toString()));
        player.sendPacket((IBroadcastPacket)html);
    }

    public void showQuestWindow(Player player) {
        List<QuestState> awaits;
        TIntObjectHashMap options = new TIntObjectHashMap();
        Set<Quest> quests = this.getTemplate().getEventQuests(QuestEventType.QUEST_START);
        if (quests != null) {
            for (Quest quest : quests) {
                if (!quest.isVisible(player) || !quest.checkStartNpc(this, player) || options.containsKey(quest.getId())) continue;
                options.put(quest.getId(), new QuestInfo(quest, player, true));
            }
        }
        if ((awaits = player.getQuestsForEvent(this, QuestEventType.QUEST_TALK)) != null) {
            for (QuestState qs : awaits) {
                Quest quest = qs.getQuest();
                if (!quest.isVisible(player) || !quest.checkTalkNpc(this, qs) || options.containsKey(quest.getId())) continue;
                options.put(quest.getId(), new QuestInfo(quest, player, false));
            }
        }
        if (options.size() > 1) {
            ArrayList<QuestInfo> arrayList = new ArrayList<QuestInfo>();
            arrayList.addAll(options.valueCollection());
            Collections.sort(arrayList);
            this.showQuestChooseWindow(player, arrayList);
        } else if (options.size() == 1) {
            this.showQuestWindow(player, ((QuestInfo[])options.values(new QuestInfo[1]))[0].getQuest().getId());
        } else {
            this.showChatWindow(player, "no-quest.htm", false, new Object[0]);
        }
    }

    public void showQuestChooseWindow(Player player, List<QuestInfo> quests) {
        StringBuilder sb = new StringBuilder();
        sb.append("<html><body>");
        for (QuestInfo info : quests) {
            Quest q = info.getQuest();
            if (!q.isVisible(player)) continue;
            sb.append("<button icon=quest align=left action=\"bypass -h npc_").append(this.getObjectId()).append("_Quest ").append(q.getId()).append("\">").append(q.getDescr(this, player, info.isStart())).append("</button>");
        }
        sb.append("</body></html>");
        HtmlMessage html = new HtmlMessage(this);
        html.setHtml(sb.toString());
        player.sendPacket((IBroadcastPacket)html);
    }

    public void showMainChatWindow(Player player, boolean firstTalk, Object ... replace) {
        this.showChatWindow(player, this.getHtmlPath(this.getHtmlFilename(0, player), player), firstTalk, replace);
    }

    public void showChatWindow(Player player, int val, boolean firstTalk, Object ... replace) {
        if (val == 0) {
            this.showMainChatWindow(player, firstTalk, replace);
            return;
        }
        this.showChatWindow(player, this.getHtmlPath(this.getHtmlFilename(val, player), player), firstTalk, replace);
    }

    public void showChatWindow(Player player, String filename, boolean firstTalk, Object ... replace) {
        HtmlMessage packet;
        if (filename.endsWith(".htm")) {
            packet = new HtmlMessage(this, filename);
        } else {
            packet = new HtmlMessage(this);
            packet.setHtml(filename);
        }
        packet.setPlayVoice(firstTalk);
        if (replace.length % 2 == 0) {
            for (int i = 0; i < replace.length; i += 2) {
                packet.replace(String.valueOf(replace[i]), String.valueOf(replace[i + 1]));
            }
        }
        player.sendPacket((IBroadcastPacket)packet);
    }

    public String getHtmlFilename(int val, Player player) {
        String filename = val == 0 ? this.getNpcId() + ".htm" : this.getNpcId() + "-" + val + ".htm";
        return filename;
    }

    public String getHtmlDir(String filename, Player player) {
        if (this.getTemplate().getHtmRoot() != null && HtmCache.getInstance().getIfExists(this.getTemplate().getHtmRoot() + filename, player) != null) {
            return this.getTemplate().getHtmRoot();
        }
        if (HtmCache.getInstance().getIfExists(filename, player) != null) {
            return "";
        }
        if (HtmCache.getInstance().getIfExists("default/" + filename, player) != null) {
            return "default/";
        }
        if (HtmCache.getInstance().getIfExists("blacksmith/" + filename, player) != null) {
            return "blacksmith/";
        }
        if (HtmCache.getInstance().getIfExists("merchant/" + filename, player) != null) {
            return "merchant/";
        }
        if (HtmCache.getInstance().getIfExists("teleporter/" + filename, player) != null) {
            return "teleporter/";
        }
        if (HtmCache.getInstance().getIfExists("petmanager/" + filename, player) != null) {
            return "petmanager/";
        }
        if (HtmCache.getInstance().getIfExists("mammons/" + filename, player) != null) {
            return "mammons/";
        }
        if (HtmCache.getInstance().getIfExists("warehouse/" + filename, player) != null) {
            return "warehouse/";
        }
        return null;
    }

    public final String getHtmlPath(String filename, Player player) {
        String dir = this.getHtmlDir(filename, player);
        if (dir == null) {
            return "npcdefault.htm";
        }
        String path = dir + filename;
        if (HtmCache.getInstance().getIfExists(path, player) != null) {
            return path;
        }
        return "npcdefault.htm";
    }

    public final boolean isBusy() {
        return this._isBusy;
    }

    public void setBusy(boolean isBusy) {
        this._isBusy = isBusy;
    }

    public final String getBusyMessage() {
        return this._busyMessage;
    }

    public void setBusyMessage(String message) {
        this._busyMessage = message;
    }

    public void showBusyWindow(Player player) {
        HtmlMessage html = new HtmlMessage(this);
        html.setFile("npcbusy.htm");
        html.replace("%busymessage%", this._busyMessage);
        player.sendPacket((IBroadcastPacket)html);
    }

    public static void showFishingSkillList(Player player) {
        NpcInstance.showAcquireList(AcquireType.FISHING, player);
    }

    public static void showClanSkillList(Player player) {
        if (player.getClan() == null || !player.isClanLeader()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.ONLY_THE_CLAN_LEADER_IS_ENABLED);
            player.sendActionFailed();
            return;
        }
        NpcInstance.showAcquireList(AcquireType.CLAN, player);
    }

    public static void showAcquireList(AcquireType t, Player player) {
        Collection<SkillLearn> skills = SkillAcquireHolder.getInstance().getAvailableSkills(player, t);
        ExAcquirableSkillListByClass asl = new ExAcquirableSkillListByClass(t, skills.size());
        for (SkillLearn s : skills) {
            asl.addSkill(s.getId(), s.getLevel(), s.getLevel(), s.getCost(), s.getMinLevel());
        }
        if (skills.size() == 0) {
            player.sendPacket((IBroadcastPacket)AcquireSkillDonePacket.STATIC);
            player.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NO_OTHER_SKILLS_TO_LEARN);
        } else {
            player.sendPacket((IBroadcastPacket)asl);
        }
        player.sendActionFailed();
    }

    public static void showSubUnitSkillList(Player player) {
        Clan clan = player.getClan();
        if (clan == null) {
            return;
        }
        if ((player.getClanPrivileges() & 0x200) != 512) {
            player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT);
            return;
        }
        TreeSet<SkillLearn> learns = new TreeSet<SkillLearn>();
        for (SubUnit sub : player.getClan().getAllSubUnits()) {
            learns.addAll(SkillAcquireHolder.getInstance().getAvailableSkills(player, AcquireType.SUB_UNIT, sub));
        }
        ExAcquirableSkillListByClass asl = new ExAcquirableSkillListByClass(AcquireType.SUB_UNIT, learns.size());
        for (SkillLearn s : learns) {
            asl.addSkill(s.getId(), s.getLevel(), s.getLevel(), s.getCost(), 1, 2002);
        }
        if (learns.size() == 0) {
            player.sendPacket((IBroadcastPacket)AcquireSkillDonePacket.STATIC);
            player.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NO_OTHER_SKILLS_TO_LEARN);
        } else {
            player.sendPacket((IBroadcastPacket)asl);
        }
        player.sendActionFailed();
    }

    public int getSpawnAnimation() {
        return this._spawnAnimation;
    }

    public int calculateLevelDiffForDrop(int charLevel) {
        if (!Config.DEEPBLUE_DROP_RULES) {
            return 0;
        }
        int mobLevel = this.getLevel();
        int deepblue_maxdiff = this instanceof RaidBossInstance ? Config.DEEPBLUE_DROP_RAID_MAXDIFF : Config.DEEPBLUE_DROP_MAXDIFF;
        return Math.max(charLevel - mobLevel - deepblue_maxdiff, 0);
    }

    @Override
    public String toString() {
        return this.getNpcId() + " " + this.getName();
    }

    public void refreshID() {
        GameObjectsStorage.remove(this);
        this.objectId = IdFactory.getInstance().getNextId();
        GameObjectsStorage.put(this);
    }

    public void setUnderground(boolean b) {
        this._isUnderground = b;
    }

    public boolean isUnderground() {
        return this._isUnderground;
    }

    public boolean isShowName() {
        return this._showName;
    }

    public void setShowName(boolean value) {
        this._showName = value;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public NpcListenerList getListeners() {
        if (this.listeners == null) {
            NpcInstance npcInstance = this;
            synchronized (npcInstance) {
                if (this.listeners == null) {
                    this.listeners = new NpcListenerList(this);
                }
            }
        }
        return (NpcListenerList)this.listeners;
    }

    public <T extends NpcListener> boolean addListener(T listener) {
        return this.getListeners().add(listener);
    }

    public <T extends NpcListener> boolean removeListener(T listener) {
        return this.getListeners().remove(listener);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public NpcStatsChangeRecorder getStatsRecorder() {
        if (this._statsRecorder == null) {
            NpcInstance npcInstance = this;
            synchronized (npcInstance) {
                if (this._statsRecorder == null) {
                    this._statsRecorder = new NpcStatsChangeRecorder(this);
                }
            }
        }
        return (NpcStatsChangeRecorder)this._statsRecorder;
    }

    public void setNpcState(int stateId) {
        this.broadcastPacket(new ExChangeNPCState(this.getObjectId(), stateId));
        this.npcState = stateId;
    }

    public int getNpcState() {
        return this.npcState;
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        if (this.isInvisible(forPlayer)) {
            return Collections.emptyList();
        }
        ArrayList<L2GameServerPacket> list = new ArrayList<L2GameServerPacket>(3);
        list.add(new NpcInfoPacket(this, (Creature)forPlayer).init());
        if (this.isInCombat()) {
            list.add(new AutoAttackStartPacket(this.getObjectId()));
        }
        if (this.getMovement().isMoving() || this.getMovement().isFollow()) {
            list.add(this.movePacket());
        }
        return list;
    }

    @Override
    public boolean isNpc() {
        return true;
    }

    @Override
    public int getGeoZ(int x, int y, int z) {
        int geoZ = super.getGeoZ(x, y, z);
        Location spawnedLoc = this.getSpawnedLoc();
        if (spawnedLoc.equals(x, y, z) && Math.abs(geoZ - z) > Config.MIN_LAYER_HEIGHT) {
            return z;
        }
        return geoZ;
    }

    @Override
    public Clan getClan() {
        Castle castle = this.getCastle();
        if (castle == null) {
            return null;
        }
        return castle.getOwner();
    }

    public NpcString getNameNpcString() {
        return this._nameNpcString;
    }

    public NpcString getTitleNpcString() {
        return this._titleNpcString;
    }

    public void setNameNpcString(NpcString nameNpcString) {
        this._nameNpcString = nameNpcString;
    }

    public void setTitleNpcString(NpcString titleNpcString) {
        this._titleNpcString = titleNpcString;
    }

    public SpawnRange getSpawnRange() {
        return this._spawnRange;
    }

    public void setSpawnRange(SpawnRange spawnRange) {
        this._spawnRange = spawnRange;
    }

    public boolean isSpawnLeaderDepends() {
        return this._spawnLeaderDepends;
    }

    public void setSpawnLeaderDepends(boolean value) {
        this._spawnLeaderDepends = value;
    }

    public void setParameter(String str, Object val) {
        if (this._parameters == StatsSet.EMPTY) {
            this._parameters = new StatsSet();
        }
        this._parameters.set(str, val);
    }

    public void setParameters(MultiValueSet<String> set) {
        if (set.isEmpty()) {
            return;
        }
        if (this._parameters == StatsSet.EMPTY) {
            this._parameters = new MultiValueSet(set.size());
        }
        this._parameters.putAll(set);
    }

    public int getParameter(String str, int val) {
        return this._parameters.getInteger(str, val);
    }

    public long getParameter(String str, long val) {
        return this._parameters.getLong(str, val);
    }

    public boolean getParameter(String str, boolean val) {
        return this._parameters.getBool(str, val);
    }

    public String getParameter(String str, String val) {
        return this._parameters.getString(str, val);
    }

    public MultiValueSet<String> getParameters() {
        return this._parameters;
    }

    @Override
    public boolean isPeaceNpc() {
        return true;
    }

    public boolean isHasChatWindow() {
        return this._hasChatWindow;
    }

    public void setHasChatWindow(boolean hasChatWindow) {
        this._hasChatWindow = hasChatWindow;
    }

    public boolean isServerObject() {
        return false;
    }

    @Override
    public double getCurrentCollisionRadius() {
        if (this.isVisualTransformed()) {
            return super.getCollisionRadius();
        }
        return super.getCollisionRadius() * this.getCollisionRadiusModifier();
    }

    @Override
    public double getCurrentCollisionHeight() {
        if (this.isVisualTransformed()) {
            return super.getCollisionHeight();
        }
        return super.getCollisionHeight() * this.getCollisionHeightModifier();
    }

    public final double getCollisionHeightModifier() {
        return this._collisionHeightModifier;
    }

    public final void setCollisionHeightModifier(double value) {
        this._collisionHeightModifier = value;
    }

    public final double getCollisionRadiusModifier() {
        return this._collisionRadiusModifier;
    }

    public final void setCollisionRadiusModifier(double value) {
        this._collisionRadiusModifier = value;
    }

    @Override
    public int getEnchantEffect() {
        return this._enchantEffect;
    }

    public final boolean isNoSleepMode() {
        return this._isNoSleepMode;
    }

    @Override
    public boolean isImmortal() {
        return this._isImmortal;
    }

    @Override
    public boolean isFearImmune() {
        return this.getLeader() != null ? this.getLeader().isFearImmune() : !this.isMonster() || super.isFearImmune();
    }

    public boolean canPassPacket(Player player, Class<? extends L2GameClientPacket> packet, Object ... arg) {
        return packet == RequestItemEnsoul.class || packet == RequestTryEnSoulExtraction.class;
    }

    public boolean noShiftClick() {
        return this._noShiftClick;
    }

    @Override
    public boolean isLethalImmune() {
        return this._noLethal || super.isLethalImmune();
    }

    public double getRewardRate(Player player) {
        return player.getRateItems();
    }

    public double getDropChanceMod(Player player) {
        return player.getDropChanceMod();
    }

    public double getDropCountMod(Player player) {
        return player.getDropCountMod();
    }

    @Override
    protected L2GameServerPacket changeMovePacket() {
        return new NpcInfoState(this);
    }

    public void setOwner(Player owner) {
        this._ownerName = owner == null ? "" : owner.getName();
        this._ownerRef = owner == null ? HardReferences.emptyRef() : owner.getRef();
    }

    @Override
    public Player getPlayer() {
        return (Player)this._ownerRef.get();
    }

    public boolean addEventTrigger(int triggerId) {
        if (this._eventTriggers.add(triggerId)) {
            if (this.getReflection().isMain()) {
                return EventTriggersManager.getInstance().addTrigger(MapUtils.regionX(this.getX()), MapUtils.regionY(this.getY()), triggerId);
            }
            return EventTriggersManager.getInstance().addTrigger(this.getReflection(), triggerId);
        }
        return false;
    }

    public boolean removeEventTrigger(int triggerId) {
        if (this._eventTriggers.remove(triggerId)) {
            if (this.getReflection().isMain()) {
                return EventTriggersManager.getInstance().removeTrigger(MapUtils.regionX(this.getX()), MapUtils.regionY(this.getY()), triggerId);
            }
            return EventTriggersManager.getInstance().removeTrigger(this.getReflection(), triggerId);
        }
        return false;
    }

    public void onSeeSocialAction(Player talker, int actionId) {
    }

    public BuyListTemplate getBuyList(int listId) {
        return null;
    }

    public String correctBypassLink(Player player, String link) {
        String dir = this.getHtmlDir(link, player);
        if (dir != null) {
            String path = dir + link;
            if (HtmCache.getInstance().getIfExists(path, player) != null) {
                return path;
            }
        }
        return link;
    }

    public void onChangeClassBypass(Player player, int classId) {
    }

    public void onSkillLearnBypass(Player player) {
    }

    @Override
    public boolean isInvulnerable() {
        return super.isInvulnerable() || this.getAI().getIntention() == CtrlIntention.AI_INTENTION_RETURN_HOME;
    }

    public void onTeleportRequest(Player talker) {
        this.showTeleportList(talker);
    }

    @Override
    public boolean onTeleported() {
        if (!super.onTeleported()) {
            return false;
        }
        this.getAI().notifyEvent(CtrlEvent.EVT_TELEPORTED);
        return true;
    }

    public void onTimerFired(int timerId) {
    }

    public void onSeeCreatue(Creature creature) {
    }

    public void onDisappearCreatue(Creature creature) {
    }

    public int getLifeTime() {
        if (this._spawnTime == 0L) {
            return 0;
        }
        return (int)((System.currentTimeMillis() - this._spawnTime) / 1000L);
    }

    public boolean inMyTerritory(Creature creature) {
        if (this.getLeader() != null) {
            return this.getLeader().inMyTerritory(creature);
        }
        SpawnRange spawnRange = this.getSpawnRange();
        if (spawnRange != null && spawnRange instanceof Territory) {
            return ((Territory)spawnRange).isInside(creature.getX(), creature.getY(), creature.getZ());
        }
        return true;
    }

    public NpcInstance createOnePrivate(int npcId, String ai, int weight, int respawn) {
        if (this.isVisible()) {
            MinionSpawner spawner = this.getMinionList().addMinion(npcId, ai, 1, respawn);
            return spawner.spawnOne();
        }
        return null;
    }

    public NpcInstance createOnePrivateEx(int npcId, String ai, int weight, int respawn, int x, int y, int z, int h, long p1, long p2, long p3) {
        if (this.isVisible()) {
            // empty if block
        }
        return null;
    }

    public Collection<RewardList> getRewardLists() {
        if (this._rewardLists == null || this._rewardLists.isEmpty()) {
            return this.getTemplate().getRewards();
        }
        ArrayList<RewardList> rewardLists = new ArrayList<RewardList>(this.getTemplate().getRewards().size() + this._rewardLists.size());
        rewardLists.addAll(this.getTemplate().getRewards());
        rewardLists.addAll(this._rewardLists);
        return rewardLists;
    }

    public void addRewardList(RewardList list) {
        if (this._rewardLists == null) {
            this._rewardLists = new ArrayList<RewardList>();
        }
        this._rewardLists.add(list);
    }

    public void removeRewardList(RewardList list) {
        if (this._rewardLists != null) {
            this._rewardLists.remove(list);
        }
    }

    @Override
    public final String getVisibleName(Player receiver) {
        String name = this.getName();
        if (name.equals(this.getTemplate().name)) {
            name = "";
        }
        return name;
    }

    @Override
    public final String getVisibleTitle(Player receiver) {
        String title = this.getTitle();
        if (title.equals("%OWNER_NAME%")) {
            Player player = this.getPlayer();
            title = player != null ? player.getVisibleName(receiver) : this._ownerName;
        } else if (title.equals(this.getTemplate().title)) {
            if (this.isMonster() && Config.ALT_SHOW_MONSTERS_LVL) {
                title = "Lv: " + this.getLevel();
                if (Config.ALT_SHOW_MONSTERS_AGRESSION) {
                    if (this.isAggressive()) {
                        title = title + " (A)";
                    } else if (this.getFaction() != Faction.NONE) {
                        title = title + " (S)";
                    }
                }
            } else {
                title = "";
            }
        }
        return title;
    }

    @Override
    protected Shape makeGeoShape() {
        int x = this.getX();
        int y = this.getY();
        int z = this.getZ();
        Circle circle = new Circle(x, y, this._geoRadius);
        circle.setZmin(z - Config.MAX_Z_DIFF);
        circle.setZmax(z + this._geoHeight);
        return circle;
    }

    @Override
    protected boolean isGeoControlEnabled() {
        return this._geoControlEnabled;
    }

    public void setGeoControlEnabled(boolean value) {
        this._geoControlEnabled = value;
    }

    @Override
    public boolean isImmobilized() {
        return this._immobilized || super.isImmobilized();
    }

    @Override
    public NpcStat getStat() {
        if (this._stat == null) {
            this._stat = new NpcStat(this);
        }
        return (NpcStat)this._stat;
    }

    @Override
    public boolean isDeathImmune() {
        return this.deathImmune || super.isDeathImmune();
    }

    private class QuestInfo
    implements Comparable<QuestInfo> {
        private final Quest quest;
        private final Player player;
        private final boolean isStart;

        public QuestInfo(Quest quest, Player player, boolean isStart) {
            this.quest = quest;
            this.player = player;
            this.isStart = isStart;
        }

        public final Quest getQuest() {
            return this.quest;
        }

        public final boolean isStart() {
            return this.isStart;
        }

        @Override
        public int compareTo(QuestInfo info) {
            int quest1 = this.quest.getDescrState(NpcInstance.this, this.player, this.isStart);
            int quest2 = info.getQuest().getDescrState(NpcInstance.this, this.player, this.isStart);
            int questId1 = this.quest.getId();
            int questId2 = info.getQuest().getId();
            if (quest1 == 1 && quest2 == 2) {
                return 1;
            }
            if (quest1 == 2 && quest2 == 1) {
                return -1;
            }
            if (quest1 == 3 && quest2 == 4) {
                return 1;
            }
            if (quest1 == 4 && quest2 == 3) {
                return -1;
            }
            if (quest1 > quest2) {
                return 1;
            }
            if (quest1 < quest2) {
                return -1;
            }
            if (questId1 > questId2) {
                return 1;
            }
            if (questId1 < questId2) {
                return -1;
            }
            return 0;
        }
    }

    public class BroadcastCharInfoTask
    implements Runnable {
        @Override
        public void run() {
            NpcInstance.this.broadcastCharInfoImpl(NpcInfoType.VALUES);
            NpcInstance.this._broadcastCharInfoTask = null;
        }
    }
}

