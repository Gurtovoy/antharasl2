package l2s.gameserver.model;

import gnu.trove.iterator.TIntLongIterator;
import gnu.trove.map.TIntLongMap;
import java.awt.Color;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.CopyOnWriteArraySet;
import java.util.concurrent.Future;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.commons.ban.BanBindType;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.commons.util.Rnd;
import l2s.commons.util.concurrent.atomic.AtomicState;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.GameServer;
import l2s.gameserver.GameTimeController;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.FakeAI;
import l2s.gameserver.ai.PlayableAI;
import l2s.gameserver.ai.PlayerAI;
import l2s.gameserver.dao.AccountVariablesDAO;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.dao.CharacterGroupReuseDAO;
import l2s.gameserver.dao.CharacterPostFriendDAO;
import l2s.gameserver.dao.CharacterPrivateStoreDAO;
import l2s.gameserver.dao.CharacterSubclassDAO;
import l2s.gameserver.dao.CharacterVariablesDAO;
import l2s.gameserver.dao.CustomHeroDAO;
import l2s.gameserver.dao.EffectsDAO;
import l2s.gameserver.dao.PremiumAccountDAO;
import l2s.gameserver.dao.SummonsDAO;
import l2s.gameserver.data.QuestHolder;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.data.xml.holder.FakePlayersHolder;
import l2s.gameserver.data.xml.holder.InstantZoneHolder;
import l2s.gameserver.data.xml.holder.ItemHolder;
import l2s.gameserver.data.xml.holder.LevelUpRewardHolder;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.data.xml.holder.PetDataHolder;
import l2s.gameserver.data.xml.holder.PlayerTemplateHolder;
import l2s.gameserver.data.xml.holder.PremiumAccountHolder;
import l2s.gameserver.data.xml.holder.RecipeHolder;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.data.xml.holder.TransformTemplateHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.database.mysql;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.handler.items.IItemHandler;
import l2s.gameserver.handler.onshiftaction.OnShiftActionHolder;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.instancemanager.AwayManager;
import l2s.gameserver.instancemanager.BotCheckManager;
import l2s.gameserver.instancemanager.GameBanManager;
import l2s.gameserver.instancemanager.MatchingRoomManager;
import l2s.gameserver.instancemanager.OfflineBufferManager;
import l2s.gameserver.instancemanager.PartySubstituteManager;
import l2s.gameserver.instancemanager.PvPRewardManager;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.instancemanager.TrainingCampManager;
import l2s.gameserver.listener.actor.player.OnAnswerListener;
import l2s.gameserver.listener.actor.player.OnPlayerChatMessageReceive;
import l2s.gameserver.listener.actor.player.impl.BotCheckAnswerListner;
import l2s.gameserver.listener.actor.player.impl.ReviveAnswerListener;
import l2s.gameserver.listener.actor.player.impl.SummonAnswerListener;
import l2s.gameserver.listener.hooks.ListenerHook;
import l2s.gameserver.listener.hooks.ListenerHookType;
import l2s.gameserver.model.CommandChannel;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.FakePlayer;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectTasks;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.MultiSellListContainer;
import l2s.gameserver.model.ObservableArena;
import l2s.gameserver.model.ObservePoint;
import l2s.gameserver.model.Party;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.PlayerGroup;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.TeleportPoint;
import l2s.gameserver.model.World;
import l2s.gameserver.model.WorldRegion;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.actor.CreatureSkillCast;
import l2s.gameserver.model.actor.basestats.PlayerBaseStats;
import l2s.gameserver.model.actor.flags.PlayerFlags;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.instances.player.Agathion;
import l2s.gameserver.model.actor.instances.player.AntiFlood;
import l2s.gameserver.model.actor.instances.player.AttendanceRewards;
import l2s.gameserver.model.actor.instances.player.BlockList;
import l2s.gameserver.model.actor.instances.player.BookMarkList;
import l2s.gameserver.model.actor.instances.player.CharacterVariable;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.model.actor.instances.player.DailyMissionList;
import l2s.gameserver.model.actor.instances.player.Fishing;
import l2s.gameserver.model.actor.instances.player.FriendList;
import l2s.gameserver.model.actor.instances.player.HennaList;
import l2s.gameserver.model.actor.instances.player.Macro;
import l2s.gameserver.model.actor.instances.player.MacroList;
import l2s.gameserver.model.actor.instances.player.Mount;
import l2s.gameserver.model.actor.instances.player.PremiumItem;
import l2s.gameserver.model.actor.instances.player.PremiumItemList;
import l2s.gameserver.model.actor.instances.player.ProductHistoryList;
import l2s.gameserver.model.actor.instances.player.ShortCut;
import l2s.gameserver.model.actor.instances.player.ShortCutList;
import l2s.gameserver.model.actor.instances.player.SubClass;
import l2s.gameserver.model.actor.instances.player.SubClassList;
import l2s.gameserver.model.actor.instances.player.TrainingCamp;
import l2s.gameserver.model.actor.instances.player.VIP;
import l2s.gameserver.model.actor.instances.player.tasks.EnableUserRelationTask;
import l2s.gameserver.model.actor.listener.PlayerListenerList;
import l2s.gameserver.model.actor.recorder.PlayerStatsChangeRecorder;
import l2s.gameserver.model.actor.stat.PlayerStat;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.ClassType;
import l2s.gameserver.model.base.Experience;
import l2s.gameserver.model.base.MountType;
import l2s.gameserver.model.base.PetType;
import l2s.gameserver.model.base.PlayerAccess;
import l2s.gameserver.model.base.PledgeRank;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.model.base.SoulShotType;
import l2s.gameserver.model.base.SubClassType;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.base.TransformType;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.impl.CastleSiegeEvent;
import l2s.gameserver.model.entity.events.impl.DuelEvent;
import l2s.gameserver.model.entity.events.impl.PvPEvent;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.impl.SingleMatchEvent;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.entity.olympiad.OlympiadGame;
import l2s.gameserver.model.entity.olympiad.OlympiadParticipiantData;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.ClanHall;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceSide;
import l2s.gameserver.model.instances.ChairInstance;
import l2s.gameserver.model.instances.DecoyInstance;
import l2s.gameserver.model.instances.GuardInstance;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.PetBabyInstance;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.model.instances.SymbolInstance;
import l2s.gameserver.model.instances.TrapInstance;
import l2s.gameserver.model.instances.residences.SiegeToggleNpcInstance;
import l2s.gameserver.model.items.ItemContainer;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.items.LockType;
import l2s.gameserver.model.items.ManufactureItem;
import l2s.gameserver.model.items.PcFreight;
import l2s.gameserver.model.items.PcInventory;
import l2s.gameserver.model.items.PcRefund;
import l2s.gameserver.model.items.PcWarehouse;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.model.items.Warehouse;
import l2s.gameserver.model.items.attachment.FlagItemAttachment;
import l2s.gameserver.model.items.attachment.PickableAttachment;
import l2s.gameserver.model.matching.MatchingRoom;
import l2s.gameserver.model.petition.PetitionMainGroup;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.model.pledge.Privilege;
import l2s.gameserver.model.pledge.RankPrivs;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.model.quest.Quest;
import l2s.gameserver.model.quest.QuestEventType;
import l2s.gameserver.model.quest.QuestState;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.gs2as.BonusRequest;
import l2s.gameserver.network.authcomm.gs2as.ReduceAccountPoints;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SceneMovie;
import l2s.gameserver.network.l2.components.StatusUpdate;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.AbnormalStatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.AcquireSkillListPacket;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.AutoAttackStartPacket;
import l2s.gameserver.network.l2.s2c.CIPacket;
import l2s.gameserver.network.l2.s2c.CameraModePacket;
import l2s.gameserver.network.l2.s2c.ChairSitPacket;
import l2s.gameserver.network.l2.s2c.ChangeWaitTypePacket;
import l2s.gameserver.network.l2.s2c.ConfirmDlgPacket;
import l2s.gameserver.network.l2.s2c.EtcStatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.ExAutoSoulShot;
import l2s.gameserver.network.l2.s2c.ExBR_AgathionEnergyInfoPacket;
import l2s.gameserver.network.l2.s2c.ExBR_PremiumStatePacket;
import l2s.gameserver.network.l2.s2c.ExBasicActionList;
import l2s.gameserver.network.l2.s2c.ExMagicAttackInfo;
import l2s.gameserver.network.l2.s2c.ExNewSkillToLearnByLevelUp;
import l2s.gameserver.network.l2.s2c.ExNotifyPremiumItem;
import l2s.gameserver.network.l2.s2c.ExOlympiadSpelledInfoPacket;
import l2s.gameserver.network.l2.s2c.ExPCCafePointInfoPacket;
import l2s.gameserver.network.l2.s2c.ExPrivateStoreWholeMsg;
import l2s.gameserver.network.l2.s2c.ExQuestItemListPacket;
import l2s.gameserver.network.l2.s2c.ExSetCompassZoneCode;
import l2s.gameserver.network.l2.s2c.ExShowScreenMessage;
import l2s.gameserver.network.l2.s2c.ExStopScenePlayerPacket;
import l2s.gameserver.network.l2.s2c.ExTeleportToLocationActivate;
import l2s.gameserver.network.l2.s2c.ExUseSharedGroupItem;
import l2s.gameserver.network.l2.s2c.ExUserInfoCubic;
import l2s.gameserver.network.l2.s2c.ExWaitWaitingSubStituteInfo;
import l2s.gameserver.network.l2.s2c.ExWorldChatCnt;
import l2s.gameserver.network.l2.s2c.GetItemPacket;
import l2s.gameserver.network.l2.s2c.InventoryUpdatePacket;
import l2s.gameserver.network.l2.s2c.ItemListPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.LogOutOkPacket;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.network.l2.s2c.MyTargetSelectedPacket;
import l2s.gameserver.network.l2.s2c.NpcInfoPoly;
import l2s.gameserver.network.l2.s2c.ObserverEndPacket;
import l2s.gameserver.network.l2.s2c.ObserverStartPacket;
import l2s.gameserver.network.l2.s2c.PartySmallWindowUpdatePacket;
import l2s.gameserver.network.l2.s2c.PartySpelledPacket;
import l2s.gameserver.network.l2.s2c.PetDeletePacket;
import l2s.gameserver.network.l2.s2c.PledgeShowMemberListUpdatePacket;
import l2s.gameserver.network.l2.s2c.PrivateStoreBuyList;
import l2s.gameserver.network.l2.s2c.PrivateStoreBuyMsg;
import l2s.gameserver.network.l2.s2c.PrivateStoreList;
import l2s.gameserver.network.l2.s2c.PrivateStoreMsg;
import l2s.gameserver.network.l2.s2c.QuestListPacket;
import l2s.gameserver.network.l2.s2c.RadarControlPacket;
import l2s.gameserver.network.l2.s2c.RecipeShopMsgPacket;
import l2s.gameserver.network.l2.s2c.RecipeShopSellListPacket;
import l2s.gameserver.network.l2.s2c.RelationChangedPacket;
import l2s.gameserver.network.l2.s2c.SayPacket2;
import l2s.gameserver.network.l2.s2c.ServerCloseSocketPacket;
import l2s.gameserver.network.l2.s2c.SetupGaugePacket;
import l2s.gameserver.network.l2.s2c.ShortBuffStatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.ShortCutInitPacket;
import l2s.gameserver.network.l2.s2c.ShortCutRegisterPacket;
import l2s.gameserver.network.l2.s2c.SkillListPacket;
import l2s.gameserver.network.l2.s2c.SnoopPacket;
import l2s.gameserver.network.l2.s2c.SocialActionPacket;
import l2s.gameserver.network.l2.s2c.SpecialCameraPacket;
import l2s.gameserver.network.l2.s2c.StatusUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessage;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.network.l2.s2c.TargetSelectedPacket;
import l2s.gameserver.network.l2.s2c.TargetUnselectedPacket;
import l2s.gameserver.network.l2.s2c.TeleportToLocationPacket;
import l2s.gameserver.network.l2.s2c.TradeDonePacket;
import l2s.gameserver.network.l2.s2c.UIPacket;
import l2s.gameserver.network.l2.s2c.ValidateLocationPacket;
import l2s.gameserver.network.l2.s2c.updatetype.IUpdateTypeComponent;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.skills.SkillInfo;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.skills.skillclasses.Summon;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.taskmanager.AutoSaveManager;
import l2s.gameserver.taskmanager.LazyPrecisionTaskManager;
import l2s.gameserver.templates.CreatureTemplate;
import l2s.gameserver.templates.InstantZone;
import l2s.gameserver.templates.OptionDataTemplate;
import l2s.gameserver.templates.PremiumAccountTemplate;
import l2s.gameserver.templates.agathion.AgathionTemplate;
import l2s.gameserver.templates.fakeplayer.FakePlayerAITemplate;
import l2s.gameserver.templates.item.ArmorTemplate;
import l2s.gameserver.templates.item.ItemTemplate;
import l2s.gameserver.templates.item.ItemType;
import l2s.gameserver.templates.item.RecipeTemplate;
import l2s.gameserver.templates.item.WeaponTemplate;
import l2s.gameserver.templates.item.data.ItemData;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.pet.PetData;
import l2s.gameserver.templates.player.PlayerTemplate;
import l2s.gameserver.templates.player.transform.TransformTemplate;
import l2s.gameserver.utils.AbnormalsComparator;
import l2s.gameserver.utils.AdminFunctions;
import l2s.gameserver.utils.BypassStorage;
import l2s.gameserver.utils.GameStats;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.Language;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.SkillUtils;
import l2s.gameserver.utils.SqlBatch;
import l2s.gameserver.utils.Strings;
import l2s.gameserver.utils.TeleportUtils;
import l2s.gameserver.utils.TimeUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.napile.primitive.Containers;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.maps.impl.CTreeIntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.napile.primitive.pair.IntObjectPair;
import org.napile.primitive.pair.impl.IntObjectPairImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class Player
extends Playable
implements PlayerGroup {
    public static final int DEFAULT_NAME_COLOR = 0xFFFFFF;
    public static final int DEFAULT_TITLE_COLOR = 0xFFFF77;
    public static final int MAX_POST_FRIEND_SIZE = 100;
    public static final Location STABLE_LOCATION = new Location(-119664, 246306, 1232);
    private static final Logger _log = LoggerFactory.getLogger(Player.class);
    public static final String NO_TRADERS_VAR = "notraders";
    public static final String NO_ANIMATION_OF_CAST_VAR = "notShowBuffAnim";
    public static final String MY_BIRTHDAY_RECEIVE_YEAR = "MyBirthdayReceiveYear";
    private static final String NOT_CONNECTED = "<not connected>";
    private static final String LVL_UP_REWARD_VAR = "@lvl_up_reward";
    private static final String ACADEMY_GRADUATED_VAR = "@academy_graduated";
    private static final String JAILED_VAR = "jailed";
    private static final String PA_ITEMS_RECIEVED = "pa_items_recieved";
    private static final String FREE_PA_RECIEVED = "free_pa_recieved";
    private static final String ACTIVE_SHOT_ID_VAR = "@active_shot_id";
    private static final String PC_BANG_POINTS_VAR = "pc_bang_poins";
    public static final String CHANGED_OLD_NAME = "changed_old_name";
    public static final String CHANGED_PLEDGE_NAME = "changed_old_pledge_name";
    private static final String PK_KILL_VAR = "@pk_kill";
    public static final int OBSERVER_NONE = 0;
    public static final int OBSERVER_STARTING = 1;
    public static final int OBSERVER_STARTED = 3;
    public static final int OBSERVER_LEAVING = 2;
    public static final int STORE_PRIVATE_NONE = 0;
    public static final int STORE_PRIVATE_SELL = 1;
    public static final int STORE_PRIVATE_BUY = 3;
    public static final int STORE_PRIVATE_MANUFACTURE = 5;
    public static final int STORE_OBSERVING_GAMES = 7;
    public static final int STORE_PRIVATE_SELL_PACKAGE = 8;
    public static final int STORE_PRIVATE_BUFF = 20;
    public static final int[] EXPERTISE_LEVELS = new int[]{0, 20, 40, 52, 61, 76, Integer.MAX_VALUE};
    private PlayerTemplate _baseTemplate;
    private GameClient _connection;
    private String _login;
    private int _karma;
    private int _pkKills;
    private int _pvpKills;
    private int _face;
    private int _hairStyle;
    private int _hairColor;
    private int _beautyFace;
    private int _beautyHairStyle;
    private int _beautyHairColor;
    private int _recomHave;
    private int _recomLeftToday;
    private int _fame;
    private int _raidPoints;
    private int _recomLeft = 0;
    private int _deleteTimer;
    private boolean _isVoting = false;
    private long _createTime;
    private long _onlineTime;
    private long _onlineBeginTime;
    private long _leaveClanTime;
    private long _deleteClanTime;
    private long _NoChannel;
    private long _NoChannelBegin;
    private long _uptime;
    private int _lastAccess;
    private int _nameColor = 0xFFFFFF;
    private int _titlecolor = 0xFFFF77;
    private boolean _overloaded;
    boolean sittingTaskLaunched;
    private int _waitTimeWhenSit;
    private boolean _autoLoot = Config.AUTO_LOOT;
    private boolean AutoLootHerbs = Config.AUTO_LOOT_HERBS;
    private boolean _autoLootOnlyAdena = Config.AUTO_LOOT_ONLY_ADENA;
    private final PcInventory _inventory = new PcInventory(this);
    private final Warehouse _warehouse = new PcWarehouse(this);
    private final ItemContainer _refund = new PcRefund(this);
    private final PcFreight _freight = new PcFreight(this);
    private final BookMarkList _bookmarks = new BookMarkList(this, 0);
    public Location bookmarkLocation = null;
    private final AntiFlood _antiFlood = new AntiFlood(this);
    private final Map<Integer, RecipeTemplate> _recipebook = new TreeMap<Integer, RecipeTemplate>();
    private final Map<Integer, RecipeTemplate> _commonrecipebook = new TreeMap<Integer, RecipeTemplate>();
    private final IntObjectMap<QuestState> _quests = new HashIntObjectMap();
    private final ShortCutList _shortCuts = new ShortCutList(this);
    private final MacroList _macroses = new MacroList(this);
    private final SubClassList _subClassList = new SubClassList(this);
    private int _privatestore;
    private String _manufactureName;
    private Map<Integer, ManufactureItem> _createList = Collections.emptyMap();
    private String _sellStoreName;
    private String _packageSellStoreName;
    private Map<Integer, TradeItem> _sellList = Collections.emptyMap();
    private Map<Integer, TradeItem> _packageSellList = Collections.emptyMap();
    private String _buyStoreName;
    private List<TradeItem> _buyList = Collections.emptyList();
    private List<TradeItem> _tradeList = Collections.emptyList();
    private Party _party;
    private Location _lastPartyPosition;
    private Clan _clan;
    private PledgeRank _pledgeRank = PledgeRank.VAGABOND;
    private int _pledgeType = -128;
    private int _powerGrade = 0;
    private int _lvlJoinedAcademy = 0;
    private int _apprentice = 0;
    private int _accessLevel;
    private PlayerAccess _playerAccess = new PlayerAccess();
    private boolean _messageRefusal = false;
    private boolean _tradeRefusal = false;
    private boolean _blockAll = false;
    private SummonInstance _summon = null;
    private PetInstance _pet = null;
    private SymbolInstance _symbol = null;
    private boolean _riding;
    private int _botRating;
    private List<DecoyInstance> _decoys = new CopyOnWriteArrayList<DecoyInstance>();
    private IntObjectMap<Cubic> _cubics = null;
    private Agathion _agathion = null;
    private Request _request;
    private ItemInstance _arrowItem;
    private WeaponTemplate _fistsWeaponItem;
    private Map<Integer, String> _chars = new HashMap<Integer, String>(8);
    private ItemInstance _enchantScroll = null;
    private ItemInstance _appearanceStone = null;
    private ItemInstance _appearanceExtractItem = null;
    private Warehouse.WarehouseType _usingWHType;
    private boolean _isOnline = false;
    private final AtomicBoolean _isLogout = new AtomicBoolean();
    private HardReference<NpcInstance> _lastNpc = HardReferences.emptyRef();
    private MultiSellListContainer _multisell = null;
    private IntObjectMap<SoulShotType> _activeAutoShots = new CHashIntObjectMap();
    private ObservePoint _observePoint;
    private AtomicInteger _observerMode = new AtomicInteger(0);
    public int _telemode = 0;
    public boolean entering = true;
    private Location _stablePoint = null;
    public int[] _loto = new int[5];
    public int[] _race = new int[2];
    private final BlockList _blockList = new BlockList(this);
    private final FriendList _friendList = new FriendList(this);
    private final PremiumItemList _premiumItemList = new PremiumItemList(this);
    private final ProductHistoryList _productHistoryList = new ProductHistoryList(this);
    private final HennaList _hennaList = new HennaList(this);
    private final AttendanceRewards _attendanceRewards = new AttendanceRewards(this);
    private final DailyMissionList _dailiyMissionList = new DailyMissionList(this);
    private final VIP _vip = new VIP(this);
    private boolean _hero = false;
    private PremiumAccountTemplate _premiumAccount = PremiumAccountHolder.getInstance().getPremiumAccount(0);
    private Future<?> _premiumAccountExpirationTask;
    private boolean _isSitting;
    private ChairInstance _chairObject;
    private boolean _inOlympiadMode;
    private OlympiadGame _olympiadGame;
    private ObservableArena _observableArena;
    private int _olympiadSide = -1;
    private int _varka = 0;
    private int _ketra = 0;
    private int _ram = 0;
    private byte[] _keyBindings = ArrayUtils.EMPTY_BYTE_ARRAY;
    private final Fishing _fishing = new Fishing(this);
    private Future<?> _taskWater;
    private Future<?> _autoSaveTask;
    private Future<?> _kickTask;
    private Future<?> _pcCafePointsTask;
    private Future<?> _unjailTask;
    private Future<?> _trainingCampTask;
    private Future<?> _sceneMovieEndTask;
    private final Lock _storeLock = new ReentrantLock();
    private int _zoneMask;
    private long _offlineStartTime = 0L;
    private boolean _awaying = false;
    private boolean _registeredInEvent = false;
    private int _pcBangPoints;
    private int _expandInventory = 0;
    private int _expandWarehouse = 0;
    private int _battlefieldChatId;
    private int _lectureMark;
    private AtomicState _gmInvisible = new AtomicState();
    private AtomicState _gmUndying = new AtomicState();
    private IntObjectMap<String> _postFriends = Containers.emptyIntObjectMap();
    private List<String> _blockedActions = new ArrayList<String>();
    private BypassStorage _bypassStorage = new BypassStorage(this);
    private boolean _notShowBuffAnim = false;
    private boolean _notShowTraders = false;
    private boolean _canSeeAllShouts = false;
    private boolean _debug = false;
    private long _dropDisabled;
    private long _lastItemAuctionInfoRequest;
    private IntObjectPair<OnAnswerListener> _askDialog = null;
    private boolean _matchingRoomWindowOpened = false;
    private MatchingRoom _matchingRoom;
    private PetitionMainGroup _petitionGroup;
    private final Map<Integer, Long> _instancesReuses = new ConcurrentHashMap<Integer, Long>();
    private Language _language = Config.DEFAULT_LANG;
    private int _npcDialogEndTime = 0;
    private Mount _mount = null;
    private final Map<String, CharacterVariable> _variables = new ConcurrentHashMap<String, CharacterVariable>();
    private List<SummonInstance.RestoredSummon> _restoredSummons = null;
    private boolean _autoSearchParty;
    private Future<?> _substituteTask;
    private TransformTemplate _transform = null;
    private final IntObjectMap<SkillEntry> _transformSkills = new CHashIntObjectMap();
    private long _lastMultisellBuyTime = 0L;
    private long _lastEnchantItemTime = 0L;
    private long _lastAttributeItemTime = 0L;
    private Future<?> _enableRelationTask;
    private boolean _isInReplaceTeleport = false;
    private int _armorSetEnchant = 0;
    private int _usedWorldChatPoints = 0;
    private boolean _hideHeadAccessories = false;
    private ItemInstance _synthesisItem1 = null;
    private ItemInstance _synthesisItem2 = null;
    private List<TrapInstance> _traps = Collections.emptyList();
    private boolean _isInJail = false;
    private final IntObjectMap<OptionDataTemplate> _options = new CTreeIntObjectMap();
    private long _receivedExp = 0L;
    private Reflection _activeReflection = null;
    private int _questZoneId = -1;
    private ClassId _selectedMultiClassId = null;
    protected final ReadWriteLock questLock = new ReentrantReadWriteLock();
    protected final Lock questRead = this.questLock.readLock();
    protected final Lock questWrite = this.questLock.writeLock();
    private final List<ScheduledFuture<?>> _tasks = new ArrayList();
    private static final int FALLING_VALIDATION_DELAY = 10000;
    private volatile long _fallingTimestamp = 0L;
    private boolean _dontRewardSkills = false;
    private ScheduledFuture<?> _broadcastCharInfoTask;
    private int _polyNpcId;
    private Future<?> _userInfoTask;
    private static final SchedulingPattern DAILY_TIME_PATTERN = new SchedulingPattern("30 6 * * *");
    private static final SchedulingPattern WEEKLY_TIME_PATTERN = new SchedulingPattern("30 6 * * 3");
    private boolean _maried = false;
    private int _partnerId = 0;
    private int _coupleId = 0;
    private boolean _maryrequest = false;
    private boolean _maryaccepted = false;
    private OnPlayerChatMessageReceive _snoopListener = null;
    private List<Player> _snoopListenerPlayers = new ArrayList<Player>();
    private boolean _charmOfCourage = false;
    private int _increasedForce = 0;
    private int _useSeed = 0;
    protected int _pvpFlag;
    private Future<?> _PvPRegTask;
    private long _lastPvPAttack;
    private long _lastAttackPacket = 0L;
    private long _lastMovePacket = 0L;
    private Location _groundSkillLoc;
    private int _buyListId;
    private final int _incorrectValidateCount = 0;
    private int _movieId = 0;
    private ItemInstance _petControlItem = null;
    private AtomicBoolean isActive = new AtomicBoolean();
    private Future<?> _hourlyTask;
    private AtomicInteger _hoursInGame = new AtomicInteger(0);
    private boolean _agathionResAvailable = false;
    private Map<String, String> _userSession;
    private long _blockUntilTime = 0L;
    private static final int[] ADDITIONAL_SS_EFFECTS = new int[]{70455, 70454, 70453, 70452, 70451, 90332, 90331, 90330, 90329, 90328, 70460, 70459, 70458, 70457, 70456, 90337, 90336, 90335, 90334, 90333};
    private final ConcurrentHashMap<ListenerHookType, CopyOnWriteArraySet<ListenerHook>> scriptHookTypeList = new ConcurrentHashMap();
    private final Map<BanBindType, Pair<Integer, Future<?>>> banTasks = new HashMap();

    public Player(int objectId, PlayerTemplate template, String accountName) {
        super(objectId, template);
        this._baseTemplate = template;
        this._login = accountName;
    }

    private Player(FakePlayerAITemplate fakeAiTemplate, int objectId, PlayerTemplate template) {
        this(objectId, template, null);
        this._ai = new FakeAI(this, fakeAiTemplate);
    }

    private Player(int objectId, PlayerTemplate template) {
        this(objectId, template, null);
        this._ai = new PlayerAI(this);
        if (!Config.EVERYBODY_HAS_ADMIN_RIGHTS) {
            this.setPlayerAccess(Config.gmlist.get(objectId));
        } else {
            this.setPlayerAccess(Config.gmlist.get(0));
        }
    }

    @SuppressWarnings("unchecked")
    public HardReference<Player> getRef() {
        return (HardReference<Player>) super.getRef();
    }

    public String getAccountName() {
        if (this._connection == null) {
            return this._login;
        }
        return this._connection.getLogin();
    }

    public String getIP() {
        if (this._connection == null) {
            return NOT_CONNECTED;
        }
        return this._connection.getIpAddr();
    }

    public String getLogin() {
        return this._login;
    }

    public void setLogin(String val) {
        this._login = val;
    }

    public Map<Integer, String> getAccountChars() {
        return this._chars;
    }

    @Override
    public final PlayerTemplate getTemplate() {
        return (PlayerTemplate)super.getTemplate();
    }

    @Override
    public final void setTemplate(CreatureTemplate template) {
        if (this.isBaseClassActive()) {
            this._baseTemplate = (PlayerTemplate)template;
        }
        super.setTemplate(template);
    }

    public final PlayerTemplate getBaseTemplate() {
        return this._baseTemplate;
    }

    @Override
    public final boolean isTransformed() {
        return this._transform != null;
    }

    @Override
    public final TransformTemplate getTransform() {
        return this._transform;
    }

    @Override
    public final void setTransform(int id) {
        TransformTemplate template = id > 0 ? TransformTemplateHolder.getInstance().getTemplate(this.getSex(), id) : null;
        this.setTransform(template);
    }

    @Override
    public final synchronized void setTransform(TransformTemplate transform) {
        if (transform == this._transform || transform != null && this._transform != null) {
            return;
        }
        if (transform == null) {
            if (!this._transformSkills.isEmpty()) {
                for (SkillEntry skillEntry : this._transformSkills.valueCollection()) {
                    if (SkillAcquireHolder.getInstance().isSkillPossible(this, skillEntry.getTemplate())) continue;
                    super.removeSkill(skillEntry);
                }
                this._transformSkills.clear();
            }
            if (this._transform.getItemCheckType() != LockType.NONE) {
                this.getInventory().unlock();
            }
            this._transform = transform;
            this.checkActiveToggleEffects();
            this.getAbnormalList().stop(AbnormalType.TRANSFORM);
        } else {
            SkillEntry skillEntry;
            boolean isFlying;
            boolean bl = isFlying = transform.getType() == TransformType.FLYING;
            if (isFlying) {
                for (Servitor servitor : this.getServitors()) {
                    servitor.unSummon(false);
                }
            }
            for (SkillLearn skillLearn : transform.getSkills()) {
                skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillLearn.getId(), skillLearn.getLevel());
                if (skillEntry == null) continue;
                this._transformSkills.put(skillEntry.getId(), skillEntry);
            }
            for (SkillLearn skillLearn : transform.getAddtionalSkills()) {
                if (skillLearn.getMinLevel() > this.getLevel() || (skillEntry = (SkillEntry)this._transformSkills.get(skillLearn.getId())) != null && skillEntry.getLevel() >= skillLearn.getLevel() || (skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, skillLearn.getId(), skillLearn.getLevel())) == null) continue;
                this._transformSkills.put(skillEntry.getId(), skillEntry);
            }
            for (SkillEntry skillEntry2 : this._transformSkills.valueCollection()) {
                this.addSkill(skillEntry2, false);
            }
            if (transform.getItemCheckType() != LockType.NONE) {
                this.getInventory().unlock();
                this.getInventory().lockItems(transform.getItemCheckType(), transform.getItemCheckIDs());
            }
            this.checkActiveToggleEffects();
            this._transform = transform;
        }
        this.setZ(this.getZ() + (this.isFlying() ? 300 : 0) + (int)this.getCurrentCollisionHeight(), false);
        this.sendPacket((IBroadcastPacket)new ExBasicActionList(this));
        this.sendSkillList();
        this.sendPacket((IBroadcastPacket)new ShortCutInitPacket(this));
        this.sendActiveAutoShots();
        this.sendChanges();
        this.setZ(this.getZ(), true);
    }

    @Override
    public final boolean isFlying() {
        return super.isFlying() || this._transform != null && this._transform.getType() == TransformType.FLYING;
    }

    public void changeSex() {
        PlayerTemplate template = PlayerTemplateHolder.getInstance().getPlayerTemplate(this.getRace(), this.getClassId(), this.getSex().revert());
        if (template == null) {
            return;
        }
        this.setTemplate(template);
        if (this.isTransformed()) {
            int transformId = this.getTransform().getId();
            this.setTransform(null);
            this.setTransform(transformId);
        }
    }

    @Override
    public PlayerAI getAI() {
        return (PlayerAI)this._ai;
    }

    @Override
    public boolean doCast(SkillEntry skillEntry, Creature target, boolean forceUse) {
        return super.doCast(skillEntry, target, forceUse);
    }

    @Override
    public void sendReuseMessage(Skill skill) {
        if (this.getSkillLevel(skill.getId(), 0) > 0) {
            return;
        }
        if (this.getSkillCast(SkillCastingType.NORMAL).isCastingNow() && (!this.isDualCastEnable() || this.getSkillCast(SkillCastingType.NORMAL_SECOND).isCastingNow())) {
            return;
        }
        TimeStamp sts = this.getSkillReuse(skill);
        if (sts == null || !sts.hasNotPassed()) {
            return;
        }
        long timeleft = sts.getReuseCurrent();
        if (!Config.ALT_SHOW_REUSE_MSG && timeleft < 10000L || timeleft < 500L) {
            return;
        }
        int hours = (int)TimeUnit.MILLISECONDS.toHours(timeleft);
        int minutes = (int)TimeUnit.MILLISECONDS.toMinutes(timeleft - TimeUnit.HOURS.toMillis(hours));
        int seconds = (int)Math.max(1L, TimeUnit.MILLISECONDS.toSeconds(timeleft - TimeUnit.HOURS.toMillis(hours) - TimeUnit.MINUTES.toMillis(minutes)));
        if (hours > 0) {
            this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.THERE_ARE_S2_HOURS_S3_MINUTES_AND_S4_SECONDS_REMAINING_IN_S1S_REUSE_TIME).addSkillName(skill)).addByte((byte)hours)).addByte((byte)minutes)).addByte((byte)seconds));
        } else if (minutes > 0) {
            this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.THERE_ARE_S2_MINUTES_S3_SECONDS_REMAINING_IN_S1S_REUSE_TIME).addSkillName(skill)).addByte((byte)minutes)).addByte((byte)seconds));
        } else {
            this.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.THERE_ARE_S2_SECONDS_REMAINING_IN_S1S_REUSE_TIME).addSkillName(skill)).addByte((byte)seconds));
        }
    }

    @Override
    public final int getLevel() {
        return this.getActiveSubClass() == null ? 1 : this.getActiveSubClass().getLevel();
    }

    @Override
    public final Sex getSex() {
        return this.getTemplate().getSex();
    }

    public int getFace() {
        return this._face;
    }

    public void setFace(int face) {
        this._face = face;
    }

    public int getBeautyFace() {
        return this._beautyFace;
    }

    public void setBeautyFace(int face) {
        this._beautyFace = face;
    }

    public int getHairColor() {
        return this._hairColor;
    }

    public void setHairColor(int hairColor) {
        this._hairColor = hairColor;
    }

    public int getBeautyHairColor() {
        return this._beautyHairColor;
    }

    public void setBeautyHairColor(int hairColor) {
        this._beautyHairColor = hairColor;
    }

    public int getHairStyle() {
        return this._hairStyle;
    }

    public void setHairStyle(int hairStyle) {
        this._hairStyle = hairStyle;
    }

    public int getBeautyHairStyle() {
        return this._beautyHairStyle;
    }

    public void setBeautyHairStyle(int hairStyle) {
        this._beautyHairStyle = hairStyle;
    }

    public void offline() {
        this.offline(Config.SERVICES_OFFLINE_TRADE_SECONDS_TO_KICK);
    }

    public void offline(int delay) {
        if (this._connection != null) {
            this._connection.setActiveChar(null);
            this._connection.close(ServerCloseSocketPacket.STATIC);
            this.setNetConnection(null);
        }
        this.startAbnormalEffect(Config.SERVICES_OFFLINE_TRADE_ABNORMAL_EFFECT);
        this.setOfflineMode(true);
        if (this.isInBuffStore()) {
            OfflineBufferManager.getInstance().storeBufferData(this);
        } else {
            this.storePrivateStore();
        }
        if (delay > 0) {
            this.setVar(this.isInBuffStore() ? "offlinebuff" : "offline", (long)delay + System.currentTimeMillis() / 1000L);
            this.startKickTask((long)delay * 1000L);
        } else {
            this.setVar(this.isInBuffStore() ? "offlinebuff" : "offline", Integer.MAX_VALUE);
        }
        Party party = this.getParty();
        if (party != null) {
            this.leaveParty(false);
        }
        if (this.isAutoSearchParty()) {
            PartySubstituteManager.getInstance().removeWaitingPlayer(this);
        }
        for (Servitor servitor : this.getServitors()) {
            servitor.unSummon(false);
        }
        Olympiad.logoutPlayer(this);
        if (this.isFishing()) {
            this.getFishing().stop();
        }
        MatchingRoomManager.getInstance().removeFromWaitingList(this);
        this.broadcastCharInfo();
        this.stopWaterTask();
        this.stopPremiumAccountTask();
        this.stopHourlyTask();
        this.stopPcBangPointsTask();
        this.stopTrainingCampTask();
        this.stopAutoSaveTask();
        this.stopQuestTimers();
        this.stopEnableUserRelationTask();
        this.broadcastUserInfo(true);
        try {
            this.getInventory().store();
        }
        catch (Throwable t) {
            _log.error("", t);
        }
        try {
            this.store(false);
        }
        catch (Throwable t) {
            _log.error("", t);
        }
    }

    public void kick() {
        this.prepareToLogout1();
        if (this._connection != null) {
            this._connection.close(LogOutOkPacket.STATIC);
            this.setNetConnection(null);
        }
        this.prepareToLogout2();
        this.deleteMe();
    }

    public void restart() {
        this.prepareToLogout1();
        if (this._connection != null) {
            this._connection.setActiveChar(null);
            this.setNetConnection(null);
        }
        this.prepareToLogout2();
        this.deleteMe();
    }

    public void logout() {
        this.prepareToLogout1();
        if (this._connection != null) {
            this._connection.close(ServerCloseSocketPacket.STATIC);
            this.setNetConnection(null);
        }
        this.prepareToLogout2();
        this.deleteMe();
    }

    private void prepareToLogout1() {
        for (Servitor servitor : this.getServitors()) {
            this.sendPacket((IBroadcastPacket)new PetDeletePacket(servitor.getObjectId(), servitor.getServitorType()));
        }
        if (this.isProcessingRequest()) {
            Request request = this.getRequest();
            if (this.isInTrade()) {
                Player parthner = request.getOtherPlayer(this);
                parthner.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_ONLINE);
                parthner.sendPacket((IBroadcastPacket)TradeDonePacket.FAIL);
            }
            request.cancel(new IBroadcastPacket[0]);
        }
        World.removeObjectsFromPlayer(this);
    }

    private void prepareToLogout2() {
        MatchingRoom room;
        SubUnit unit;
        UnitMember member;
        Party party;
        if (this._isLogout.getAndSet(true)) {
            return;
        }
        for (ListenerHook hook : this.getListenerHooks(ListenerHookType.PLAYER_QUIT_GAME)) {
            hook.onPlayerQuitGame(this);
        }
        for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.PLAYER_QUIT_GAME)) {
            hook.onPlayerQuitGame(this);
        }
        FlagItemAttachment attachment = this.getActiveWeaponFlagAttachment();
        if (attachment != null) {
            attachment.onLogout(this);
        }
        this.setNetConnection(null);
        this.setIsOnline(false);
        this.getListeners().onExit();
        if (this.isFlying() && !this.checkLandingState()) {
            this._stablePoint = TeleportUtils.getRestartPoint(this, RestartType.TO_VILLAGE).getLoc();
        }
        if (this.isCastingNow()) {
            this.abortCast(true, true);
        }
        if ((party = this.getParty()) != null) {
            this.leaveParty(false);
        }
        if (this._observableArena != null) {
            this._observableArena.removeObserver(this._observePoint);
        }
        Olympiad.logoutPlayer(this);
        if (this.isFishing()) {
            this.getFishing().stop();
        }
        for (Servitor servitor : this.getServitors()) {
            servitor.unSummon(true);
        }
        if (this.isMounted()) {
            this._mount.onLogout();
        }
        this._friendList.notifyFriends(false);
        if (this.getClan() != null) {
            this.getClan().loginClanCond(this, false);
        }
        if (this.isProcessingRequest()) {
            this.getRequest().cancel(new IBroadcastPacket[0]);
        }
        this.stopAllTimers();
        if (this.isInBoat()) {
            this.getBoat().removePlayer(this);
        }
        UnitMember unitMember = member = (unit = this.getSubUnit()) == null ? null : unit.getUnitMember(this.getObjectId());
        if (member != null) {
            int sponsor = member.getSponsor();
            int apprentice = this.getApprentice();
            PledgeShowMemberListUpdatePacket memberUpdate = new PledgeShowMemberListUpdatePacket(this);
            for (Player clanMember : this._clan.getOnlineMembers(this.getObjectId())) {
                clanMember.sendPacket((IBroadcastPacket)memberUpdate);
                if (clanMember.getObjectId() == sponsor) {
                    clanMember.sendPacket((IBroadcastPacket)new SystemMessage(1757).addString(this._name));
                    continue;
                }
                if (clanMember.getObjectId() != apprentice) continue;
                clanMember.sendPacket((IBroadcastPacket)new SystemMessage(1759).addString(this._name));
            }
            member.setPlayerInstance(this, true);
        }
        if ((room = this.getMatchingRoom()) != null) {
            if (room.getLeader() == this) {
                room.disband();
            } else {
                room.removeMember(this, false);
            }
        }
        this.setMatchingRoom(null);
        MatchingRoomManager.getInstance().removeFromWaitingList(this);
        this.destroyAllTraps();
        if (!this._decoys.isEmpty()) {
            for (DecoyInstance decoy : this.getDecoys()) {
                decoy.unSummon();
                this.removeDecoy(decoy);
            }
        }
        this.stopPvPFlag();
        Reflection ref = this.getReflection();
        if (!ref.isMain()) {
            if (ref.getReturnLoc() != null) {
                this._stablePoint = ref.getReturnLoc();
            }
            ref.removeObject(this);
        }
        try {
            this.getInventory().store();
            this.getRefund().clear();
        }
        catch (Throwable t) {
            _log.error("", t);
        }
        try {
            this.store(false);
        }
        catch (Throwable t) {
            _log.error("", t);
        }
    }

    public Collection<RecipeTemplate> getDwarvenRecipeBook() {
        return this._recipebook.values();
    }

    public Collection<RecipeTemplate> getCommonRecipeBook() {
        return this._commonrecipebook.values();
    }

    public int recipesCount() {
        return this._commonrecipebook.size() + this._recipebook.size();
    }

    public boolean hasRecipe(RecipeTemplate id) {
        return this._recipebook.containsValue(id) || this._commonrecipebook.containsValue(id);
    }

    public boolean findRecipe(int id) {
        return this._recipebook.containsKey(id) || this._commonrecipebook.containsKey(id);
    }

    public void registerRecipe(RecipeTemplate recipe, boolean saveDB) {
        if (recipe == null) {
            return;
        }
        if (recipe.isCommon()) {
            this._commonrecipebook.put(recipe.getId(), recipe);
        } else {
            this._recipebook.put(recipe.getId(), recipe);
        }
        if (saveDB) {
            mysql.set("REPLACE INTO character_recipebook (char_id, id) VALUES(?,?)", this.getObjectId(), recipe.getId());
        }
    }

    public void unregisterRecipe(int RecipeID) {
        if (this._recipebook.containsKey(RecipeID)) {
            mysql.set("DELETE FROM `character_recipebook` WHERE `char_id`=? AND `id`=? LIMIT 1", this.getObjectId(), RecipeID);
            this._recipebook.remove(RecipeID);
        } else if (this._commonrecipebook.containsKey(RecipeID)) {
            mysql.set("DELETE FROM `character_recipebook` WHERE `char_id`=? AND `id`=? LIMIT 1", this.getObjectId(), RecipeID);
            this._commonrecipebook.remove(RecipeID);
        } else {
            _log.warn("Attempted to remove unknown RecipeList" + RecipeID);
        }
    }

    public QuestState getQuestState(int id) {
        this.questRead.lock();
        try {
            QuestState questState = (QuestState)this._quests.get(id);
            return questState;
        }
        finally {
            this.questRead.unlock();
        }
    }

    public QuestState getQuestState(Quest quest) {
        return this.getQuestState(quest.getId());
    }

    public boolean isQuestCompleted(int id) {
        QuestState qs = this.getQuestState(id);
        return qs != null && qs.isCompleted();
    }

    public boolean isQuestCompleted(Quest quest) {
        return this.isQuestCompleted(quest.getId());
    }

    public void setQuestState(QuestState qs) {
        this.questWrite.lock();
        try {
            this._quests.put(qs.getQuest().getId(), qs);
        }
        finally {
            this.questWrite.unlock();
        }
    }

    public void removeQuestState(int id) {
        this.questWrite.lock();
        try {
            this._quests.remove(id);
        }
        finally {
            this.questWrite.unlock();
        }
    }

    public void removeQuestState(Quest quest) {
        this.removeQuestState(quest.getId());
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public Quest[] getAllActiveQuests() {
        ArrayList<Quest> quests = new ArrayList<Quest>(this._quests.size());
        this.questRead.lock();
        try {
            for (QuestState qs : this._quests.valueCollection()) {
                if (!qs.isStarted()) continue;
                quests.add(qs.getQuest());
            }
        }
        finally {
            this.questRead.unlock();
        }
        return quests.toArray(new Quest[quests.size()]);
    }

    public QuestState[] getAllQuestsStates() {
        this.questRead.lock();
        try {
            QuestState[] questStateArray = (QuestState[])this._quests.values(new QuestState[this._quests.size()]);
            return questStateArray;
        }
        finally {
            this.questRead.unlock();
        }
    }

    public List<QuestState> getQuestsForEvent(NpcInstance npc, QuestEventType event) {
        ArrayList<QuestState> states = new ArrayList<QuestState>();
        Set<Quest> quests = npc.getTemplate().getEventQuests(event);
        if (quests != null) {
            for (Quest quest : quests) {
                QuestState qs = this.getQuestState(quest);
                if (qs == null || qs.isCompleted()) continue;
                states.add(this.getQuestState(quest));
            }
        }
        return states;
    }

    public void processQuestEvent(int questId, String event, NpcInstance npc) {
        QuestState qs;
        if (event == null) {
            event = "";
        }
        if ((qs = this.getQuestState(questId)) == null) {
            Quest q = QuestHolder.getInstance().getQuest(questId);
            if (q == null) {
                _log.warn("Quest ID[" + questId + "] not found!");
                return;
            }
            qs = q.newQuestState(this);
        }
        if (qs == null || qs.isCompleted()) {
            return;
        }
        qs.getQuest().notifyEvent(event, qs, npc);
        this.sendPacket((IBroadcastPacket)new QuestListPacket(this));
    }

    public boolean isInventoryFull() {
        return this.getWeightPenalty() >= 3 || (double)this.getInventoryLimit() * 0.8 < (double)this.getInventory().getSize();
    }

    public boolean isQuestContinuationPossible(boolean msg) {
        if (this.isInventoryFull() || (double)Config.QUEST_INVENTORY_MAXIMUM * 0.8 < (double)this.getInventory().getQuestSize()) {
            if (msg) {
                this.sendPacket((IBroadcastPacket)SystemMsg.PROGRESS_IN_A_QUEST_IS_POSSIBLE_ONLY_WHEN_YOUR_INVENTORYS_WEIGHT_AND_SLOT_COUNT_ARE_LESS_THAN_80_PERCENT_OF_CAPACITY);
            }
            return false;
        }
        return true;
    }

    public void stopQuestTimers() {
        for (QuestState qs : this.getAllQuestsStates()) {
            if (qs.isStarted()) {
                qs.pauseQuestTimers();
                continue;
            }
            qs.stopQuestTimers();
        }
    }

    public void resumeQuestTimers() {
        for (QuestState qs : this.getAllQuestsStates()) {
            qs.resumeQuestTimers();
        }
    }

    public Collection<ShortCut> getAllShortCuts() {
        return this._shortCuts.getAllShortCuts();
    }

    public ShortCut getShortCut(int slot, int page) {
        return this._shortCuts.getShortCut(slot, page);
    }

    public void registerShortCut(ShortCut shortcut) {
        this._shortCuts.registerShortCut(shortcut);
    }

    public void deleteShortCut(int slot, int page) {
        this._shortCuts.deleteShortCut(slot, page);
    }

    public void registerMacro(Macro macro) {
        this._macroses.registerMacro(macro);
    }

    public void deleteMacro(int id) {
        this._macroses.deleteMacro(id);
    }

    public MacroList getMacroses() {
        return this._macroses;
    }

    public boolean isCastleLord(int castleId) {
        return this._clan != null && this.isClanLeader() && this._clan.getCastle() == castleId;
    }

    public int getPkKills() {
        return this._pkKills;
    }

    public void setPkKills(int pkKills) {
        this._pkKills = pkKills;
    }

    public long getCreateTime() {
        return this._createTime;
    }

    public void setCreateTime(long createTime) {
        this._createTime = createTime;
    }

    public int getDeleteTimer() {
        return this._deleteTimer;
    }

    public void setDeleteTimer(int deleteTimer) {
        this._deleteTimer = deleteTimer;
    }

    @Override
    public int getCurrentLoad() {
        return this.getInventory().getTotalWeight();
    }

    public long getLastAccess() {
        return this._lastAccess;
    }

    public void setLastAccess(int value) {
        this._lastAccess = value;
    }

    public int getRecomHave() {
        return this._recomHave;
    }

    public void setRecomHave(int value) {
        this._recomHave = value > 255 ? 255 : (value < 0 ? 0 : value);
    }

    public int getRecomLeft() {
        return this._recomLeft;
    }

    public void setRecomLeft(int value) {
        this._recomLeft = value;
    }

    public void giveRecom(Player target) {
        int targetRecom = target.getRecomHave();
        if (targetRecom < 255) {
            target.addRecomHave(1);
        }
        if (this.getRecomLeft() > 0) {
            this.setRecomLeft(this.getRecomLeft() - 1);
        }
        this.sendUserInfo(true);
    }

    public void addRecomHave(int val) {
        this.setRecomHave(this.getRecomHave() + val);
        this.broadcastUserInfo(true);
    }

    @Override
    public int getKarma() {
        return this._karma;
    }

    public void setKarma(int karma) {
        if (this._karma == karma) {
            return;
        }
        this._karma = Math.min(0, karma);
        this.sendChanges();
        for (Servitor servitor : this.getServitors()) {
            servitor.broadcastCharInfo();
        }
    }

    @Override
    public int getMaxLoad() {
        return (int)this.getStat().calc(Stats.MAX_LOAD, 69000.0, this, null);
    }

    @Override
    public void updateAbnormalIcons() {
        if (this.entering || this.isLogoutStarted()) {
            return;
        }
        super.updateAbnormalIcons();
    }

    @Override
    public void updateAbnormalIconsImpl() {
        OlympiadGame olymp_game;
        Abnormal[] effects = this.getAbnormalList().toArray();
        Arrays.sort(effects, AbnormalsComparator.getInstance());
        PartySpelledPacket ps = new PartySpelledPacket(this, false);
        AbnormalStatusUpdatePacket abnormalStatus = new AbnormalStatusUpdatePacket();
        for (Abnormal effect : effects) {
            if (effect == null) continue;
            if (effect.checkAbnormalType(AbnormalType.HP_RECOVER)) {
                this.sendPacket((IBroadcastPacket)new ShortBuffStatusUpdatePacket(effect));
            } else {
                effect.addIcon(abnormalStatus);
            }
            if (this._party == null) continue;
            effect.addPartySpelledIcon(ps);
        }
        this.sendPacket((IBroadcastPacket)abnormalStatus);
        if (this._party != null) {
            this._party.broadCast(ps);
        }
        if (this.isInOlympiadMode() && this.isOlympiadCompStart() && (olymp_game = this._olympiadGame) != null) {
            ExOlympiadSpelledInfoPacket olympiadSpelledInfo = new ExOlympiadSpelledInfoPacket();
            for (Abnormal effect : effects) {
                if (effect == null) continue;
                effect.addOlympiadSpelledIcon(this, olympiadSpelledInfo);
            }
            this.sendPacket((IBroadcastPacket)olympiadSpelledInfo);
            for (ObservePoint observer : olymp_game.getObservers()) {
                observer.sendPacket((IBroadcastPacket)olympiadSpelledInfo);
            }
        }
        List<SingleMatchEvent> events = this.getEvents(SingleMatchEvent.class);
        for (SingleMatchEvent event : events) {
            event.onEffectIconsUpdate(this, effects);
        }
        super.updateAbnormalIconsImpl();
    }

    @Override
    public int getWeightPenalty() {
        return this.getSkillLevel(4270, 0);
    }

    public void refreshOverloaded() {
        if (this.isLogoutStarted() || this.getMaxLoad() <= 0) {
            return;
        }
        this.setOverloaded(this.getCurrentLoad() > this.getMaxLoad());
        double weightproc = 100.0 * ((double)this.getCurrentLoad() - this.getStat().calc(Stats.MAX_NO_PENALTY_LOAD, 0.0, this, null)) / (double)this.getMaxLoad();
        int newWeightPenalty = 0;
        newWeightPenalty = weightproc < 50.0 ? 0 : (weightproc < 66.6 ? 1 : (weightproc < 80.0 ? 2 : (weightproc < 100.0 ? 3 : 4)));
        int current = this.getWeightPenalty();
        if (current == newWeightPenalty) {
            return;
        }
        boolean update = false;
        if (newWeightPenalty > 0) {
            SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 4270, newWeightPenalty);
            if (skillEntry != null && !skillEntry.equals(this.addSkill(skillEntry))) {
                update = true;
            }
        } else if (super.removeSkill(this.getKnownSkill(4270)) != null) {
            update = true;
        }
        if (update) {
            this.sendSkillList();
            this.sendEtcStatusUpdate();
            this.updateStats(false, true);
        }
    }

    public int getArmorsExpertisePenalty() {
        return this.getSkillLevel(6213, 0);
    }

    public int getWeaponsExpertisePenalty() {
        return this.getSkillLevel(6209, 0);
    }

    public int getExpertisePenalty(ItemInstance item) {
        if (item.getTemplate().getType2() == 0) {
            return this.getWeaponsExpertisePenalty();
        }
        if (item.getTemplate().getType2() == 1 || item.getTemplate().getType2() == 2) {
            return this.getArmorsExpertisePenalty();
        }
        return 0;
    }

    public void refreshExpertisePenalty() {
        if (this.isLogoutStarted()) {
            return;
        }
        int level = (int)this.getStat().calc(Stats.GRADE_EXPERTISE_LEVEL, this.getLevel(), null, null);
        int expertiseIndex = 0;
        for (expertiseIndex = 0; expertiseIndex < EXPERTISE_LEVELS.length && level >= EXPERTISE_LEVELS[expertiseIndex + 1]; ++expertiseIndex) {
        }
        boolean skillUpdate = false;
        if (expertiseIndex > 0) {
            for (expertiseIndex = Math.max(expertiseIndex, (int)this.getStat().calc(Stats.ADDITIONAL_EXPERTISE_INDEX)); expertiseIndex >= 1; --expertiseIndex) {
                SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 239, expertiseIndex);
                if (skillEntry == null) continue;
                if (skillEntry.equals(this.addSkill(skillEntry))) break;
                skillUpdate = true;
                break;
            }
        }
        if (Config.EXPERTISE_PENALTY_ENABLED) {
            SkillEntry skillEntry;
            ItemInstance[] items;
            int newWeaponPenalty = 0;
            int newArmorPenalty = 0;
            for (ItemInstance item : items = this.getInventory().getPaperdollItems()) {
                if (item == null) continue;
                int crystaltype = item.getTemplate().getGrade().ordinal();
                if (item.getTemplate().getType2() == 0) {
                    if (crystaltype <= newWeaponPenalty) continue;
                    newWeaponPenalty = crystaltype;
                    continue;
                }
                if (item.getTemplate().getType2() != 1 && item.getTemplate().getType2() != 2 || crystaltype <= expertiseIndex) continue;
                if (item.getBodyPart() == 32768L) {
                    ++newArmorPenalty;
                }
                ++newArmorPenalty;
            }
            newWeaponPenalty -= expertiseIndex;
            if ((newWeaponPenalty = Math.max(0, Math.min(4, newWeaponPenalty))) > 0) {
                skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 6209, newWeaponPenalty);
                if (skillEntry != null && !skillEntry.equals(this.addSkill(skillEntry))) {
                    skillUpdate = true;
                }
            } else if (this.removeSkillById(6209) != null) {
                skillUpdate = true;
            }
            newArmorPenalty = Math.max(0, Math.min(4, newArmorPenalty));
            if (newArmorPenalty > 0) {
                skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 6213, newArmorPenalty);
                if (skillEntry != null && !skillEntry.equals(this.addSkill(skillEntry))) {
                    skillUpdate = true;
                }
            } else if (this.removeSkillById(6213) != null) {
                skillUpdate = true;
            }
        }
        if (skillUpdate) {
            this.getInventory().refreshEquip();
            this.sendSkillList();
            this.sendEtcStatusUpdate();
            this.updateStats(true, false);
        }
    }

    public int getPvpKills() {
        return this._pvpKills;
    }

    public void setPvpKills(int pvpKills) {
        this._pvpKills = pvpKills;
    }

    public ClassLevel getClassLevel() {
        return this.getClassId().getClassLevel();
    }

    public boolean isAcademyGraduated() {
        return this.getVarBoolean(ACADEMY_GRADUATED_VAR, false);
    }

    public synchronized void setClassId(int id, boolean noban) {
        ClassId classId = ClassId.VALUES[id];
        if (classId.isDummy()) {
            return;
        }
        if (!(noban || classId.equalsOrChildOf(this.getClassId()) || this.getPlayerAccess().CanChangeClass || Config.EVERYBODY_HAS_ADMIN_RIGHTS)) {
            Thread.dumpStack();
            return;
        }
        PlayerTemplate template = PlayerTemplateHolder.getInstance().getPlayerTemplate(this.getRace(), classId, this.getSex());
        if (template == null) {
            _log.error("Missing template for classId: " + id);
            return;
        }
        this.setTemplate(template);
        if (!this._subClassList.containsClassId(id)) {
            SubClass cclass = this.getActiveSubClass();
            ClassId oldClass = ClassId.VALUES[cclass.getClassId()];
            this._subClassList.changeSubClassId(oldClass.getId(), id);
            this.changeClassInDb(oldClass.getId(), id);
            this.onReceiveNewClassId(oldClass, classId);
            this.storeCharSubClasses();
            this.getListeners().onClassChange(oldClass, classId);
            for (QuestState qs : this.getAllQuestsStates()) {
                qs.getQuest().notifyTutorialEvent("CE", false, "100", qs);
            }
        } else {
            this.getListeners().onClassChange(null, classId);
        }
        this.broadcastUserInfo(true);
        if (this.isInParty()) {
            this.getParty().broadCast(new PartySmallWindowUpdatePacket(this));
        }
        if (this.getClan() != null) {
            this.getClan().broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(this));
        }
        if (this._matchingRoom != null) {
            this._matchingRoom.broadcastPlayerUpdate(this);
        }
    }

    private void onReceiveNewClassId(ClassId oldClass, ClassId newClass) {
        if (oldClass != null) {
            OlympiadParticipiantData participant;
            if (this.isBaseClassActive() && (participant = Olympiad.getParticipantInfo(this.getObjectId())) != null) {
                participant.setClassId(newClass.getId());
            }
            if (!newClass.equalsOrChildOf(oldClass)) {
                this.removeAllSkills();
                this.restoreSkills();
                this.rewardSkills(false);
                this.checkSkills();
                this.refreshExpertisePenalty();
                this.getInventory().refreshEquip();
                this.getInventory().validateItems();
                this.getHennaList().refreshStats(true);
                this.sendSkillList();
                this.updateStats();
            } else {
                this.rewardSkills(true);
            }
        }
    }

    public long getExp() {
        return this.getActiveSubClass() == null ? 0L : this.getActiveSubClass().getExp();
    }

    public long getMaxExp() {
        return this.getActiveSubClass() == null ? Experience.getExpForLevel(Experience.getMaxLevel() + 1) : this.getActiveSubClass().getMaxExp();
    }

    public void setEnchantScroll(ItemInstance scroll) {
        this._enchantScroll = scroll;
    }

    public ItemInstance getEnchantScroll() {
        return this._enchantScroll;
    }

    public void setAppearanceStone(ItemInstance stone) {
        this._appearanceStone = stone;
    }

    public ItemInstance getAppearanceStone() {
        return this._appearanceStone;
    }

    public void setAppearanceExtractItem(ItemInstance item) {
        this._appearanceExtractItem = item;
    }

    public ItemInstance getAppearanceExtractItem() {
        return this._appearanceExtractItem;
    }

    public void addExpAndCheckBonus(MonsterInstance mob, double noRateExp, double noRateSp) {
        Clan clan;
        if (this.getActiveSubClass() == null) {
            return;
        }
        if (noRateExp > 0.0 && (!this.getVarBoolean("NoExp") || this.getExp() != Experience.getExpForLevel(this.getLevel() + 1) - 1L) && (clan = this.getClan()) != null) {
            int huntingPoints = Math.max((int)(noRateExp * (this.getRateExp() / Config.RATE_XP_BY_LVL[this.getLevel()]) / Math.pow(this.getLevel(), 2.0) * Config.CLAN_HUNTING_PROGRESS_RATE), 1);
            clan.addHuntingProgress(huntingPoints);
        }
        long normalExp = (long)(noRateExp * this.getRateExp() * (mob.isRaid() ? Config.RATE_XP_RAIDBOSS_MODIFIER : 1.0));
        long normalSp = (long)(noRateSp * this.getRateSp() * (mob.isRaid() ? Config.RATE_SP_RAIDBOSS_MODIFIER : 1.0));
        long expWithoutBonus = (long)(noRateExp * Config.RATE_XP_BY_LVL[this.getLevel()]);
        long spWithoutBonus = (long)(noRateSp * Config.RATE_SP_BY_LVL[this.getLevel()]);
        this.addExpAndSp(normalExp, normalSp, normalExp - expWithoutBonus, normalSp - spWithoutBonus, false, true, false, true, true);
    }

    @Override
    public void addExpAndSp(long exp, long sp) {
        this.addExpAndSp(exp, sp, -1L, -1L, false, false, Config.ALT_DELEVEL_ON_DEATH_PENALTY_MIN_LEVEL > -1 && this.getLevel() > Config.ALT_DELEVEL_ON_DEATH_PENALTY_MIN_LEVEL, true, true);
    }

    public void addExpAndSp(long exp, long sp, boolean delevel) {
        this.addExpAndSp(exp, sp, -1L, -1L, false, false, delevel, true, true);
    }

    public void addExpAndSp(long addToExp, long addToSp, long bonusAddExp, long bonusAddSp, boolean applyRate, boolean applyToPet, boolean delevel, boolean clearKarma, boolean sendMsg) {
        int level;
        if (this.getActiveSubClass() == null) {
            return;
        }
        if (addToExp < 0L && this.isFakePlayer()) {
            return;
        }
        if (applyRate) {
            addToExp = (long)((double)addToExp * this.getRateExp());
            addToSp = (long)((double)addToSp * this.getRateSp());
        }
        PetInstance pet = this.getPet();
        if (addToExp > 0L) {
            int karmaLost;
            if (applyToPet && pet != null && !pet.isDead() && !pet.getData().isOfType(PetType.SPECIAL)) {
                if (pet.getData().isOfType(PetType.KARMA)) {
                    pet.addExpAndSp(addToExp, 0L);
                    addToExp = 0L;
                } else if (pet.getExpPenalty() > 0.0) {
                    if (pet.getLevel() > this.getLevel() - 20 && pet.getLevel() < this.getLevel() + 5) {
                        pet.addExpAndSp((long)((double)addToExp * pet.getExpPenalty()), 0L);
                        addToExp = (long)((double)addToExp * (1.0 - pet.getExpPenalty()));
                    } else {
                        pet.addExpAndSp((long)((double)addToExp * pet.getExpPenalty() / 5.0), 0L);
                        addToExp = (long)((double)addToExp * (1.0 - pet.getExpPenalty() / 5.0));
                    }
                } else if (pet.isSummon()) {
                    addToExp = (long)((double)addToExp * (1.0 - pet.getExpPenalty()));
                }
            }
            if (clearKarma && this.isPK() && !this.isInZoneBattle() && (karmaLost = Formulas.calculateKarmaLost(this, addToExp)) > 0) {
                this._karma += karmaLost;
                if (this._karma > 0) {
                    this._karma = 0;
                }
                if (sendMsg) {
                    this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUR_FAME_HAS_BEEN_CHANGED_TO_S1).addInteger(this._karma));
                }
            }
            long max_xp = this.getVarBoolean("NoExp") || this.isInDuel() ? Experience.getExpForLevel(this.getLevel() + 1) - 1L : this.getMaxExp();
            addToExp = Math.min(addToExp, max_xp - this.getExp());
        }
        int oldLvl = this.getActiveSubClass().getLevel();
        this.getActiveSubClass().addExp(addToExp, delevel);
        this.getActiveSubClass().addSp(addToSp);
        if (addToExp > 0L) {
            this.getListeners().onExpReceive(addToExp, bonusAddExp >= 0L);
            this._receivedExp += addToExp;
        }
        if (sendMsg) {
            if ((addToExp > 0L || addToSp > 0L) && bonusAddExp >= 0L && bonusAddSp >= 0L) {
                this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_ACQUIRED_S1_EXP_BONUS_S2_AND_S3_SP_BONUS_S4).addLong(addToExp)).addLong(bonusAddExp)).addInteger(addToSp)).addInteger((int)bonusAddSp));
            } else if (addToSp > 0L && addToExp == 0L) {
                this.sendPacket((IBroadcastPacket)new SystemMessage(331).addNumber(addToSp));
            } else if (addToSp > 0L && addToExp > 0L) {
                this.sendPacket((IBroadcastPacket)new SystemMessage(95).addNumber(addToExp).addNumber(addToSp));
            } else if (addToSp == 0L && addToExp > 0L) {
                this.sendPacket((IBroadcastPacket)new SystemMessage(45).addNumber(addToExp));
            }
        }
        if ((level = this.getActiveSubClass().getLevel()) != oldLvl) {
            this.levelSet(level - oldLvl);
            this.getListeners().onLevelChange(oldLvl, level);
            for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.PLAYER_GLOBAL_LEVEL_UP)) {
                hook.onPlayerGlobalLevelUp(this, oldLvl, level);
            }
        }
        if (pet != null && pet.getData().isOfType(PetType.SPECIAL)) {
            pet.setLevel(this.getLevel());
            pet.setExp(pet.getExpForNextLevel());
            pet.broadcastStatusUpdate();
        }
        this.updateStats();
    }

    public void rewardSkills(boolean send) {
        this.rewardSkills(send, true, Config.AUTO_LEARN_SKILLS, true);
    }

    public int rewardSkills(boolean send, boolean checkShortCuts, boolean learnAllSkills, boolean checkRequiredItems) {
        if (this._dontRewardSkills) {
            return 0;
        }
        ArrayList<SkillLearn> skillLearns = new ArrayList<SkillLearn>(SkillAcquireHolder.getInstance().getAvailableNextLevelsSkills(this, AcquireType.NORMAL));
        Collections.sort(skillLearns);
        Collections.reverse(skillLearns);
        HashIntObjectMap<SkillLearn> skillsToLearnMap = new HashIntObjectMap<SkillLearn>();
        for (SkillLearn sl : skillLearns) {
            if (!sl.isAutoGet() || (!learnAllSkills || checkRequiredItems && sl.haveRequiredItemsForLearn(AcquireType.NORMAL)) && !sl.isFreeAutoGet(AcquireType.NORMAL)) {
                skillsToLearnMap.remove(sl.getId());
                continue;
            }
            if (skillsToLearnMap.containsKey(sl.getId())) continue;
            skillsToLearnMap.put(sl.getId(), sl);
        }
        boolean update = false;
        int addedSkillsCount = 0;
        for (SkillLearn sl : skillsToLearnMap.valueCollection()) {
            SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, sl.getId(), sl.getLevel());
            if (skillEntry == null) continue;
            if (this.addSkill(skillEntry, true) == null) {
                ++addedSkillsCount;
            }
            if (checkShortCuts && this.getAllShortCuts().size() > 0 && skillEntry.getLevel() > 1) {
                this.updateSkillShortcuts(skillEntry.getId(), skillEntry.getLevel());
            }
            update = true;
        }
        if (this.isTransformed()) {
            boolean added = false;
            for (SkillLearn sl : this._transform.getAddtionalSkills()) {
                SkillEntry skillEntry;
                if (sl.getMinLevel() > this.getLevel() || (skillEntry = (SkillEntry)this._transformSkills.get(sl.getId())) != null && skillEntry.getLevel() >= sl.getLevel() || (skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, sl.getId(), sl.getLevel())) == null) continue;
                this._transformSkills.remove(skillEntry.getId());
                this._transformSkills.put(skillEntry.getId(), skillEntry);
                update = true;
                added = true;
            }
            if (added) {
                for (SkillEntry skillEntry : this._transformSkills.valueCollection()) {
                    if (this.addSkill(skillEntry, false) != null) continue;
                    ++addedSkillsCount;
                }
            }
        }
        this.updateStats();
        if (send && update) {
            this.sendSkillList();
        }
        return addedSkillsCount;
    }

    public Race getRace() {
        return ClassId.valueOf(this.getBaseClassId()).getRace();
    }

    public ClassType getBaseClassType() {
        return ClassId.valueOf(this.getBaseClassId()).getType();
    }

    public long getSp() {
        return this.getActiveSubClass() == null ? 0L : this.getActiveSubClass().getSp();
    }

    public void setSp(long sp) {
        if (this.getActiveSubClass() != null) {
            this.getActiveSubClass().setSp(sp);
        }
    }

    public int getClanId() {
        return this._clan == null ? 0 : this._clan.getClanId();
    }

    public long getLeaveClanTime() {
        return this._leaveClanTime;
    }

    public long getDeleteClanTime() {
        return this._deleteClanTime;
    }

    public void setLeaveClanTime(long time) {
        this._leaveClanTime = time;
    }

    public void setDeleteClanTime(long time) {
        this._deleteClanTime = time;
    }

    public void setOnlineTime(long time) {
        this._onlineTime = time;
        this._onlineBeginTime = System.currentTimeMillis();
    }

    public int getOnlineTime() {
        long result = this._onlineTime;
        if (this._onlineBeginTime > 0L) {
            result += System.currentTimeMillis() - this._onlineBeginTime;
        }
        if (this._offlineStartTime > 0L) {
            result -= System.currentTimeMillis() - this._offlineStartTime;
        }
        return (int)(result / 1000L);
    }

    public long getOnlineBeginTime() {
        return this._onlineBeginTime;
    }

    public void setNoChannel(long time) {
        this._NoChannel = time;
        if (this._NoChannel > 2145909600000L || this._NoChannel < 0L) {
            this._NoChannel = -1L;
        }
        this._NoChannelBegin = this._NoChannel > 0L ? System.currentTimeMillis() : 0L;
    }

    public long getNoChannel() {
        return this._NoChannel;
    }

    public long getNoChannelRemained() {
        if (this._NoChannel == 0L) {
            return 0L;
        }
        if (this._NoChannel < 0L) {
            return -1L;
        }
        long remained = this._NoChannel - System.currentTimeMillis() + this._NoChannelBegin;
        if (remained < 0L) {
            return 0L;
        }
        return remained;
    }

    public boolean isChatBlocked() {
        return this.getFlags().getChatBlocked().get();
    }

    public boolean isEscapeBlocked() {
        return this.getFlags().getEscapeBlocked().get();
    }

    public boolean isPartyBlocked() {
        return this.getFlags().getPartyBlocked().get();
    }

    public boolean isVioletBoy() {
        return this.getFlags().getVioletBoy().get();
    }

    public void setLeaveClanCurTime() {
        this._leaveClanTime = System.currentTimeMillis();
    }

    public void setDeleteClanCurTime() {
        this._deleteClanTime = System.currentTimeMillis();
    }

    public boolean canJoinClan() {
        if (this._leaveClanTime == 0L) {
            return true;
        }
        if (System.currentTimeMillis() - this._leaveClanTime >= (long)(Config.ALT_CLAN_LEAVE_PENALTY_TIME * 60 * 60) * 1000L) {
            this._leaveClanTime = 0L;
            return true;
        }
        return false;
    }

    public boolean canCreateClan() {
        if (this._deleteClanTime == 0L) {
            return true;
        }
        if (System.currentTimeMillis() - this._deleteClanTime >= (long)(Config.ALT_CLAN_CREATE_PENALTY_TIME * 60 * 60) * 1000L) {
            this._deleteClanTime = 0L;
            return true;
        }
        return false;
    }

    public IBroadcastPacket canJoinParty(Player inviter) {
        Request request = this.getRequest();
        if (request != null && request.isInProgress() && request.getOtherPlayer(this) != inviter) {
            return SystemMsg.WAITING_FOR_ANOTHER_REPLY.packet(inviter);
        }
        if (this.isBlockAll() || this.getMessageRefusal()) {
            return SystemMsg.THAT_PERSON_IS_IN_MESSAGE_REFUSAL_MODE.packet(inviter);
        }
        if (this.isInParty()) {
            return new SystemMessagePacket(SystemMsg.C1_IS_A_MEMBER_OF_ANOTHER_PARTY_AND_CANNOT_BE_INVITED).addName(this);
        }
        if (this.isPartyBlocked()) {
            return new SystemMessagePacket(SystemMsg.C1_HAS_BEEN_REPORTED_AS_AN_ILLEGAL_PROGRAM_USER_AND_CANNOT_JOIN_A_PARTY).addName(this);
        }
        if (inviter.getReflection() != this.getReflection() && !inviter.getReflection().isMain() && !this.getReflection().isMain()) {
            return SystemMsg.INVALID_TARGET.packet(inviter);
        }
        if (inviter.isInOlympiadMode() || this.isInOlympiadMode()) {
            return SystemMsg.A_USER_CURRENTLY_PARTICIPATING_IN_THE_OLYMPIAD_CANNOT_SEND_PARTY_AND_FRIEND_INVITATIONS.packet(inviter);
        }
        if (!inviter.getPlayerAccess().CanJoinParty || !this.getPlayerAccess().CanJoinParty) {
            return SystemMsg.INVALID_TARGET.packet(inviter);
        }
        for (Event event : this.getEvents()) {
            if (event.canJoinParty(inviter, this)) continue;
            return SystemMsg.INVALID_TARGET.packet(inviter);
        }
        return null;
    }

    @Override
    public PcInventory getInventory() {
        return this._inventory;
    }

    @Override
    public long getWearedMask() {
        return this._inventory.getWearedMask();
    }

    public PcFreight getFreight() {
        return this._freight;
    }

    public void removeItemFromShortCut(int objectId) {
        this._shortCuts.deleteShortCutByObjectId(objectId);
    }

    public void removeSkillFromShortCut(int skillId) {
        this._shortCuts.deleteShortCutBySkillId(skillId);
    }

    @Override
    public boolean isSitting() {
        return this._isSitting;
    }

    public void setSitting(boolean val) {
        this._isSitting = val;
    }

    public boolean getSittingTask() {
        return this.sittingTaskLaunched;
    }

    public ChairInstance getChairObject() {
        return this._chairObject;
    }

    @Override
    public void sitDown(ChairInstance chair) {
        if (this.isSitting() || this.sittingTaskLaunched || this.isAlikeDead()) {
            return;
        }
        if (this.isStunned() || this.isSleeping() || this.isDecontrolled() || this.isAttackingNow() || this.isCastingNow() || this.getMovement().isMoving()) {
            this.getAI().setNextAction(PlayableAI.AINextAction.REST, null, null, false, false);
            return;
        }
        this.resetWaitSitTime();
        this.getAI().setIntention(CtrlIntention.AI_INTENTION_REST, null, null);
        if (chair == null) {
            this.broadcastPacket(new ChangeWaitTypePacket(this, 0));
        } else {
            chair.setSeatedPlayer(this);
            this.broadcastPacket(new ChairSitPacket(this, chair));
        }
        this._chairObject = chair;
        this.setSitting(true);
        this.sittingTaskLaunched = true;
        ThreadPoolManager.getInstance().schedule(new GameObjectTasks.EndSitDownTask(this), 2500L);
    }

    @Override
    public void standUp() {
        if (!this.isSitting() || this.sittingTaskLaunched || this.isInStoreMode() || this.isAlikeDead()) {
            return;
        }
        this.getAbnormalList().stop("Relax");
        this.getAI().clearNextAction();
        this.broadcastPacket(new ChangeWaitTypePacket(this, 1));
        if (this._chairObject != null) {
            this._chairObject.setSeatedPlayer(this);
        }
        this._chairObject = null;
        this.sittingTaskLaunched = true;
        ThreadPoolManager.getInstance().schedule(new GameObjectTasks.EndStandUpTask(this), 2500L);
    }

    public void updateWaitSitTime() {
        if (this._waitTimeWhenSit < 200) {
            this._waitTimeWhenSit += 2;
        }
    }

    public int getWaitSitTime() {
        return this._waitTimeWhenSit;
    }

    public void resetWaitSitTime() {
        this._waitTimeWhenSit = 0;
    }

    public Warehouse getWarehouse() {
        return this._warehouse;
    }

    public ItemContainer getRefund() {
        return this._refund;
    }

    public long getAdena() {
        return this.getInventory().getAdena();
    }

    public boolean reduceAdena(long adena) {
        return this.reduceAdena(adena, false);
    }

    public boolean reduceAdena(long adena, boolean notify) {
        if (adena < 0L) {
            return false;
        }
        if (adena == 0L) {
            return true;
        }
        boolean result = this.getInventory().reduceAdena(adena);
        if (notify && result) {
            this.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(57, adena));
        }
        return result;
    }

    public ItemInstance addAdena(long adena) {
        return this.addAdena(adena, false);
    }

    public ItemInstance addAdena(long adena, boolean notify) {
        if (adena < 1L) {
            return null;
        }
        ItemInstance item = this.getInventory().addAdena(adena);
        if (item != null && notify) {
            this.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(57, adena, 0));
        }
        return item;
    }

    public GameClient getNetConnection() {
        return this._connection;
    }

    public boolean checkFloodProtection(String type, String command) {
        return this._connection == null ? false : this._connection.checkFloodProtection(type, command);
    }

    public int getRevision() {
        return this._connection == null ? 0 : this._connection.getRevision();
    }

    public void setNetConnection(GameClient connection) {
        this._connection = connection;
    }

    public boolean isConnected() {
        return this._connection != null && this._connection.isConnected();
    }

    @Override
    public void onAction(Player player, boolean shift) {
        if (!this.isTargetable(player)) {
            player.sendActionFailed();
            return;
        }
        if (this.isFrozen()) {
            player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
            return;
        }
        if (shift && OnShiftActionHolder.getInstance().callShiftAction(player, Player.class, this, true)) {
            return;
        }
        if (player.getTarget() != this) {
            player.setTarget(this);
            if (player.getTarget() != this) {
                player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
            }
        } else if (this.getPrivateStoreType() != 0) {
            if (!player.checkInteractionDistance(this) && player.getAI().getIntention() != CtrlIntention.AI_INTENTION_INTERACT) {
                if (!shift) {
                    player.getAI().setIntention(CtrlIntention.AI_INTENTION_INTERACT, this, null);
                } else {
                    player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
                }
            } else {
                player.doInteract(this);
            }
        } else if (this.isAutoAttackable(player)) {
            player.getAI().Attack(this, false, shift);
        } else if (player != this) {
            if (player.getAI().getIntention() != CtrlIntention.AI_INTENTION_FOLLOW) {
                if (!shift) {
                    player.getAI().setIntention(CtrlIntention.AI_INTENTION_FOLLOW, this, Config.FOLLOW_RANGE);
                } else {
                    player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
                }
            } else {
                player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
            }
        } else {
            player.sendPacket((IBroadcastPacket)ActionFailPacket.STATIC);
        }
    }

    @Override
    public void broadcastStatusUpdate() {
        if (!this.needStatusUpdate()) {
            return;
        }
        this.broadcastPacket(new StatusUpdate((Creature)this, StatusUpdatePacket.UpdateType.DEFAULT, 9, 10, 11, 12, 33, 34));
        if (this.isInParty()) {
            this.getParty().broadcastToPartyMembers(this, new PartySmallWindowUpdatePacket(this));
        }
        List<SingleMatchEvent> events = this.getEvents(SingleMatchEvent.class);
        for (SingleMatchEvent event : events) {
            event.onStatusUpdate(this);
        }
        if (this.isInOlympiadMode() && this.isOlympiadCompStart() && this._olympiadGame != null) {
            this._olympiadGame.broadcastInfo(this, null, false);
        }
    }

    @Override
    public void broadcastCharInfo() {
        this.broadcastUserInfo(false);
    }

    public void broadcastUserInfo(boolean force) {
        this.sendUserInfo(force);
        if (!this.isVisible()) {
            return;
        }
        if (Config.BROADCAST_CHAR_INFO_INTERVAL == 0L) {
            force = true;
        }
        if (force) {
            if (this._broadcastCharInfoTask != null) {
                this._broadcastCharInfoTask.cancel(false);
                this._broadcastCharInfoTask = null;
            }
            this.broadcastCharInfoImpl(new IUpdateTypeComponent[0]);
            return;
        }
        if (this._broadcastCharInfoTask != null) {
            return;
        }
        this._broadcastCharInfoTask = ThreadPoolManager.getInstance().schedule(new BroadcastCharInfoTask(), Config.BROADCAST_CHAR_INFO_INTERVAL);
    }

    public void setPolyId(int polyid) {
        this._polyNpcId = polyid;
        this.teleToLocation(this.getLoc());
        this.broadcastUserInfo(true);
    }

    public boolean isPolymorphed() {
        return this._polyNpcId != 0;
    }

    public int getPolyId() {
        return this._polyNpcId;
    }

    @Override
    public void broadcastCharInfoImpl(IUpdateTypeComponent ... components) {
        if (!this.isVisible()) {
            return;
        }
        for (Player target : World.getAroundObservers(this)) {
            if (this.isInvisible(target)) continue;
            target.sendPacket((IBroadcastPacket)(this.isPolymorphed() ? new NpcInfoPoly(this, target) : new CIPacket(this, target)));
            target.sendPacket((IBroadcastPacket)new RelationChangedPacket(this, target));
        }
    }

    public void sendEtcStatusUpdate() {
        if (!this.isVisible()) {
            return;
        }
        this.sendPacket((IBroadcastPacket)new EtcStatusUpdatePacket(this));
    }

    private void sendUserInfoImpl() {
        this.sendPacket((IBroadcastPacket)new UIPacket(this));
    }

    public void sendUserInfo() {
        this.sendUserInfo(false);
    }

    public void sendUserInfo(boolean force) {
        if (!this.isVisible() || this.entering || this.isLogoutStarted() || this.isFakePlayer()) {
            return;
        }
        if (Config.USER_INFO_INTERVAL == 0L || force) {
            if (this._userInfoTask != null) {
                this._userInfoTask.cancel(false);
                this._userInfoTask = null;
            }
            this.sendUserInfoImpl();
            return;
        }
        if (this._userInfoTask != null) {
            return;
        }
        this._userInfoTask = ThreadPoolManager.getInstance().schedule(new UserInfoTask(), Config.USER_INFO_INTERVAL);
    }

    public void sendSkillList(int learnedSkillId) {
        this.sendPacket((IBroadcastPacket)new SkillListPacket(this, learnedSkillId));
        this.sendPacket((IBroadcastPacket)new AcquireSkillListPacket(this));
    }

    public void sendSkillList() {
        this.sendSkillList(0);
    }

    public void updateSkillShortcuts(int skillId, int skillLevel) {
        for (ShortCut sc : this.getAllShortCuts()) {
            if (sc.getId() != skillId || sc.getType() != ShortCut.ShortCutType.SKILL) continue;
            ShortCut newsc = new ShortCut(sc.getSlot(), sc.getPage(), sc.getType(), sc.getId(), skillLevel, 1);
            this.sendPacket((IBroadcastPacket)new ShortCutRegisterPacket(this, newsc));
            this.registerShortCut(newsc);
        }
    }

    public void sendStatusUpdate(boolean broadCast, boolean withPet, int ... fields) {
        if (fields.length == 0 || this.entering && !broadCast) {
            return;
        }
        StatusUpdate su = new StatusUpdate((Creature)this, StatusUpdatePacket.UpdateType.DEFAULT, fields);
        ArrayList<IBroadcastPacket> packets = new ArrayList<IBroadcastPacket>(withPet ? 2 : 1);
        if (withPet) {
            for (Servitor servitor : this.getServitors()) {
                packets.add(new StatusUpdate((Creature)servitor, StatusUpdatePacket.UpdateType.DEFAULT, fields));
            }
        }
        packets.add(su);
        if (!broadCast) {
            this.sendPacket(packets);
        } else if (this.entering) {
            this.broadcastPacketToOthers(packets);
        } else {
            this.broadcastPacket(packets);
        }
    }

    public int getAllyId() {
        return this._clan == null ? 0 : this._clan.getAllyId();
    }

    @Override
    public void sendPacket(IBroadcastPacket p) {
        if (p == null) {
            return;
        }
        if (this.isPacketIgnored(p)) {
            return;
        }
        GameClient connection = this.getNetConnection();
        if (connection != null && connection.isConnected()) {
            this._connection.sendPacket(p.packet(this));
        }
    }

    @Override
    public void sendPacket(IBroadcastPacket ... packets) {
        for (IBroadcastPacket p : packets) {
            this.sendPacket(p);
        }
    }

    @Override
    public void sendPacket(List<? extends IBroadcastPacket> packets) {
        if (packets == null) {
            return;
        }
        for (IBroadcastPacket iBroadcastPacket : packets) {
            this.sendPacket(iBroadcastPacket);
        }
    }

    private boolean isPacketIgnored(IBroadcastPacket p) {
        return p == null;
    }

    public void doInteract(GameObject target) {
        if (target == null || this.isActionsDisabled()) {
            this.sendActionFailed();
            return;
        }
        if (target.isPlayer()) {
            if (this.checkInteractionDistance(target)) {
                Player temp = (Player)target;
                if (temp.getPrivateStoreType() == 1 || temp.getPrivateStoreType() == 8) {
                    this.sendPacket((IBroadcastPacket)new PrivateStoreList(this, temp));
                } else if (temp.getPrivateStoreType() == 3) {
                    this.sendPacket((IBroadcastPacket)new PrivateStoreBuyList(this, temp));
                } else if (temp.getPrivateStoreType() == 5) {
                    this.sendPacket((IBroadcastPacket)new RecipeShopSellListPacket(this, temp));
                } else if (temp.getPrivateStoreType() == 20) {
                    OfflineBufferManager.getInstance().processBypass(this, "bufflist_" + temp.getObjectId());
                }
                this.sendActionFailed();
            } else if (this.getAI().getIntention() != CtrlIntention.AI_INTENTION_INTERACT) {
                this.getAI().setIntention(CtrlIntention.AI_INTENTION_INTERACT, this, null);
            }
        } else {
            target.onAction(this, false);
        }
    }

    public void doAutoLootOrDrop(ItemInstance item, NpcInstance fromNpc) {
        boolean forceAutoloot;
        boolean bl = forceAutoloot = fromNpc.isFlying() || this.getReflection().isAutolootForced();
        if (fromNpc.isRaid() && !Config.AUTO_LOOT_FROM_RAIDS && !item.isHerb() && !forceAutoloot) {
            item.dropToTheGround(this, fromNpc);
            return;
        }
        if (item.isHerb()) {
            if (!this.AutoLootHerbs && !forceAutoloot) {
                item.dropToTheGround(this, fromNpc);
                return;
            }
            for (SkillEntry skillEntry : item.getTemplate().getAttachedSkills()) {
                this.altUseSkill(skillEntry, this);
                for (Servitor servitor : this.getServitors()) {
                    if (!servitor.isSummon() || servitor.isDead()) continue;
                    servitor.altUseSkill(skillEntry, servitor);
                }
            }
            item.deleteMe();
            return;
        }
        if (!(forceAutoloot || this._autoLoot && (Config.AUTO_LOOT_ITEM_ID_LIST.isEmpty() || Config.AUTO_LOOT_ITEM_ID_LIST.contains(item.getItemId())) || this._autoLootOnlyAdena && item.getTemplate().isAdena())) {
            item.dropToTheGround(this, fromNpc);
            return;
        }
        if (!this.isInParty()) {
            if (!this.pickupItem(item, "Pickup")) {
                item.dropToTheGround(this, fromNpc);
                return;
            }
        } else {
            this.getParty().distributeItem(this, item, fromNpc);
        }
        this.broadcastPickUpMsg(item);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public void doPickupItem(GameObject object) {
        ItemInstance item;
        if (!object.isItem()) {
            _log.warn("trying to pickup wrong target." + this.getTarget());
            return;
        }
        this.sendActionFailed();
        this.getMovement().stopMove();
        ItemInstance itemInstance = item = (ItemInstance)object;
        synchronized (itemInstance) {
            FlagItemAttachment attachment;
            if (!item.isVisible()) {
                return;
            }
            if (!ItemFunctions.checkIfCanPickup(this, item)) {
                SystemMessage sm;
                if (item.getItemId() == 57) {
                    sm = new SystemMessage(55);
                    sm.addNumber(item.getCount());
                } else {
                    sm = new SystemMessage(56);
                    sm.addItemName(item.getItemId());
                }
                this.sendPacket((IBroadcastPacket)sm);
                return;
            }
            if (item.isHerb()) {
                for (SkillEntry skillEntry : item.getTemplate().getAttachedSkills()) {
                    this.altUseSkill(skillEntry, this);
                }
                this.broadcastPacket(new GetItemPacket(item, this.getObjectId()));
                item.deleteMe();
                return;
            }
            FlagItemAttachment flagItemAttachment = attachment = item.getAttachment() instanceof FlagItemAttachment ? (FlagItemAttachment)item.getAttachment() : null;
            if (!this.isInParty() || attachment != null) {
                if (this.pickupItem(item, "Pickup")) {
                    this.broadcastPacket(new GetItemPacket(item, this.getObjectId()));
                    this.broadcastPickUpMsg(item);
                    item.pickupMe();
                }
            } else {
                this.getParty().distributeItem(this, item, null);
            }
        }
    }

    public boolean pickupItem(ItemInstance item, String log) {
        PickableAttachment attachment;
        PickableAttachment pickableAttachment = attachment = item.getAttachment() instanceof PickableAttachment ? (PickableAttachment)item.getAttachment() : null;
        if (!ItemFunctions.canAddItem(this, item)) {
            return false;
        }
        Log.LogItem(this, log, item);
        this.sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(item));
        this.getInventory().addItem(item);
        if (attachment != null) {
            attachment.pickUp(this);
        }
        this.getListeners().onPickupItem(item);
        this.sendChanges();
        return true;
    }

    @Override
    public void setTarget(GameObject newTarget) {
        GameObject oldTarget;
        if (newTarget != null && !newTarget.isVisible()) {
            newTarget = null;
        }
        if ((oldTarget = this.getTarget()) != null && oldTarget.equals(newTarget)) {
            if (newTarget != null && newTarget.getObjectId() != this.getObjectId()) {
                this.sendPacket((IBroadcastPacket)new ValidateLocationPacket(newTarget));
            }
            return;
        }
        super.setTarget(newTarget);
        if (newTarget != null) {
            if (newTarget.isCreature()) {
                Creature target = (Creature)newTarget;
                if (target.getObjectId() != this.getObjectId()) {
                    this.sendPacket((IBroadcastPacket)new ValidateLocationPacket(target));
                }
                this.sendPacket((IBroadcastPacket)new MyTargetSelectedPacket(this, target));
                if (target.isServitor()) {
                    this.sendPacket((IBroadcastPacket)new StatusUpdate(target, this, StatusUpdatePacket.UpdateType.DEFAULT, 9, 10, 11, 12));
                } else {
                    this.sendPacket((IBroadcastPacket)new StatusUpdate(target, this, StatusUpdatePacket.UpdateType.DEFAULT, 9, 10));
                }
                this.broadcastPacketToOthers(new TargetSelectedPacket(this.getObjectId(), target.getObjectId(), this.getLoc()));
                this.sendPacket((IBroadcastPacket)target.getAbnormalStatusUpdate());
            }
        } else {
            this.broadcastPacket(new TargetUnselectedPacket(this));
        }
        if (newTarget != null && newTarget != this && this.getDecoys() != null && !this.getDecoys().isEmpty() && newTarget.isCreature()) {
            for (DecoyInstance dec : this.getDecoys()) {
                Creature _nt;
                if (dec == null) continue;
                if (dec.getAI() == null) {
                    _log.info("This decoy has NULL AI");
                    continue;
                }
                if (newTarget.isCreature() && (_nt = (Creature)newTarget).isInPeaceZone()) continue;
                dec.getAI().notifyEvent(CtrlEvent.EVT_AGGRESSION, newTarget, 1000);
            }
        }
    }

    @Override
    public ItemInstance getActiveWeaponInstance() {
        return this.getInventory().getPaperdollItem(7);
    }

    @Override
    public WeaponTemplate getActiveWeaponTemplate() {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon == null) {
            return null;
        }
        ItemTemplate template = weapon.getTemplate();
        if (template == null) {
            return null;
        }
        if (!(template instanceof WeaponTemplate)) {
            _log.warn("Template in active weapon not WeaponTemplate! (Item ID[" + weapon.getItemId() + "])");
            return null;
        }
        return (WeaponTemplate)template;
    }

    @Override
    public ItemInstance getSecondaryWeaponInstance() {
        return this.getInventory().getPaperdollItem(8);
    }

    @Override
    public WeaponTemplate getSecondaryWeaponTemplate() {
        ItemInstance weapon = this.getSecondaryWeaponInstance();
        if (weapon == null) {
            return null;
        }
        ItemTemplate item = weapon.getTemplate();
        if (item instanceof WeaponTemplate) {
            return (WeaponTemplate)item;
        }
        return null;
    }

    public ArmorTemplate.ArmorType getWearingArmorType() {
        ItemInstance chest = this.getInventory().getPaperdollItem(10);
        if (chest == null) {
            return ArmorTemplate.ArmorType.NONE;
        }
        ItemType chestItemType = chest.getItemType();
        if (!(chestItemType instanceof ArmorTemplate.ArmorType)) {
            return ArmorTemplate.ArmorType.NONE;
        }
        ArmorTemplate.ArmorType chestArmorType = (ArmorTemplate.ArmorType)chestItemType;
        if (chest.getBodyPart() == 32768L) {
            return chestArmorType;
        }
        ItemInstance legs = this.getInventory().getPaperdollItem(11);
        if (legs == null) {
            return ArmorTemplate.ArmorType.NONE;
        }
        if (legs.getItemType() != chestArmorType) {
            return ArmorTemplate.ArmorType.NONE;
        }
        return chestArmorType;
    }

    @Override
    public void reduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean canReflectAndAbsorb, boolean transferDamage, boolean isDot, boolean sendReceiveMessage, boolean sendGiveMessage, boolean crit, boolean miss, boolean shld) {
        if (attacker == null || this.isDead() || attacker.isDead() && !isDot) {
            return;
        }
        if (attacker.isPlayer() && Math.abs(attacker.getLevel() - this.getLevel()) > 10) {
            if (attacker.isPK() && this.getAbnormalList().contains(5182) && !this.isInSiegeZone()) {
                return;
            }
            if (this.isPK() && attacker.getAbnormalList().contains(5182) && !attacker.isInSiegeZone()) {
                return;
            }
        }
        super.reduceCurrentHp(damage, attacker, skill, awake, standUp, directHp, canReflectAndAbsorb, transferDamage, isDot, sendReceiveMessage, sendGiveMessage, crit, miss, shld);
    }

    @Override
    protected void onReduceCurrentHp(double damage, Creature attacker, Skill skill, boolean awake, boolean standUp, boolean directHp, boolean isDot) {
        if (damage <= 0.0) {
            return;
        }
        if (standUp) {
            this.standUp();
            if (this.isFakeDeath()) {
                this.breakFakeDeath();
            }
        }
        double originDamage = damage;
        if (attacker.isPlayable() && !directHp && this.getCurrentCp() > 0.0) {
            double cp = this.getCurrentCp();
            if (cp >= damage) {
                cp -= damage;
                damage = 0.0;
            } else {
                damage -= cp;
                cp = 0.0;
            }
            this.setCurrentCp(cp, !isDot);
            if (isDot) {
                StatusUpdate su = new StatusUpdate((Creature)this, attacker, StatusUpdatePacket.UpdateType.REGEN, 33);
                attacker.sendPacket((IBroadcastPacket)su);
                this.sendPacket((IBroadcastPacket)su);
                this.broadcastStatusUpdate();
                this.sendChanges();
            }
        }
        double hp = this.getCurrentHp();
        DuelEvent duelEvent = this.getEvent(DuelEvent.class);
        if (duelEvent != null && hp - damage <= 1.0 && !this.isDeathImmune()) {
            this.setCurrentHp(1.0, false);
            duelEvent.onDie(this);
            return;
        }
        if (this.isInOlympiadMode()) {
            OlympiadGame game = this._olympiadGame;
            if (this != attacker && (skill == null || skill.isDebuff())) {
                game.addDamage(this, Math.min(hp, originDamage));
            }
            if (hp - damage <= 1.0 && !this.isDeathImmune()) {
                game.setWinner(this.getOlympiadSide() == 1 ? 2 : 1);
                game.endGame(20000L, false);
                this.setCurrentHp(1.0, false);
                attacker.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                attacker.sendActionFailed();
                return;
            }
        }
        if (this.getStat().calc(Stats.RestoreHPGiveDamage) == 1.0 && Rnd.chance((int)1)) {
            this.setCurrentHp(this.getCurrentHp() + (double)(this.getMaxHp() / 10), false);
        }
        super.onReduceCurrentHp(damage, attacker, skill, awake, standUp, directHp, isDot);
    }

    private void altDeathPenalty(Creature killer) {
        if (!Config.ALT_GAME_DELEVEL) {
            return;
        }
        this.deathPenalty(killer);
    }

    public final boolean atWarWith(Player player) {
        ClanWar war;
        Clan playerClan = this.getClan();
        if (playerClan != null && (war = playerClan.getWarWith(player.getClanId())) != null) {
            return this.getPledgeType() != -1 && player.getPledgeType() != -1;
        }
        return false;
    }

    public boolean atMutualWarWith(Player player) {
        ClanWar war;
        Clan playerClan = this.getClan();
        if (playerClan != null && (war = playerClan.getWarWith(player.getClanId())) != null && war.getPeriod() == ClanWar.ClanWarPeriod.MUTUAL) {
            return this.getPledgeType() != -1 && player.getPledgeType() != -1;
        }
        return false;
    }

    public final void doPurePk(Player killer) {
        int pkCountMulti = (int)Math.max((double)killer.getPkKills() * Config.KARMA_PENALTY_DURATION_INCREASE, 1.0);
        killer.decreaseKarma(Config.KARMA_MIN_KARMA * pkCountMulti);
        killer.setPkKills(killer.getPkKills() + 1);
    }

    public final void doKillInPeace(Player killer) {
        if (!this.isPK()) {
            this.doPurePk(killer);
        } else {
            String var = "@pk_kill_" + this.getObjectId();
            if (!killer.getVarBoolean(var)) {
                long expirationTime = System.currentTimeMillis() + 1800000L;
                killer.setVar(var, true, expirationTime);
            }
        }
    }

    public void checkAddItemToDrop(List<ItemInstance> array, List<ItemInstance> items, int maxCount) {
        for (int i = 0; i < maxCount && !items.isEmpty(); ++i) {
            array.add(items.remove(Rnd.get((int)items.size())));
        }
    }

    public FlagItemAttachment getActiveWeaponFlagAttachment() {
        ItemInstance item = this.getActiveWeaponInstance();
        if (item == null || !(item.getAttachment() instanceof FlagItemAttachment)) {
            return null;
        }
        return (FlagItemAttachment)item.getAttachment();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    protected void doPKPVPManage(Creature killer) {
        boolean isPvP;
        FlagItemAttachment attachment = this.getActiveWeaponFlagAttachment();
        if (attachment != null) {
            attachment.onDeath(this, killer);
        }
        if (killer == null || this.isMyServitor(killer.getObjectId()) || killer == this) {
            return;
        }
        if (killer.isServitor() && (killer = killer.getPlayer()) == null) {
            return;
        }
        if (killer.isPlayer()) {
            PvPRewardManager.tryGiveReward(this, killer.getPlayer());
        }
        if (this.isInZoneBattle() || killer.isInZoneBattle()) {
            return;
        }
        if (killer.getTeam() != TeamType.NONE && this.getTeam() != TeamType.NONE) {
            return;
        }
        ClanWar clanWar = null;
        if (killer.isPlayer() || killer instanceof FakePlayer) {
            Clan clan;
            Player pk = killer.getPlayer();
            boolean war = this.atMutualWarWith(pk);
            if (this.getPledgeType() != -1 && pk.getPledgeType() != -1 && (clan = this.getClan()) != null && (clanWar = clan.getWarWith(pk.getClanId())) != null) {
                clanWar.onKill(pk, this);
            }
            if (this.isInSiegeZone()) {
                return;
            }
            Castle castle = this.getCastle();
            if (this.getPvpFlag() > 0 || war || castle != null && castle.getResidenceSide() == ResidenceSide.DARK) {
                pk.setPvpKills(pk.getPvpKills() + 1);
            } else {
                this.doKillInPeace(pk);
            }
            pk.sendChanges();
        }
        int karma = this._karma;
        if (this.isPK()) {
            this.increaseKarma(Config.KARMA_LOST_BASE);
            if (this._karma > 0) {
                this._karma = 0;
            }
        }
        if (this.isFakePlayer()) {
            return;
        }
        if (!Config.KARMA_DROP_GM && this.isGM()) {
            return;
        }
        boolean bl = isPvP = killer.isPlayable() || killer instanceof GuardInstance;
        if (killer.isMonster()) {
            if (!Config.DROP_ITEMS_ON_DIE || killer.isRaid()) {
                return;
            }
            if (this.isHaveZoneParam("not_lost_items")) {
                return;
            }
            NpcInstance npcKiller = (NpcInstance)killer;
            if (npcKiller.getLeader() != null && npcKiller.getLeader().isRaid()) {
                return;
            }
        } else if (isPvP) {
            if (this._pkKills < Config.MIN_PK_TO_ITEMS_DROP || Config.KARMA_NEEDED_TO_DROP && karma >= 0) {
                return;
            }
        } else {
            return;
        }
        int max_drop_count = isPvP ? Config.KARMA_DROP_ITEM_LIMIT : 1;
        double dropRate = isPvP ? (double)this._pkKills * Config.KARMA_DROPCHANCE_MOD + Config.KARMA_DROPCHANCE_BASE : this.getStat().calc(Stats.ITEMS_LOST_CHANCE, Config.NORMAL_DROPCHANCE_BASE);
        int dropEquipCount = 0;
        int dropWeaponCount = 0;
        int dropItemCount = 0;
        for (int i = 0; (double)i < Math.ceil(dropRate / 100.0) && i < max_drop_count; ++i) {
            if (!Rnd.chance((double)dropRate)) continue;
            int rand = Rnd.get((int)(Config.DROPCHANCE_EQUIPPED_WEAPON + Config.DROPCHANCE_EQUIPMENT + Config.DROPCHANCE_ITEM)) + 1;
            if (rand > Config.DROPCHANCE_EQUIPPED_WEAPON + Config.DROPCHANCE_EQUIPMENT) {
                ++dropItemCount;
                continue;
            }
            if (rand > Config.DROPCHANCE_EQUIPPED_WEAPON) {
                ++dropEquipCount;
                continue;
            }
            ++dropWeaponCount;
        }
        LazyArrayList<ItemInstance> drop = new LazyArrayList<ItemInstance>();
        LazyArrayList<ItemInstance> dropItem = new LazyArrayList<ItemInstance>();
        LazyArrayList<ItemInstance> dropEquip = new LazyArrayList<ItemInstance>();
        LazyArrayList<ItemInstance> dropWeapon = new LazyArrayList<ItemInstance>();
        this.getInventory().writeLock();
        try {
            for (ItemInstance item : this.getInventory().getItems()) {
                if (!item.canBeDropped(this, true) || Config.KARMA_LIST_NONDROPPABLE_ITEMS.contains(item.getItemId())) continue;
                if (item.getTemplate().getType2() == 0) {
                    dropWeapon.add(item);
                    continue;
                }
                if (item.getTemplate().getType2() == 1 || item.getTemplate().getType2() == 2) {
                    dropEquip.add(item);
                    continue;
                }
                if (item.getTemplate().getType2() != 5) continue;
                dropItem.add(item);
            }
            this.checkAddItemToDrop((List<ItemInstance>)drop, (List<ItemInstance>)dropWeapon, dropWeaponCount);
            this.checkAddItemToDrop((List<ItemInstance>)drop, (List<ItemInstance>)dropEquip, dropEquipCount);
            this.checkAddItemToDrop((List<ItemInstance>)drop, (List<ItemInstance>)dropItem, dropItemCount);
            if (drop.isEmpty()) {
                return;
            }
            for (ItemInstance item : drop) {
                if (item.isAugmented() && !Config.ALT_ALLOW_DROP_AUGMENTED) {
                    item.setVariationStoneId(0);
                    item.setVariation1Id(0);
                    item.setVariation2Id(0);
                }
                item = this.getInventory().removeItem(item);
                Log.LogItem(this, isPvP ? "PvPPlayerDieDrop" : "PvEPlayerDieDrop", item);
                if (item.getEnchantLevel() > 0) {
                    this.sendPacket((IBroadcastPacket)new SystemMessage(375).addNumber(item.getEnchantLevel()).addItemName(item.getItemId()));
                } else {
                    this.sendPacket((IBroadcastPacket)new SystemMessage(298).addItemName(item.getItemId()));
                }
                if (killer.isPlayable() && (Config.AUTO_LOOT && Config.AUTO_LOOT_PK || this.isInFlyingTransform())) {
                    killer.getPlayer().getInventory().addItem(item);
                    Log.LogItem(this, "Pickup", item);
                    killer.getPlayer().sendPacket((IBroadcastPacket)SystemMessagePacket.obtainItems(item));
                    continue;
                }
                item.dropToTheGround((Playable)this, Location.findAroundPosition(this, Config.KARMA_RANDOM_DROP_LOCATION_LIMIT));
            }
        }
        finally {
            this.getInventory().writeUnlock();
        }
    }

    @Override
    protected void onDeath(Creature killer) {
        if (this.isInStoreMode()) {
            this.setPrivateStoreType(0);
            this.storePrivateStore();
        }
        if (this.isProcessingRequest()) {
            Request request = this.getRequest();
            if (this.isInTrade()) {
                Player parthner = request.getOtherPlayer(this);
                this.sendPacket((IBroadcastPacket)TradeDonePacket.FAIL);
                parthner.sendPacket((IBroadcastPacket)TradeDonePacket.FAIL);
            }
            request.cancel(new IBroadcastPacket[0]);
        }
        this.deleteAgathion();
        boolean checkPvp = true;
        Player killerPlayer = killer.getPlayer();
        if (killerPlayer != null) {
            for (SingleMatchEvent event : this.getEvents(SingleMatchEvent.class)) {
                if (event.canIncreasePvPPKCounter(killerPlayer, this)) continue;
                checkPvp = false;
                break;
            }
        }
        if (checkPvp) {
            this.doPKPVPManage(killer);
            this.altDeathPenalty(killer);
        }
        this.setIncreasedForce(0);
        this.stopWaterTask();
        if (!this.isSalvation() && this.isInSiegeZone() && this.isCharmOfCourage()) {
            this.ask(new ConfirmDlgPacket(SystemMsg.YOUR_CHARM_OF_COURAGE_IS_TRYING_TO_RESURRECT_YOU, 60000), new ReviveAnswerListener(this, 100.0, false));
            this.setCharmOfCourage(false);
        }
        for (QuestState qs : this.getAllQuestsStates()) {
            qs.getQuest().notifyTutorialEvent("CE", false, "200", qs);
        }
        if (this.isMounted()) {
            this._mount.onDeath();
        }
        for (Servitor servitor : this.getServitors()) {
            servitor.notifyMasterDeath();
        }
        for (ListenerHook hook : this.getListenerHooks(ListenerHookType.PLAYER_DIE)) {
            hook.onPlayerDie(this, killer);
        }
        for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.PLAYER_DIE)) {
            hook.onPlayerDie(this, killer);
        }
        super.onDeath(killer);
    }

    public void restoreExp() {
        this.restoreExp(100.0);
    }

    public void restoreExp(double percent) {
        if (percent == 0.0) {
            return;
        }
        long lostexp = 0L;
        String lostexps = this.getVar("lostexp");
        if (lostexps != null) {
            lostexp = Long.parseLong(lostexps);
            this.unsetVar("lostexp");
        }
        if (lostexp != 0L) {
            this.addExpAndSp((long)((double)lostexp * percent / 100.0), 0L);
        }
    }

    public void deathPenalty(Creature killer) {
        if (killer == null) {
            return;
        }
        if (this.isHaveZoneParam("not_lost_exp")) {
            return;
        }
        boolean atwar = killer.getPlayer() != null && this.atMutualWarWith(killer.getPlayer());
        int level = this.getLevel();
        double percentLost = Config.PERCENT_LOST_ON_DEATH[this.getLevel()];
        if (this.isPK()) {
            percentLost *= Config.PERCENT_LOST_ON_DEATH_MOD_FOR_PK;
        } else if (this.isInPeaceZone()) {
            percentLost *= Config.PERCENT_LOST_ON_DEATH_MOD_IN_PEACE_ZONE;
        } else if (atwar) {
            percentLost *= Config.PERCENT_LOST_ON_DEATH_MOD_IN_WAR;
        } else if (killer.getPlayer() != null && killer.getPlayer() != this) {
            percentLost *= Config.PERCENT_LOST_ON_DEATH_MOD_IN_PVP;
        }
        if (percentLost <= 0.0) {
            return;
        }
        long lostexp = (long)((double)(Experience.getExpForLevel(level + 1) - Experience.getExpForLevel(level)) * percentLost / 100.0);
        lostexp = (long)this.getStat().calc(Stats.EXP_LOST, lostexp, killer, null);
        if (this.isInSiegeZone()) {
            boolean onSiegeEvent = this.containsEvent(SiegeEvent.class);
            if (onSiegeEvent) {
                lostexp = 0L;
            }
            if (onSiegeEvent) {
                Skill skill;
                int syndromeLvl = 0;
                for (Abnormal e : this.getAbnormalList()) {
                    if (e.getSkill().getId() != 5660) continue;
                    syndromeLvl = e.getSkill().getLevel();
                    break;
                }
                if (syndromeLvl == 0) {
                    skill = SkillHolder.getInstance().getSkill(5660, 1);
                    if (skill != null) {
                        skill.getEffects(this, this);
                    }
                } else if (syndromeLvl < 5) {
                    this.getAbnormalList().stop(5660);
                    skill = SkillHolder.getInstance().getSkill(5660, syndromeLvl + 1);
                    skill.getEffects(this, this);
                } else if (syndromeLvl == 5) {
                    this.getAbnormalList().stop(5660);
                    skill = SkillHolder.getInstance().getSkill(5660, 5);
                    skill.getEffects(this, this);
                }
            }
        }
        long before = this.getExp();
        this.addExpAndSp(-lostexp, 0L);
        long lost = before - this.getExp();
        if (lost > 0L) {
            this.setVar("lostexp", lost);
        }
    }

    public void setRequest(Request transaction) {
        this._request = transaction;
    }

    public Request getRequest() {
        return this._request;
    }

    public boolean isBusy() {
        return this.isProcessingRequest() || this.isOutOfControl() || this.isInOlympiadMode() || this.getTeam() != TeamType.NONE || this.isInStoreMode() || this.isInDuel() || this.getMessageRefusal() || this.isBlockAll() || this.isInvisible(null);
    }

    public boolean isProcessingRequest() {
        if (this._request == null) {
            return false;
        }
        return this._request.isInProgress();
    }

    public boolean isInTrade() {
        return this.isProcessingRequest() && this.getRequest().isTypeOf(Request.L2RequestType.TRADE);
    }

    public List<L2GameServerPacket> addVisibleObject(GameObject object, Creature dropper) {
        if (this.isLogoutStarted() || object == null || object.getObjectId() == this.getObjectId() || !object.isVisible() || object.isObservePoint()) {
            return Collections.emptyList();
        }
        return object.addPacketList(this, dropper);
    }

    @Override
    public List<L2GameServerPacket> addPacketList(Player forPlayer, Creature dropper) {
        long animationEndTime;
        SkillEntry castingSkillEntry;
        Creature castingTarget;
        CreatureSkillCast skillCast;
        if (this.isInvisible(forPlayer) && forPlayer.getObjectId() != this.getObjectId()) {
            return Collections.emptyList();
        }
        if (this.isInStoreMode() && forPlayer.getVarBoolean(NO_TRADERS_VAR)) {
            return Collections.emptyList();
        }
        ArrayList<L2GameServerPacket> list = new ArrayList<L2GameServerPacket>();
        if (forPlayer.getObjectId() != this.getObjectId()) {
            list.add(this.isPolymorphed() ? new NpcInfoPoly(this, forPlayer) : new CIPacket(this, forPlayer));
        }
        if (this.isSitting() && this._chairObject != null) {
            list.add(new ChairSitPacket(this, this._chairObject));
        }
        if (this.isInStoreMode()) {
            list.add(this.getPrivateStoreMsgPacket(forPlayer));
        }
        if ((skillCast = this.getSkillCast(SkillCastingType.NORMAL)).isCastingNow()) {
            castingTarget = skillCast.getTarget();
            castingSkillEntry = skillCast.getSkillEntry();
            animationEndTime = skillCast.getAnimationEndTime();
            if (castingSkillEntry != null && !castingSkillEntry.getTemplate().isNotBroadcastable() && castingTarget != null && castingTarget.isCreature() && animationEndTime > 0L) {
                list.add(new MagicSkillUse(this, castingTarget, castingSkillEntry.getId(), castingSkillEntry.getLevel(), (int)(animationEndTime - System.currentTimeMillis()), 0L, SkillCastingType.NORMAL));
            }
        }
        if ((skillCast = this.getSkillCast(SkillCastingType.NORMAL_SECOND)).isCastingNow()) {
            castingTarget = skillCast.getTarget();
            castingSkillEntry = skillCast.getSkillEntry();
            animationEndTime = skillCast.getAnimationEndTime();
            if (castingSkillEntry != null && !castingSkillEntry.getTemplate().isNotBroadcastable() && castingTarget != null && castingTarget.isCreature() && animationEndTime > 0L) {
                list.add(new MagicSkillUse(this, castingTarget, castingSkillEntry.getId(), castingSkillEntry.getLevel(), (int)(animationEndTime - System.currentTimeMillis()), 0L, SkillCastingType.NORMAL_SECOND));
            }
        }
        if (this.isInCombat()) {
            list.add(new AutoAttackStartPacket(this.getObjectId()));
        }
        list.add(new RelationChangedPacket(this, forPlayer));
        if (this.isInBoat()) {
            list.add(this.getBoat().getOnPacket(this, this.getInBoatPosition()));
        } else if (this.getMovement().isMoving() || this.getMovement().isFollow()) {
            list.add(this.movePacket());
        }
        if (this.isInStoreMode() && this.entering) {
            list.add(new CIPacket(this, forPlayer));
        }
        return list;
    }

    public List<L2GameServerPacket> removeVisibleObject(GameObject object, List<L2GameServerPacket> list) {
        List<L2GameServerPacket> result;
        if (this.isLogoutStarted() || object == null || object.getObjectId() == this.getObjectId() || object.isObservePoint()) {
            return Collections.emptyList();
        }
        List<L2GameServerPacket> list2 = result = list == null ? object.deletePacketList(this) : list;
        if (this.getParty() != null && object instanceof Creature) {
            this.getParty().removeTacticalSign((Creature)object);
        }
        if (!this.isInObserverMode()) {
            this.getAI().notifyEvent(CtrlEvent.EVT_FORGET_OBJECT, object);
        }
        return result;
    }

    private void levelSet(int levels) {
        if (levels > 0) {
            int level = this.getLevel();
            this.checkLevelUpReward(false);
            this.sendPacket((IBroadcastPacket)SystemMsg.YOUR_LEVEL_HAS_INCREASED);
            this.broadcastPacket(new SocialActionPacket(this.getObjectId(), 2122));
            this.setCurrentHpMp(this.getMaxHp(), this.getMaxMp());
            this.setCurrentCp(this.getMaxCp());
            for (QuestState qs : this.getAllQuestsStates()) {
                qs.getQuest().notifyTutorialEvent("CE", false, "300", qs);
            }
            this.rewardSkills(false);
            this.notifyNewSkills();
        } else if (levels < 0) {
            this.checkSkills();
        }
        this.sendUserInfo(true);
        this.sendSkillList();
        if (this.isInParty()) {
            this.getParty().recalculatePartyData();
        }
        if (this._clan != null) {
            this._clan.broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(this));
        }
        if (this._matchingRoom != null) {
            this._matchingRoom.broadcastPlayerUpdate(this);
        }
    }

    public boolean notifyNewSkills() {
        Collection<SkillLearn> skills = SkillAcquireHolder.getInstance().getAvailableSkills(this, AcquireType.NORMAL);
        for (SkillLearn s : skills) {
            Skill sk;
            if (s.isFreeAutoGet(AcquireType.NORMAL) || (sk = SkillHolder.getInstance().getSkill(s.getId(), s.getLevel())) == null) continue;
            this.sendPacket((IBroadcastPacket)ExNewSkillToLearnByLevelUp.STATIC);
            return true;
        }
        return false;
    }

    public boolean checkSkills() {
        boolean update = false;
        for (SkillEntry sk : this.getAllSkillsArray()) {
            if (!SkillUtils.checkSkill(this, sk)) continue;
            update = true;
        }
        return update;
    }

    public void startTimers() {
        this.startAutoSaveTask();
        this.startPcBangPointsTask();
        this.startPremiumAccountTask();
        this.getInventory().startTimers();
        this.resumeQuestTimers();
        this.getAttendanceRewards().startTasks();
        this.getProductHistoryList().startTask();
        this.getVIP().startTask();
    }

    public void stopAllTimers() {
        this.deleteAgathion();
        this.stopWaterTask();
        this.stopPremiumAccountTask();
        this.stopHourlyTask();
        this.stopKickTask();
        this.stopPcBangPointsTask();
        this.stopTrainingCampTask();
        this.stopAutoSaveTask();
        this.getInventory().stopTimers();
        this.stopQuestTimers();
        this.stopEnableUserRelationTask();
        this.getHennaList().stopHennaRemoveTask();
        this.getAttendanceRewards().stopTasks();
        this.stopBanEndTasks();
        this.getProductHistoryList().stopTask();
        this.getVIP().stopTask();
        for (ScheduledFuture<?> task : this._tasks) {
            task.cancel(false);
        }
        this._tasks.clear();
    }

    @Override
    public boolean isMyServitor(int objId) {
        if (this._summon != null && this._summon.getObjectId() == objId) {
            return true;
        }
        return this._pet != null && this._pet.getObjectId() == objId;
    }

    public int getServitorsCount() {
        int count = 0;
        if (this._summon != null) {
            ++count;
        }
        if (this._pet != null) {
            ++count;
        }
        return count;
    }

    public boolean hasServitor() {
        return this.getServitorsCount() > 0;
    }

    @Override
    public List<Servitor> getServitors() {
        ArrayList<Servitor> servitors = new ArrayList<Servitor>();
        if (this._summon != null) {
            servitors.add(this._summon);
        }
        if (this._pet != null) {
            servitors.add(this._pet);
        }
        Collections.sort(servitors, Servitor.ServitorComparator.getInstance());
        return servitors;
    }

    public Servitor getAnyServitor() {
        return this.getServitors().stream().findAny().orElse(null);
    }

    public Servitor getFirstServitor() {
        return this.getServitors().stream().findFirst().orElse(null);
    }

    public Servitor getServitor(int objId) {
        if (this._summon != null && this._summon.getObjectId() == objId) {
            return this._summon;
        }
        if (this._pet != null && this._pet.getObjectId() == objId) {
            return this._pet;
        }
        return null;
    }

    public boolean hasSummon() {
        return this._summon != null;
    }

    public SummonInstance getSummon() {
        return this._summon;
    }

    public void setSummon(SummonInstance summon) {
        if (this._summon == summon) {
            return;
        }
        this._summon = summon;
        if (this._summon == null && this._pet == null) {
            this.removeAutoShot(SoulShotType.BEAST_SOULSHOT);
            this.removeAutoShot(SoulShotType.BEAST_SPIRITSHOT);
        }
        this.autoShot();
        if (summon == null) {
            this.getAbnormalList().stop(4140);
        }
    }

    public void deleteServitor(int objId) {
        if (this._summon != null && this._summon.getObjectId() == objId) {
            this.setSummon(null);
        } else if (this._pet != null && this._pet.getObjectId() == objId) {
            this.setPet(null);
        }
    }

    public PetInstance getPet() {
        return this._pet;
    }

    public void setPet(PetInstance pet) {
        boolean petDeleted = this._pet != null;
        this._pet = pet;
        this.unsetVar("pet");
        if (pet == null) {
            if (petDeleted) {
                if (this.isLogoutStarted() && this.getPetControlItem() != null) {
                    this.setVar("pet", this.getPetControlItem().getObjectId());
                }
                this.setPetControlItem(null);
                if (this._summon == null && this._pet == null) {
                    this.removeAutoShot(SoulShotType.BEAST_SOULSHOT);
                    this.removeAutoShot(SoulShotType.BEAST_SPIRITSHOT);
                }
            }
            this.getAbnormalList().stop(4140);
        }
        this.autoShot();
    }

    public void scheduleDelete() {
        long time = 0L;
        if (Config.SERVICES_ENABLE_NO_CARRIER) {
            time = NumberUtils.toInt((String)this.getVar("noCarrier"), (int)Config.SERVICES_NO_CARRIER_DEFAULT_TIME);
        }
        this.scheduleDelete(time * 1000L);
    }

    public void scheduleDelete(long time) {
        if (this.isLogoutStarted() || this.isInOfflineMode()) {
            return;
        }
        this.broadcastCharInfo();
        ThreadPoolManager.getInstance().schedule(() -> {
            if (!this.isConnected()) {
                this.prepareToLogout1();
                this.prepareToLogout2();
                this.deleteMe();
            }
        }, time);
    }

    @Override
    protected void onDelete() {
        this.deleteCubics();
        super.onDelete();
        if (this._observePoint != null) {
            this._observePoint.deleteMe();
        }
        this._friendList.notifyFriends(false);
        this.getBookMarkList().clear();
        this._inventory.clear();
        this._warehouse.clear();
        this._summon = null;
        this._pet = null;
        this._arrowItem = null;
        this._fistsWeaponItem = null;
        this._chars = null;
        this._enchantScroll = null;
        this._appearanceStone = null;
        this._appearanceExtractItem = null;
        this._lastNpc = HardReferences.emptyRef();
        this._observePoint = null;
    }

    public void setTradeList(List<TradeItem> list) {
        this._tradeList = list;
    }

    public List<TradeItem> getTradeList() {
        return this._tradeList;
    }

    public String getSellStoreName() {
        return this._sellStoreName;
    }

    public void setSellStoreName(String name) {
        this._sellStoreName = Strings.stripToSingleLine(name);
    }

    public String getPackageSellStoreName() {
        return this._packageSellStoreName;
    }

    public void setPackageSellStoreName(String name) {
        this._packageSellStoreName = Strings.stripToSingleLine(name);
    }

    public void setSellList(boolean packageSell, Map<Integer, TradeItem> list) {
        if (packageSell) {
            this._packageSellList = list;
        } else {
            this._sellList = list;
        }
    }

    public Map<Integer, TradeItem> getSellList() {
        return this.getSellList(this._privatestore == 8);
    }

    public Map<Integer, TradeItem> getSellList(boolean packageSell) {
        return packageSell ? this._packageSellList : this._sellList;
    }

    public String getBuyStoreName() {
        return this._buyStoreName;
    }

    public void setBuyStoreName(String name) {
        this._buyStoreName = Strings.stripToSingleLine(name);
    }

    public void setBuyList(List<TradeItem> list) {
        this._buyList = list;
    }

    public List<TradeItem> getBuyList() {
        return this._buyList;
    }

    public void setManufactureName(String name) {
        this._manufactureName = Strings.stripToSingleLine(name);
    }

    public String getManufactureName() {
        return this._manufactureName;
    }

    public Map<Integer, ManufactureItem> getCreateList() {
        return this._createList;
    }

    public void setCreateList(Map<Integer, ManufactureItem> list) {
        this._createList = list;
    }

    public void setPrivateStoreType(int type) {
        this._privatestore = type;
    }

    public boolean isInStoreMode() {
        return this._privatestore != 0;
    }

    public boolean isInBuffStore() {
        return this._privatestore == 20;
    }

    public int getPrivateStoreType() {
        return this._privatestore;
    }

    public L2GameServerPacket getPrivateStoreMsgPacket(Player forPlayer) {
        switch (this.getPrivateStoreType()) {
            case 3: {
                return new PrivateStoreBuyMsg(this, this.canTalkWith(forPlayer));
            }
            case 1: {
                return new PrivateStoreMsg(this, this.canTalkWith(forPlayer));
            }
            case 8: {
                return new ExPrivateStoreWholeMsg(this, this.canTalkWith(forPlayer));
            }
            case 5: {
                return new RecipeShopMsgPacket(this, this.canTalkWith(forPlayer));
            }
        }
        return null;
    }

    public void broadcastPrivateStoreInfo() {
        if (!this.isVisible() || this._privatestore == 0) {
            return;
        }
        this.sendPacket((IBroadcastPacket)this.getPrivateStoreMsgPacket(this));
        for (Player target : World.getAroundObservers(this)) {
            target.sendPacket((IBroadcastPacket)this.getPrivateStoreMsgPacket(target));
        }
    }

    public void setClan(Clan clan) {
        Clan oldClan;
        if (this._clan != clan && this._clan != null) {
            this.unsetVar("canWhWithdraw");
        }
        if ((oldClan = this._clan) != null && clan == null) {
            for (SkillEntry skillEntry : oldClan.getSkills()) {
                this.removeSkill(skillEntry, false);
            }
        }
        this._clan = clan;
        if (clan == null) {
            this._pledgeType = -128;
            this._pledgeRank = PledgeRank.VAGABOND;
            this._powerGrade = 0;
            this._apprentice = 0;
            this._lvlJoinedAcademy = 0;
            this.getInventory().validateItems();
            return;
        }
        if (!clan.isAnyMember(this.getObjectId())) {
            this.setClan(null);
            this.setTitle("");
        }
    }

    @Override
    public Clan getClan() {
        return this._clan;
    }

    public SubUnit getSubUnit() {
        return this._clan == null ? null : this._clan.getSubUnit(this._pledgeType);
    }

    public ClanHall getClanHall() {
        int id = this._clan != null ? this._clan.getHasHideout() : 0;
        return ResidenceHolder.getInstance().getResidence(ClanHall.class, id);
    }

    public Castle getCastle() {
        int id = this._clan != null ? this._clan.getCastle() : 0;
        return ResidenceHolder.getInstance().getResidence(Castle.class, id);
    }

    public Alliance getAlliance() {
        return this._clan == null ? null : this._clan.getAlliance();
    }

    public boolean isClanLeader() {
        return this._clan != null && this.getObjectId() == this._clan.getLeaderId();
    }

    public boolean isAllyLeader() {
        return this.getAlliance() != null && this.getAlliance().getLeader().getLeaderId() == this.getObjectId();
    }

    @Override
    public void reduceArrowCount() {
        if (this._arrowItem != null && this._arrowItem.getTemplate().isQuiver()) {
            return;
        }
        this.sendPacket((IBroadcastPacket)SystemMsg.YOU_CAREFULLY_NOCK_AN_ARROW);
        if (!this.getInventory().destroyItemByObjectId(this.getInventory().getPaperdollObjectId(8), 1L)) {
            this.getInventory().setPaperdollItem(8, null);
            this._arrowItem = null;
        }
    }

    public boolean checkAndEquipArrows() {
        if (this.getInventory().getPaperdollItem(8) == null) {
            ItemInstance activeWeapon = this.getActiveWeaponInstance();
            if (activeWeapon != null) {
                if (activeWeapon.getItemType() == WeaponTemplate.WeaponType.BOW) {
                    this._arrowItem = this.getInventory().findArrowForBow(activeWeapon.getTemplate());
                } else if (activeWeapon.getItemType() == WeaponTemplate.WeaponType.CROSSBOW || activeWeapon.getItemType() == WeaponTemplate.WeaponType.TWOHANDCROSSBOW) {
                    this._arrowItem = this.getInventory().findArrowForCrossbow(activeWeapon.getTemplate());
                }
            }
            if (this._arrowItem != null) {
                this.getInventory().setPaperdollItem(8, this._arrowItem);
            }
        } else {
            this._arrowItem = this.getInventory().getPaperdollItem(8);
        }
        return this._arrowItem != null;
    }

    public void setUptime(long time) {
        this._uptime = time;
    }

    public long getUptime() {
        return System.currentTimeMillis() - this._uptime;
    }

    public boolean isInParty() {
        return this._party != null;
    }

    public void setParty(Party party) {
        this._party = party;
    }

    public void joinParty(Party party, boolean force) {
        if (party != null) {
            party.addPartyMember(this, force);
        }
    }

    public void leaveParty(boolean force) {
        if (this.isInParty()) {
            this._party.removePartyMember(this, false, force);
        }
    }

    public Party getParty() {
        return this._party;
    }

    public void setLastPartyPosition(Location loc) {
        this._lastPartyPosition = loc;
    }

    public Location getLastPartyPosition() {
        return this._lastPartyPosition;
    }

    public boolean isGM() {
        return this._playerAccess == null ? false : this._playerAccess.IsGM;
    }

    public void setAccessLevel(int level) {
        this._accessLevel = level;
    }

    @Override
    public int getAccessLevel() {
        return this._accessLevel;
    }

    public void setPlayerAccess(PlayerAccess pa) {
        this._playerAccess = pa != null ? pa : new PlayerAccess();
        this.setAccessLevel(this.isGM() || this._playerAccess.Menu ? 100 : 0);
    }

    public PlayerAccess getPlayerAccess() {
        return this._playerAccess;
    }

    public void updateStats(boolean refreshOverloaded, boolean refreshExpertisePenalty) {
        if (this.entering || this.isLogoutStarted()) {
            return;
        }
        if (refreshOverloaded) {
            this.refreshOverloaded();
        }
        if (refreshExpertisePenalty) {
            this.refreshExpertisePenalty();
        }
        super.updateStats();
        for (Servitor servitor : this.getServitors()) {
            servitor.updateStats();
        }
    }

    @Override
    public void updateStats() {
        this.updateStats(true, true);
    }

    @Override
    public void sendChanges() {
        if (this.entering || this.isLogoutStarted()) {
            return;
        }
        super.sendChanges();
    }

    public void updateKarma(boolean flagChanged) {
        this.sendStatusUpdate(true, true, 27);
        if (flagChanged) {
            this.broadcastRelation();
        }
    }

    public boolean isOnline() {
        return this._isOnline;
    }

    public void setIsOnline(boolean isOnline) {
        this._isOnline = isOnline;
    }

    public void setOnlineStatus(boolean isOnline) {
        this._isOnline = isOnline;
        this.updateOnlineStatus();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void updateOnlineStatus() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET online=?, lastAccess=? WHERE obj_id=?");
            statement.setInt(1, this.isOnline() && !this.isInOfflineMode() ? 1 : 0);
            statement.setInt(2, (int)(System.currentTimeMillis() / 1000L));
            statement.setInt(3, this.getObjectId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void storeLastIpAndHWID(String ip, String hwid) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            if (StringUtils.isEmpty((CharSequence)hwid)) {
                statement = con.prepareStatement("UPDATE characters SET last_ip=? WHERE obj_Id=? LIMIT 1");
                statement.setString(1, ip);
                statement.setInt(2, this.getObjectId());
            } else {
                statement = con.prepareStatement("UPDATE characters SET last_ip=?, last_hwid=? WHERE obj_Id=? LIMIT 1");
                statement.setString(1, ip);
                statement.setString(2, hwid);
                statement.setInt(3, this.getObjectId());
            }
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("Could not store " + this.toString() + " IP and HWID: ", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public void decreaseKarma(long val) {
        boolean flagChanged = this._karma >= 0;
        long new_karma = (long)this._karma - val;
        if (new_karma < Integer.MIN_VALUE) {
            new_karma = Integer.MIN_VALUE;
        }
        if (this._karma >= 0 && new_karma < 0L && this._pvpFlag > 0) {
            this._pvpFlag = 0;
            if (this._PvPRegTask != null) {
                this._PvPRegTask.cancel(true);
                this._PvPRegTask = null;
            }
            this.sendStatusUpdate(true, true, 26);
        }
        this.setKarma((int)new_karma);
        this.updateKarma(flagChanged);
    }

    public void increaseKarma(int val) {
        boolean flagChanged = this._karma < 0;
        long new_karma = this._karma + val;
        if (new_karma > Integer.MAX_VALUE) {
            new_karma = Integer.MAX_VALUE;
        }
        this.setKarma((int)new_karma);
        if (this._karma > 0) {
            this.updateKarma(flagChanged);
        } else {
            this.updateKarma(false);
        }
    }

    public static Player create(int classId, int sex, String accountName, String name, int hairStyle, int hairColor, int face) {
        if (classId < 0 || classId >= ClassId.VALUES.length) {
            return null;
        }
        ClassId classID = ClassId.VALUES[classId];
        if (classID.isDummy() || !classID.isOfLevel(ClassLevel.NONE)) {
            return null;
        }
        PlayerTemplate template = PlayerTemplateHolder.getInstance().getPlayerTemplate(classID.getRace(), classID, Sex.VALUES[sex]);
        Player player = new Player(IdFactory.getInstance().getNextId(), template, accountName);
        player.setName(name);
        player.setTitle("");
        player.setHairStyle(hairStyle);
        player.setHairColor(hairColor);
        player.setFace(face);
        player.setCreateTime(System.currentTimeMillis());
        if (Config.PC_BANG_POINTS_BY_ACCOUNT) {
            player.setPcBangPoints(Integer.parseInt(AccountVariablesDAO.getInstance().select(player.getAccountName(), PC_BANG_POINTS_VAR, "0")), false);
        }
        if (!CharacterDAO.getInstance().insert(player)) {
            return null;
        }
        int level = Config.STARTING_LVL;
        double hp = classID.getBaseHp(level);
        double mp = classID.getBaseMp(level);
        double cp = classID.getBaseCp(level);
        long exp = Experience.getExpForLevel(level);
        long sp = Config.STARTING_SP;
        boolean active = true;
        SubClassType type = SubClassType.BASE_CLASS;
        if (!CharacterSubclassDAO.getInstance().insert(player.getObjectId(), classId, exp, sp, hp, mp, cp, hp, mp, cp, level, active, type)) {
            return null;
        }
        return player;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     * Unable to fully structure code
     */
    public static Player restore(int objectId, boolean fake) {
        Player player = null;
        Connection con = null;
        Statement statement = null;
        Statement statement2 = null;
        PreparedStatement statement3 = null;
        ResultSet rset = null;
        ResultSet rset2 = null;
        ResultSet rset3 = null;
        if (GameObjectsStorage.getPlayers(false, false).size() >= GameServer.getInstance().getOnlineLimit()) {
            Player._log.warn("Player:restore: Impossible to restore character. Exceeded the number of online players!");
            return null;
        }
        try {
                        con = DatabaseFactory.getInstance().getConnection();
                        statement = con.createStatement();
                        statement2 = con.createStatement();
                        rset = statement.executeQuery("SELECT * FROM `characters` WHERE `obj_Id`=" + objectId + " LIMIT 1");
                        rset2 = statement2.executeQuery("SELECT `class_id` FROM `character_subclasses` WHERE `char_obj_id`=" + objectId + " AND `type`=" + SubClassType.BASE_CLASS.ordinal() + " LIMIT 1");
                        if (!rset.next() || !rset2.next()) {
                            return player;
                        }
                        ClassId classId = ClassId.VALUES[rset2.getInt("class_id")];
                        PlayerTemplate template = PlayerTemplateHolder.getInstance().getPlayerTemplate(classId.getRace(), classId, Sex.VALUES[rset.getInt("sex")]);
                        if (fake) {
                            FakePlayerAITemplate fakeAiTemplate = FakePlayersHolder.getInstance().getAITemplate(classId.getRace(), classId.getType());
                            if (fakeAiTemplate == null) {
                                Player._log.warn("Player: Not found fake player AI template for class ID[" + classId.getId() + "] (default class ID[" + classId.getId() + "])!");
                                return null;
                            }
                            player = new Player(fakeAiTemplate, objectId, template);
                        } else {
                            player = new Player(objectId, template);
                        }
                if (!player.getSubClassList().restore()) {
                    Player._log.warn("Player:restore: Could not restore character due to a failure when restoring sub-classes!");
                    return null;
                }
                player.restoreVariables();
                player.loadInstanceReuses();
                player.getBookMarkList().setCapacity(rset.getInt("bookmarks"));
                player.getBookMarkList().restore();
                player.setBotRating(rset.getInt("bot_rating"));
                player.getFriendList().restore();
                player.getBlockList().restore();
                player.getProductHistoryList().restore();
                player.setPostFriends(CharacterPostFriendDAO.getInstance().select(player));
                CharacterGroupReuseDAO.getInstance().select(player);
                player.setLogin(rset.getString("account_name"));
                player.setName(rset.getString("char_name"));
                player.setFace(rset.getInt("face"));
                player.setBeautyFace(rset.getInt("beautyFace"));
                player.setHairStyle(rset.getInt("hairStyle"));
                player.setBeautyHairStyle(rset.getInt("beautyHairStyle"));
                player.setHairColor(rset.getInt("hairColor"));
                player.setBeautyHairColor(rset.getInt("beautyHairColor"));
                player.setHeading(0);
                player.setKarma(rset.getInt("karma"));
                player.setPvpKills(rset.getInt("pvpkills"));
                player.setPkKills(rset.getInt("pkkills"));
                player.setLeaveClanTime(rset.getLong("leaveclan") * 1000L);
                if (player.getLeaveClanTime() > 0L && player.canJoinClan()) {
                    player.setLeaveClanTime(0L);
                }
                player.setDeleteClanTime(rset.getLong("deleteclan") * 1000L);
                if (player.getDeleteClanTime() > 0L && player.canCreateClan()) {
                    player.setDeleteClanTime(0L);
                }
                player.setNoChannel(rset.getLong("nochannel") * 1000L);
                if (player.getNoChannel() > 0L && player.getNoChannelRemained() < 0L) {
                    player.setNoChannel(0L);
                }
                player.setOnlineTime(rset.getLong("onlinetime") * 1000L);
                int clanId = rset.getInt("clanid");
                if (clanId > 0) {
                    player.setClan(ClanTable.getInstance().getClan(clanId));
                    player.setPledgeType(rset.getInt("pledge_type"));
                    player.setPowerGrade(rset.getInt("pledge_rank"));
                    player.setLvlJoinedAcademy(rset.getInt("lvl_joined_academy"));
                    player.setApprentice(rset.getInt("apprentice"));
                }
                player.setCreateTime(rset.getLong("createtime") * 1000L);
                player.setDeleteTimer(rset.getInt("deletetime"));
                player.setTitle(rset.getString("title"));
                if (player.getVar("titlecolor") != null) {
                    player.setTitleColor(Integer.decode("0x" + player.getVar("titlecolor")));
                }
                if (player.getVar("namecolor") == null) {
                    if (player.isGM()) {
                        player.setNameColor(Config.GM_NAME_COLOUR);
                    } else if (player.getClan() != null && player.getClan().getLeaderId() == player.getObjectId()) {
                        player.setNameColor(Config.CLANLEADER_NAME_COLOUR);
                    } else {
                        player.setNameColor(Config.NORMAL_NAME_COLOUR);
                    }
                } else {
                    player.setNameColor(Integer.decode("0x" + player.getVar("namecolor")));
                }
                if (Config.AUTO_LOOT_INDIVIDUAL) {
                    player._autoLoot = player.getVarBoolean("AutoLoot", Config.AUTO_LOOT);
                    player._autoLootOnlyAdena = player.getVarBoolean("AutoLootOnlyAdena", Config.AUTO_LOOT);
                    player.AutoLootHerbs = player.getVarBoolean("AutoLootHerbs", Config.AUTO_LOOT_HERBS);
                }
                player.setUptime(System.currentTimeMillis());
                player.setLastAccess(rset.getInt("lastAccess"));
                player.setRecomHave(rset.getInt("rec_have"));
                player.setRecomLeft(rset.getInt("rec_left"));
                if (!Config.USE_CLIENT_LANG && Config.CAN_SELECT_LANGUAGE) {
                    player.setLanguage(player.getVar("lang@"));
                }
                player.setKeyBindings(rset.getBytes("key_bindings"));
                if (Config.PC_BANG_POINTS_BY_ACCOUNT) {
                    player.setPcBangPoints(Integer.parseInt(AccountVariablesDAO.getInstance().select(player.getAccountName(), "pc_bang_poins", "0")), false);
                } else {
                    player.setPcBangPoints(rset.getInt("pcBangPoints"), false);
                }
                player.setFame(rset.getInt("fame"), null, false);
                player.setUsedWorldChatPoints(rset.getInt("used_world_chat_points"));
                player.setHideHeadAccessories(rset.getInt("hide_head_accessories") > 0);
                player.restoreRecipeBook();
                if (Config.ENABLE_OLYMPIAD) {
                    player.setHero(Hero.getInstance().isHero(player.getObjectId()));
                }
                if (!player.isHero()) {
                    player.setHero(CustomHeroDAO.getInstance().isCustomHero(player.getObjectId()));
                }
                player.updatePledgeRank();
                player.setXYZ(rset.getInt("x"), rset.getInt("y"), rset.getInt("z"));
                int reflection = 0;
                long jailExpireTime = player.getVarExpireTime("jailed");
                if (jailExpireTime > System.currentTimeMillis()) {
                    reflection = ReflectionManager.JAIL.getId();
                    if (!player.isInZone("[gm_prison]")) {
                        player.setLoc(Location.findPointToStay(player, AdminFunctions.JAIL_SPAWN, 50, 200));
                    }
                    player.setIsInJail(true);
                    player.startUnjailTask(player, (int)(jailExpireTime - System.currentTimeMillis() / 60000L));
                } else {
                    String ref = player.getVar("reflection");
                    if (ref != null && (reflection = Integer.parseInt(ref)) != ReflectionManager.PARNASSUS.getId() && reflection != ReflectionManager.GIRAN_HARBOR.getId()) {
                        String back = player.getVar("backCoords");
                        if (back != null) {
                            player.setLoc(Location.parseLoc(back));
                            player.unsetVar("backCoords");
                        } else {
                            player.setLoc(Player.STABLE_LOCATION);
                        }
                        reflection = 0;
                        player.unsetVar("reflection");
                    }
                }
                player.setReflection(reflection);
                EventHolder.getInstance().findEvent(player);
                Quest.restoreQuestStates(player);
                player.getInventory().restore();
                player.setActiveSubClass(player.getActiveClassId(), false, true);
                player.getVIP().restore();
                player.getProductHistoryList().restore();
                player.getAttendanceRewards().restore();
                player.restoreSummons();
                try {
                    String var = player.getVar("ExpandInventory");
                    if (var != null) {
                        player.setExpandInventory(Integer.parseInt(var));
                    }
                }
                catch (Exception e) {
                    Player._log.error("", (Throwable)e);
                }
                try {
                    String var2 = player.getVar("ExpandWarehouse");
                    if (var2 != null) {
                        player.setExpandWarehouse(Integer.parseInt(var2));
                    }
                }
                catch (Exception e) {
                    Player._log.error("", (Throwable)e);
                }
                try {
                    String var3 = player.getVar("notShowBuffAnim");
                    if (var3 != null) {
                        player.setNotShowBuffAnim(Boolean.parseBoolean(var3));
                    }
                }
                catch (Exception e) {
                    Player._log.error("", (Throwable)e);
                }
                try {
                    String var4 = player.getVar("notraders");
                    if (var4 != null) {
                        player.setNotShowTraders(Boolean.parseBoolean(var4));
                    }
                }
                catch (Exception e) {
                    Player._log.error("", (Throwable)e);
                }
                try {
                    String var5 = player.getVar("pet");
                    if (var5 != null) {
                        player.setPetControlItem(Integer.parseInt(var5));
                    }
                }
                catch (Exception e) {
                    Player._log.error("", (Throwable)e);
                }
                statement3 = con.prepareStatement("SELECT obj_Id, char_name FROM characters WHERE account_name=? AND obj_Id!=?");
                statement3.setString(1, player._login);
                statement3.setInt(2, objectId);
                rset3 = statement3.executeQuery();
                while (rset3.next()) {
                    int charId = rset3.getInt("obj_Id");
                    String charName = rset3.getString("char_name");
                    player._chars.put(charId, charName);
                }
                DbUtils.close((Statement)statement3, (ResultSet)rset3);
                LazyArrayList<Zone> zones = LazyArrayList.newInstance();
                World.getZones((Collection<Zone>)zones, player.getLoc(), player.getReflection());
                if (!zones.isEmpty()) {
                    for (Zone zone : zones) {
                        if (zone.getType() == Zone.ZoneType.no_restart) {
                            if (System.currentTimeMillis() / 1000L - player.getLastAccess() <= zone.getRestartTime()) continue;
                            player.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.EnterWorld.TeleportedReasonNoRestart"));
                            player.setLoc(TeleportUtils.getRestartPoint(player, RestartType.TO_VILLAGE).getLoc());
                            continue;
                        }
                        if (zone.getType() != Zone.ZoneType.SIEGE) continue;
                        SiegeEvent currentSiegeEvent = null;
                        for (SiegeEvent siegeEvent : player.getEvents(SiegeEvent.class)) {
                            if (!zone.containsEvent(siegeEvent)) continue;
                            currentSiegeEvent = siegeEvent;
                            break;
                        }
                        if (currentSiegeEvent != null) {
                            player.setLoc(currentSiegeEvent.getEnterLoc(player, zone));
                            continue;
                        }
                        Residence r = ResidenceHolder.getInstance().getResidence(zone.getParams().getInteger("residence"));
                        player.setLoc(r.getNotOwnerRestartPoint(player));
                    }
                }
                LazyArrayList.recycle((LazyArrayList)zones);
                player.getMacroses().restore();
                player.refreshExpertisePenalty();
                player.refreshOverloaded();
                player.getWarehouse().restore();
                player.getFreight().restore();
                player.restorePrivateStore();
                player.updateKetraVarka();
                player.updateRam();
                player.checkDailyCounters();
                player.checkWeeklyCounters();
                GameObjectsStorage.put(player);
            }
            catch (Exception e) {
                Player._log.error("Player:restore: Could not restore char data!", (Throwable)e);
            }
            finally {
                DbUtils.closeQuietly(statement2, rset2);
                DbUtils.closeQuietly(statement3, rset3);
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        return player;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void store(boolean fast) {
        block12: {
            if (!this._storeLock.tryLock()) {
                return;
            }
            try {
                PreparedStatement statement;
                Connection con;
                block11: {
                    con = null;
                    statement = null;
                    try {
                        con = DatabaseFactory.getInstance().getConnection();
                        statement = con.prepareStatement("UPDATE characters SET face=?,beautyFace=?,hairStyle=?,beautyHairStyle=?,hairColor=?,beautyHairColor=?,sex=?,x=?,y=?,z=?,karma=?,pvpkills=?,pkkills=?,rec_have=?,rec_left=?,clanid=?,deletetime=?,title=?,accesslevel=?,online=?,leaveclan=?,deleteclan=?,nochannel=?,onlinetime=?,pledge_type=?,pledge_rank=?,lvl_joined_academy=?,apprentice=?,key_bindings=?,pcBangPoints=?,char_name=?,fame=?,bookmarks=?,bot_rating=?,used_world_chat_points=?,hide_head_accessories=? WHERE obj_Id=? LIMIT 1");
                        statement.setInt(1, this.getFace());
                        statement.setInt(2, this.getBeautyFace());
                        statement.setInt(3, this.getHairStyle());
                        statement.setInt(4, this.getBeautyHairStyle());
                        statement.setInt(5, this.getHairColor());
                        statement.setInt(6, this.getBeautyHairColor());
                        statement.setInt(7, this.getSex().ordinal());
                        if (this._stablePoint == null) {
                            statement.setInt(8, this.getX());
                            statement.setInt(9, this.getY());
                            statement.setInt(10, this.getZ());
                        } else {
                            statement.setInt(8, this._stablePoint.x);
                            statement.setInt(9, this._stablePoint.y);
                            statement.setInt(10, this._stablePoint.z);
                        }
                        statement.setInt(11, this.getKarma());
                        statement.setInt(12, this.getPvpKills());
                        statement.setInt(13, this.getPkKills());
                        statement.setInt(14, this.getRecomHave());
                        statement.setInt(15, this.getRecomLeft());
                        statement.setInt(16, this.getClanId());
                        statement.setInt(17, this.getDeleteTimer());
                        statement.setString(18, this._title);
                        statement.setInt(19, this._accessLevel);
                        statement.setInt(20, this.isOnline() && !this.isInOfflineMode() ? 1 : 0);
                        statement.setLong(21, this.getLeaveClanTime() / 1000L);
                        statement.setLong(22, this.getDeleteClanTime() / 1000L);
                        statement.setLong(23, this._NoChannel > 0L ? this.getNoChannelRemained() / 1000L : this._NoChannel);
                        statement.setInt(24, this.getOnlineTime());
                        statement.setInt(25, this.getPledgeType());
                        statement.setInt(26, this.getPowerGrade());
                        statement.setInt(27, this.getLvlJoinedAcademy());
                        statement.setInt(28, this.getApprentice());
                        statement.setBytes(29, this.getKeyBindings());
                        statement.setInt(30, Config.PC_BANG_POINTS_BY_ACCOUNT ? 0 : this.getPcBangPoints());
                        statement.setString(31, this.getName());
                        statement.setInt(32, this.getFame());
                        statement.setInt(33, this.getBookMarkList().getCapacity());
                        statement.setInt(34, this.getBotRating());
                        statement.setInt(35, this.getUsedWorldChatPoints());
                        statement.setInt(36, this.hideHeadAccessories() ? 1 : 0);
                        statement.setInt(37, this.getObjectId());
                        statement.executeUpdate();
                        GameStats.increaseUpdatePlayerBase();
                        if (!fast) {
                            EffectsDAO.getInstance().insert(this);
                            CharacterGroupReuseDAO.getInstance().insert(this);
                            this.storeDisableSkills();
                        }
                        this.storeCharSubClasses();
                        this.getBookMarkList().store();
                        this.getDailyMissionList().store();
                        if (!Config.PC_BANG_POINTS_BY_ACCOUNT) break block11;
                        AccountVariablesDAO.getInstance().insert(this.getAccountName(), PC_BANG_POINTS_VAR, String.valueOf(this.getPcBangPoints()));
                    }
                    catch (Exception e) {
                        try {
                            _log.error("Could not store char data: " + this + "!", (Throwable)e);
                        }
                        catch (Throwable throwable) {
                            DbUtils.closeQuietly((Connection)con, statement);
                            throw throwable;
                        }
                        DbUtils.closeQuietly((Connection)con, (Statement)statement);
                        break block12;
                    }
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
            }
            finally {
                this._storeLock.unlock();
            }
        }
    }

    public SkillEntry addSkill(SkillEntry newSkillEntry, boolean store) {
        if (newSkillEntry == null) {
            return null;
        }
        SkillEntry oldSkillEntry = this.addSkill(newSkillEntry);
        if (newSkillEntry.equals(oldSkillEntry)) {
            return oldSkillEntry;
        }
        if (store) {
            this.storeSkill(newSkillEntry);
        }
        return oldSkillEntry;
    }

    public SkillEntry removeSkill(SkillInfo skillInfo, boolean fromDB) {
        if (skillInfo == null) {
            return null;
        }
        return this.removeSkill(skillInfo.getId(), fromDB);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public SkillEntry removeSkill(int id, boolean fromDB) {
        SkillEntry oldSkillEntry = this.removeSkillById(id);
        if (!fromDB) {
            return oldSkillEntry;
        }
        if (oldSkillEntry != null) {
            Connection con = null;
            PreparedStatement statement = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("DELETE FROM character_skills WHERE skill_id=? AND char_obj_id=? AND (class_index=? OR class_index=-1 OR class_index=-2)");
                statement.setInt(1, oldSkillEntry.getId());
                statement.setInt(2, this.getObjectId());
                statement.setInt(3, this.getActiveClassId());
                statement.execute();
            }
            catch (Exception e) {
                try {
                    _log.error("Could not delete skill!", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        return oldSkillEntry;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void storeSkill(SkillEntry newSkillEntry) {
        if (newSkillEntry == null) {
            _log.warn("could not store new skill. its NULL");
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO character_skills (char_obj_id,skill_id,skill_level,class_index) values(?,?,?,?)");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, newSkillEntry.getId());
            statement.setInt(3, newSkillEntry.getLevel());
            statement.setInt(4, this.getActiveClassId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("Error could not store skills!", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void restoreSkills() {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        block11: {
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT skill_id,skill_level FROM character_skills WHERE char_obj_id=? AND (class_index=? OR class_index=-1 OR class_index=-2)");
                statement.setInt(1, this.getObjectId());
                statement.setInt(2, this.getActiveClassId());
                rset = statement.executeQuery();
                while (rset.next()) {
                    SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, rset.getInt("skill_id"), rset.getInt("skill_level"));
                    if (skillEntry == null) continue;
                    if (!this.isGM()) {
                        Skill skill = skillEntry.getTemplate();
                        if (!SkillAcquireHolder.getInstance().isSkillPossible(this, skill)) {
                            this.removeSkill(skillEntry, true);
                            continue;
                        }
                    }
                    this.addSkill(skillEntry);
                }
                this.checkHeroSkills();
                if (this._clan != null) {
                    this._clan.addSkillsQuietly(this);
                }
                if (Config.UNSTUCK_SKILL && this.getSkillLevel(1050) < 0) {
                    this.addSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, 2099, 1));
                }
                for (OptionDataTemplate optionData : this._options.valueCollection()) {
                    for (SkillEntry skillEntry : optionData.getSkills()) {
                        this.addSkill(skillEntry);
                    }
                }
                if (!this.isGM()) break block11;
                this.giveGMSkills();
            }
            catch (Exception e) {
                try {
                    _log.warn("Could not restore skills for player objId: " + this.getObjectId());
                    _log.error("", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void storeDisableSkills() {
        Statement statement;
        Connection con;
        block10: {
            block9: {
                con = null;
                statement = null;
                if (!this._skillReuses.isEmpty()) break block9;
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
                return;
            }
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.createStatement();
                statement.executeUpdate("DELETE FROM character_skills_save WHERE char_obj_id = " + this.getObjectId() + " AND class_index=" + this.getActiveClassId() + " AND `end_time` < " + System.currentTimeMillis());
                SqlBatch b = new SqlBatch("REPLACE INTO `character_skills_save` (`char_obj_id`,`skill_id`,`skill_level`,`class_index`,`end_time`,`reuse_delay_org`) VALUES");
                IntObjectMap intObjectMap = this._skillReuses;
                synchronized (intObjectMap) {
                    for (TimeStamp timeStamp : this._skillReuses.valueCollection()) {
                        if (!timeStamp.hasNotPassed()) continue;
                        StringBuilder sb = new StringBuilder("(");
                        sb.append(this.getObjectId()).append(",");
                        sb.append(timeStamp.getId()).append(",");
                        sb.append(timeStamp.getLevel()).append(",");
                        sb.append(this.getActiveClassId()).append(",");
                        sb.append(timeStamp.getEndTime()).append(",");
                        sb.append(timeStamp.getReuseBasic()).append(")");
                        b.write(sb.toString());
                    }
                }
                if (b.isEmpty()) break block10;
                statement.executeUpdate(b.close());
            }
            catch (Exception e) {
                try {
                    _log.warn("Could not store disable skills data: " + e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restoreDisableSkills() {
        this._skillReuses.clear();
        Connection con = null;
        Statement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.createStatement();
            rset = statement.executeQuery("SELECT skill_id,skill_level,end_time,reuse_delay_org FROM character_skills_save WHERE char_obj_id=" + this.getObjectId() + " AND class_index=" + this.getActiveClassId());
            while (rset.next()) {
                int skillId = rset.getInt("skill_id");
                int skillLevel = rset.getInt("skill_level");
                long endTime = rset.getLong("end_time");
                long rDelayOrg = rset.getLong("reuse_delay_org");
                long curTime = System.currentTimeMillis();
                Skill skill = SkillHolder.getInstance().getSkill(skillId, skillLevel);
                if (skill == null || endTime - curTime <= 500L) continue;
                this._skillReuses.put(skill.getReuseHash(), new TimeStamp(skill, endTime, rDelayOrg));
            }
            DbUtils.close((Statement)statement);
            statement = con.createStatement();
            statement.executeUpdate("DELETE FROM character_skills_save WHERE char_obj_id = " + this.getObjectId() + " AND class_index=" + this.getActiveClassId() + " AND `end_time` < " + System.currentTimeMillis());
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        catch (Exception e) {
            _log.error("Could not restore active skills data!", (Throwable)e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
    }

    @Override
    public boolean consumeItem(int itemConsumeId, long itemCount, boolean sendMessage) {
        return ItemFunctions.deleteItem((Playable)this, itemConsumeId, itemCount, sendMessage);
    }

    @Override
    public boolean consumeItemMp(int itemId, int mp) {
        for (ItemInstance item : this.getInventory().getPaperdollItems()) {
            if (item == null || item.getItemId() != itemId) continue;
            int newMp = item.getLifeTime() - mp;
            if (newMp < 0) break;
            item.setLifeTime(newMp);
            this.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(this, item));
            return true;
        }
        return false;
    }

    @Override
    public boolean isMageClass() {
        return this.getClassId().isMage();
    }

    public boolean checkLandingState() {
        if (this.isInZone(Zone.ZoneType.no_landing)) {
            return false;
        }
        List<SiegeEvent> siegeEvents = this.getEvents(SiegeEvent.class);
        if (siegeEvents.isEmpty()) {
            return true;
        }
        for (SiegeEvent siege : siegeEvents) {
            Object unit = siege.getResidence();
            if (unit == null || this.getClan() == null || !this.isClanLeader() || this.getClan().getCastle() != ((Residence)unit).getId()) continue;
            return true;
        }
        return false;
    }

    public void setMount(int controlItemObjId, int npcId, int level, int currentFeed) {
        Mount mount = Mount.create(this, controlItemObjId, npcId, level, currentFeed);
        if (mount != null) {
            this.setMount(mount);
        }
    }

    public void setMount(Mount mount) {
        if (this._mount == mount) {
            return;
        }
        Mount oldMount = this._mount;
        this._mount = null;
        if (oldMount != null) {
            oldMount.onUnride();
        }
        if (mount != null) {
            this._mount = mount;
            this._mount.onRide();
        }
    }

    @Override
    public boolean isMounted() {
        return this._mount != null;
    }

    public Mount getMount() {
        return this._mount;
    }

    public int getMountControlItemObjId() {
        return this.isMounted() ? this._mount.getControlItemObjId() : 0;
    }

    public int getMountNpcId() {
        return this.isMounted() ? this._mount.getNpcId() : 0;
    }

    public int getMountLevel() {
        return this.isMounted() ? this._mount.getLevel() : 0;
    }

    public int getMountCurrentFeed() {
        return this.isMounted() ? this._mount.getCurrentFeed() : 0;
    }

    public void unEquipWeapon() {
        ItemInstance wpn = this.getSecondaryWeaponInstance();
        if (wpn != null) {
            this.sendDisarmMessage(wpn);
            this.getInventory().unEquipItem(wpn);
        }
        if ((wpn = this.getActiveWeaponInstance()) != null) {
            this.sendDisarmMessage(wpn);
            this.getInventory().unEquipItem(wpn);
        }
        this.abortAttack(true, true);
        this.abortCast(true, true);
    }

    public void sendDisarmMessage(ItemInstance wpn) {
        if (wpn.getEnchantLevel() > 0) {
            SystemMessage sm = new SystemMessage(1064);
            sm.addNumber(wpn.getEnchantLevel());
            sm.addItemName(wpn.getItemId());
            this.sendPacket((IBroadcastPacket)sm);
        } else {
            SystemMessage sm = new SystemMessage(417);
            sm.addItemName(wpn.getItemId());
            this.sendPacket((IBroadcastPacket)sm);
        }
    }

    public void setUsingWarehouseType(Warehouse.WarehouseType type) {
        this._usingWHType = type;
    }

    public Warehouse.WarehouseType getUsingWarehouseType() {
        return this._usingWHType;
    }

    public Collection<Cubic> getCubics() {
        return this._cubics == null ? Collections.emptyList() : this._cubics.valueCollection();
    }

    @Override
    public void deleteCubics() {
        for (Cubic cubic : this.getCubics()) {
            cubic.delete();
        }
    }

    public void addCubic(Cubic cubic) {
        Cubic oldCubic;
        if (this._cubics == null) {
            this._cubics = new CHashIntObjectMap(3);
        }
        if ((oldCubic = (Cubic)this._cubics.get(cubic.getSlot())) != null) {
            oldCubic.delete();
        }
        this._cubics.put(cubic.getSlot(), cubic);
        this.sendPacket((IBroadcastPacket)new ExUserInfoCubic(this));
        this.broadcastCharInfo();
    }

    public void removeCubic(int slot) {
        if (this._cubics != null) {
            this._cubics.remove(slot);
        }
        this.sendPacket((IBroadcastPacket)new ExUserInfoCubic(this));
        this.broadcastCharInfo();
    }

    public Cubic getCubic(int slot) {
        return this._cubics == null ? null : (Cubic)this._cubics.get(slot);
    }

    @Override
    public String toString() {
        return this.getName() + "[" + this.getObjectId() + "]";
    }

    @Override
    public int getEnchantEffect() {
        ItemInstance wpn = this.getActiveWeaponInstance();
        if (wpn == null) {
            return 0;
        }
        return Math.min(127, wpn.getFixedEnchantLevel(this));
    }

    public int getVariation1Id() {
        ItemInstance wpn = this.getActiveWeaponInstance();
        if (wpn == null) {
            return 0;
        }
        return wpn.getVariation1Id();
    }

    public int getVariation2Id() {
        ItemInstance wpn = this.getActiveWeaponInstance();
        if (wpn == null) {
            return 0;
        }
        return wpn.getVariation2Id();
    }

    public void setLastNpc(NpcInstance npc) {
        this._lastNpc = npc == null ? HardReferences.emptyRef() : npc.getRef();
    }

    public NpcInstance getLastNpc() {
        return (NpcInstance)this._lastNpc.get();
    }

    public void setMultisell(MultiSellListContainer multisell) {
        this._multisell = multisell;
    }

    public MultiSellListContainer getMultisell() {
        return this._multisell;
    }

    @Override
    public boolean unChargeShots(boolean spirit) {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon == null) {
            return false;
        }
        if (spirit) {
            weapon.setChargedSpiritshotPower(0.0, 0, 0.0);
        } else {
            weapon.setChargedSoulshotPower(0.0);
        }
        this.autoShot();
        return true;
    }

    public boolean unChargeFishShot() {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon == null) {
            return false;
        }
        weapon.setChargedFishshotPower(0.0);
        this.autoShot();
        return true;
    }

    public void autoShot() {
        for (IntObjectPair entry : this._activeAutoShots.entrySet()) {
            int shotId = entry.getKey();
            ItemInstance item = this.getInventory().getItemByItemId(shotId);
            if (item == null) {
                this.removeAutoShot(shotId, false, (SoulShotType)(entry.getValue()));
                continue;
            }
            item.getTemplate().useItem(this, item, false, false);
        }
    }

    @Override
    public double getChargedSoulshotPower() {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon != null && weapon.getChargedSoulshotPower() > 0.0) {
            return this.getStat().calc(Stats.SOULSHOT_POWER, weapon.getChargedSoulshotPower());
        }
        return 0.0;
    }

    @Override
    public void setChargedSoulshotPower(double val) {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon != null) {
            weapon.setChargedSoulshotPower(val);
        }
    }

    @Override
    public double getChargedSpiritshotPower() {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon != null && weapon.getChargedSpiritshotPower() > 0.0) {
            return this.getStat().calc(Stats.SPIRITSHOT_POWER, weapon.getChargedSpiritshotPower());
        }
        return 0.0;
    }

    @Override
    public double getChargedSpiritshotHealBonus() {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon != null) {
            return weapon.getChargedSpiritshotHealBonus();
        }
        return 0.0;
    }

    @Override
    public void setChargedSpiritshotPower(double power, int unk, double healBonus) {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon != null) {
            weapon.setChargedSpiritshotPower(power, unk, healBonus);
        }
    }

    public double getChargedFishshotPower() {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon != null) {
            return weapon.getChargedFishshotPower();
        }
        return 0.0;
    }

    public void setChargedFishshotPower(double val) {
        ItemInstance weapon = this.getActiveWeaponInstance();
        if (weapon != null) {
            weapon.setChargedFishshotPower(val);
        }
    }

    public boolean addAutoShot(int itemId, boolean sendMessage, SoulShotType type) {
        if (Config.EX_USE_AUTO_SOUL_SHOT) {
            for (IntObjectPair entry : this._activeAutoShots.entrySet()) {
                if (entry.getValue() != type) continue;
                this._activeAutoShots.remove(entry.getKey());
            }
            if (type == SoulShotType.SOULSHOT || type == SoulShotType.SPIRITSHOT) {
                WeaponTemplate weaponTemplate = this.getActiveWeaponTemplate();
                if (weaponTemplate == null) {
                    return false;
                }
                ItemTemplate shotTemplate = ItemHolder.getInstance().getTemplate(itemId);
                if (shotTemplate == null) {
                    return false;
                }
                if (shotTemplate.getGrade().extGrade() != weaponTemplate.getGrade().extGrade()) {
                    return false;
                }
            } else if ((type == SoulShotType.BEAST_SOULSHOT || type == SoulShotType.BEAST_SPIRITSHOT) && this.getServitorsCount() == 0) {
                return false;
            }
        }
        if (this._activeAutoShots.put(itemId, type) != type) {
            if (!Config.EX_USE_AUTO_SOUL_SHOT) {
                this.sendPacket((IBroadcastPacket)new ExAutoSoulShot(itemId, 1, type));
            }
            if (sendMessage) {
                this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_AUTOMATIC_USE_OF_S1_HAS_BEEN_ACTIVATED).addItemName(itemId));
            }
            return true;
        }
        return false;
    }

    public boolean manuallyAddAutoShot(int itemId, SoulShotType type, boolean save) {
        if (this.addAutoShot(itemId, true, type)) {
            if (Config.EX_USE_AUTO_SOUL_SHOT) {
                if (save) {
                    this.setVar("@active_shot_id_" + type.ordinal(), itemId);
                } else {
                    this.unsetVar("@active_shot_id_" + type.ordinal());
                }
            }
            return true;
        }
        return false;
    }

    public void sendActiveAutoShots() {
        if (Config.EX_USE_AUTO_SOUL_SHOT) {
            return;
        }
        for (IntObjectPair entry : this._activeAutoShots.entrySet()) {
            this.sendPacket((IBroadcastPacket)new ExAutoSoulShot(entry.getKey(), 1, (SoulShotType)(entry.getValue())));
        }
    }

    public void initActiveAutoShots() {
        if (!Config.EX_USE_AUTO_SOUL_SHOT) {
            return;
        }
        for (SoulShotType type : SoulShotType.VALUES) {
            if (this.initSavedActiveShot(type)) continue;
            this.sendPacket((IBroadcastPacket)new ExAutoSoulShot(0, 1, type));
        }
    }

    public boolean initSavedActiveShot(SoulShotType type) {
        if (!Config.EX_USE_AUTO_SOUL_SHOT) {
            return false;
        }
        int shotId = this.getVarInt("@active_shot_id_" + type.ordinal(), 0);
        if (shotId > 0) {
            IItemHandler handler;
            ItemInstance item = this.getInventory().getItemByItemId(shotId);
            if (item != null && (handler = item.getTemplate().getHandler()) != null && handler.isAutoUse() && this.addAutoShot(shotId, true, type)) {
                this.sendPacket((IBroadcastPacket)new ExAutoSoulShot(shotId, 3, type));
                this.useItem(item, false, false);
                return true;
            }
        } else if (shotId == -1) {
            this.sendPacket((IBroadcastPacket)new ExAutoSoulShot(0, 2, type));
            return true;
        }
        return false;
    }

    public void removeAutoShots(boolean uncharge) {
        ItemInstance weapon;
        if (Config.EX_USE_AUTO_SOUL_SHOT) {
            return;
        }
        for (IntObjectPair entry : this._activeAutoShots.entrySet()) {
            this.removeAutoShot(entry.getKey(), false, (SoulShotType)(entry.getValue()));
        }
        if (uncharge && (weapon = this.getActiveWeaponInstance()) != null) {
            weapon.setChargedSoulshotPower(0.0);
            weapon.setChargedSpiritshotPower(0.0, 0, 0.0);
            weapon.setChargedFishshotPower(0.0);
        }
    }

    public boolean removeAutoShot(int itemId, boolean sendMessage, SoulShotType type) {
        if (this._activeAutoShots.remove(itemId) != null) {
            if (!Config.EX_USE_AUTO_SOUL_SHOT) {
                this.sendPacket((IBroadcastPacket)new ExAutoSoulShot(itemId, 0, type));
            }
            if (sendMessage) {
                this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_AUTOMATIC_USE_OF_S1_HAS_BEEN_DEACTIVATED).addItemName(itemId));
            }
            return true;
        }
        return false;
    }

    public boolean manuallyRemoveAutoShot(int itemId, SoulShotType type, boolean save) {
        if (this.removeAutoShot(itemId, true, type)) {
            if (Config.EX_USE_AUTO_SOUL_SHOT) {
                if (save) {
                    this.setVar("@active_shot_id_" + type.ordinal(), -1);
                } else {
                    this.unsetVar("@active_shot_id_" + type.ordinal());
                }
            }
            return true;
        }
        return false;
    }

    public void removeAutoShot(SoulShotType type) {
        if (!Config.EX_USE_AUTO_SOUL_SHOT) {
            return;
        }
        for (IntObjectPair entry : this._activeAutoShots.entrySet()) {
            if (entry.getValue() != type) continue;
            this.removeAutoShot(entry.getKey(), false, (SoulShotType)(entry.getValue()));
            this.sendPacket((IBroadcastPacket)new ExAutoSoulShot(entry.getKey(), 1, (SoulShotType)(entry.getValue())));
        }
    }

    public boolean isAutoShot(int itemId) {
        return this._activeAutoShots.containsKey(itemId);
    }

    public boolean isAutoShot(SoulShotType type) {
        return this._activeAutoShots.containsValue((Object)type);
    }

    @Override
    public boolean isInvisible(GameObject observer) {
        if (observer != null) {
            if (this.getObjectId() == observer.getObjectId()) {
                return false;
            }
            if (this.isMyServitor(observer.getObjectId())) {
                return false;
            }
            if (observer.isPlayer()) {
                Player observPlayer = (Player)observer;
                if (this.isInSameParty(observPlayer)) {
                    return false;
                }
                if (observPlayer.getPlayerAccess().CanSeeInHide) {
                    return false;
                }
            }
        }
        return super.isInvisible(observer) || this.isGMInvisible();
    }

    @Override
    public boolean startInvisible(Object owner, boolean withServitors) {
        if (super.startInvisible(owner, withServitors)) {
            this.sendUserInfo(true);
            return true;
        }
        return false;
    }

    @Override
    public boolean stopInvisible(Object owner, boolean withServitors) {
        if (super.stopInvisible(owner, withServitors)) {
            this.sendUserInfo(true);
            return true;
        }
        return false;
    }

    public boolean isGMInvisible() {
        return this.getPlayerAccess().GodMode && this._gmInvisible.get();
    }

    public boolean setGMInvisible(boolean value) {
        if (value) {
            return this._gmInvisible.getAndSet(true);
        }
        return this._gmInvisible.setAndGet(false);
    }

    @Override
    public boolean isUndying() {
        return super.isUndying() || this.isGMUndying();
    }

    public boolean isGMUndying() {
        return this.getPlayerAccess().GodMode && this._gmUndying.get();
    }

    public boolean setGMUndying(boolean value) {
        if (value) {
            return this._gmUndying.getAndSet(true);
        }
        return this._gmUndying.setAndGet(false);
    }

    public int getClanPrivileges() {
        if (this._clan == null) {
            return 0;
        }
        if (this.isClanLeader()) {
            return 0xFFFFFE;
        }
        if (this._powerGrade < 1 || this._powerGrade > 9) {
            return 0;
        }
        RankPrivs privs = this._clan.getRankPrivs(this._powerGrade);
        if (privs != null) {
            return privs.getPrivs();
        }
        return 0;
    }

    public void teleToClosestTown() {
        TeleportPoint teleportPoint = TeleportUtils.getRestartPoint(this, RestartType.TO_VILLAGE);
        this.teleToLocation((ILocation)teleportPoint.getLoc(), teleportPoint.getReflection());
    }

    public void teleToCastle() {
        TeleportPoint teleportPoint = TeleportUtils.getRestartPoint(this, RestartType.TO_CASTLE);
        this.teleToLocation((ILocation)teleportPoint.getLoc(), teleportPoint.getReflection());
    }

    public void teleToClanhall() {
        TeleportPoint teleportPoint = TeleportUtils.getRestartPoint(this, RestartType.TO_CLANHALL);
        this.teleToLocation((ILocation)teleportPoint.getLoc(), teleportPoint.getReflection());
    }

    @Override
    public void sendMessage(CustomMessage message) {
        this.sendPacket((IBroadcastPacket)message);
    }

    public void teleToLocation(ILocation loc, boolean replace) {
        this._isInReplaceTeleport = replace;
        this.teleToLocation(loc);
        this._isInReplaceTeleport = false;
    }

    @Override
    public boolean onTeleported() {
        if (!super.onTeleported()) {
            return false;
        }
        if (this.isFakeDeath()) {
            this.breakFakeDeath();
        }
        if (this.isInBoat()) {
            this.setLoc(this.getBoat().getLoc());
        }
        this.setNonAggroTime(System.currentTimeMillis() + Config.NONAGGRO_TIME_ONTELEPORT);
        this.setNonPvpTime(System.currentTimeMillis() + Config.NONPVP_TIME_ONTELEPORT);
        this.spawnMe();
        if (this.isPendingRevive()) {
            this.doRevive();
        }
        this.sendActionFailed();
        this.getAI().notifyEvent(CtrlEvent.EVT_TELEPORTED);
        if (this.isLockedTarget() && this.getTarget() != null) {
            this.sendPacket((IBroadcastPacket)new MyTargetSelectedPacket(this, this.getTarget()));
        }
        this.sendUserInfo(true);
        if (!this._isInReplaceTeleport) {
            for (Servitor servitor : this.getServitors()) {
                servitor.teleportToOwner();
            }
        }
        this.getListeners().onTeleported();
        for (ListenerHook hook : this.getListenerHooks(ListenerHookType.PLAYER_TELEPORT)) {
            hook.onPlayerTeleport(this, this.getReflectionId());
        }
        for (ListenerHook hook : ListenerHook.getGlobalListenerHooks(ListenerHookType.PLAYER_TELEPORT)) {
            hook.onPlayerTeleport(this, this.getReflectionId());
        }
        return true;
    }

    public boolean enterObserverMode(Location loc) {
        WorldRegion observerRegion = World.getRegion(loc);
        if (observerRegion == null) {
            return false;
        }
        if (!this._observerMode.compareAndSet(0, 1)) {
            return false;
        }
        this.setTarget(null);
        this.getMovement().stopMove();
        this.sitDown(null);
        this.setFlying(true);
        World.removeObjectsFromPlayer(this);
        this._observePoint = new ObservePoint(this);
        this._observePoint.setLoc(loc);
        this._observePoint.getFlags().getImmobilized().start();
        this.broadcastCharInfoImpl(new IUpdateTypeComponent[0]);
        this.sendPacket((IBroadcastPacket)new ObserverStartPacket(loc));
        return true;
    }

    public boolean enterArenaObserverMode(ObservableArena arena) {
        Location enterPoint = arena.getObserverEnterPoint(this);
        WorldRegion observerRegion = World.getRegion(enterPoint);
        if (observerRegion == null) {
            return false;
        }
        if (!this._observerMode.compareAndSet(this.isInArenaObserverMode() ? 3 : 0, 1)) {
            return false;
        }
        this.sendPacket((IBroadcastPacket)new TeleportToLocationPacket(this, enterPoint));
        this.setTarget(null);
        this.getMovement().stopMove();
        World.removeObjectsFromPlayer(this);
        if (this._observableArena != null) {
            this._observableArena.removeObserver(this._observePoint);
            this._observableArena.onChangeObserverArena(this);
            this._observePoint.decayMe();
        } else {
            this.broadcastCharInfoImpl(new IUpdateTypeComponent[0]);
            arena.onEnterObserverArena(this);
            this._observePoint = new ObservePoint(this);
        }
        this._observePoint.setLoc(enterPoint);
        this._observePoint.setReflection(arena.getReflection());
        this._observableArena = arena;
        this.sendPacket((IBroadcastPacket)new ExTeleportToLocationActivate(this, enterPoint));
        return true;
    }

    public void appearObserverMode() {
        if (!this._observerMode.compareAndSet(1, 3)) {
            return;
        }
        this._observePoint.spawnMe();
        this.sendUserInfo(true);
        if (this._observableArena != null) {
            this._observableArena.addObserver(this._observePoint);
            this._observableArena.onAppearObserver(this._observePoint);
        }
    }

    public void leaveObserverMode() {
        if (!this._observerMode.compareAndSet(3, 2)) {
            return;
        }
        ObservableArena arena = this._observableArena;
        if (arena != null) {
            this.sendPacket((IBroadcastPacket)new TeleportToLocationPacket(this, this.getLoc()));
            this._observableArena.removeObserver(this._observePoint);
            this._observableArena = null;
        }
        this._observePoint.deleteMe();
        this._observePoint = null;
        this.setTarget(null);
        this.getMovement().stopMove();
        if (arena != null) {
            arena.onExitObserverArena(this);
            this.sendPacket((IBroadcastPacket)new ExTeleportToLocationActivate(this, this.getLoc()));
        } else {
            this.sendPacket((IBroadcastPacket)new ObserverEndPacket(this.getLoc()));
        }
    }

    public void returnFromObserverMode() {
        if (!this._observerMode.compareAndSet(2, 0)) {
            return;
        }
        this.standUp();
        this.setFlying(false);
        this.broadcastUserInfo(true);
        World.showObjectsToPlayer(this);
    }

    public void setOlympiadSide(int i) {
        this._olympiadSide = i;
    }

    public int getOlympiadSide() {
        return this._olympiadSide;
    }

    public boolean isInObserverMode() {
        return this.getObserverMode() > 0;
    }

    public boolean isInArenaObserverMode() {
        return this._observableArena != null;
    }

    public ObservableArena getObservableArena() {
        return this._observableArena;
    }

    public int getObserverMode() {
        return this._observerMode.get();
    }

    public ObservePoint getObservePoint() {
        return this._observePoint;
    }

    public int getTeleMode() {
        return this._telemode;
    }

    public void setTeleMode(int mode) {
        this._telemode = mode;
    }

    public void setLoto(int i, int val) {
        this._loto[i] = val;
    }

    public int getLoto(int i) {
        return this._loto[i];
    }

    public void setRace(int i, int val) {
        this._race[i] = val;
    }

    public int getRace(int i) {
        return this._race[i];
    }

    public boolean getMessageRefusal() {
        return this._messageRefusal;
    }

    public void setMessageRefusal(boolean mode) {
        this._messageRefusal = mode;
    }

    public void setTradeRefusal(boolean mode) {
        this._tradeRefusal = mode;
    }

    public boolean getTradeRefusal() {
        return this._tradeRefusal;
    }

    public boolean isBlockAll() {
        return this._blockAll;
    }

    public void setBlockAll(boolean state) {
        this._blockAll = state;
    }

    public void setHero(boolean hero) {
        this._hero = hero;
    }

    @Override
    public boolean isHero() {
        return this._hero;
    }

    public void setIsInOlympiadMode(boolean b) {
        this._inOlympiadMode = b;
    }

    public boolean isInOlympiadMode() {
        return this._inOlympiadMode;
    }

    public boolean isOlympiadGameStart() {
        return this._olympiadGame != null && this._olympiadGame.getState() == 1;
    }

    public boolean isOlympiadCompStart() {
        return this._olympiadGame != null && this._olympiadGame.getState() == 2;
    }

    public int getSubLevel() {
        return this.isBaseClassActive() ? 0 : this.getLevel();
    }

    public void updateKetraVarka() {
        if (ItemFunctions.getItemCount(this, 7215) > 0L) {
            this._ketra = 5;
        } else if (ItemFunctions.getItemCount(this, 7214) > 0L) {
            this._ketra = 4;
        } else if (ItemFunctions.getItemCount(this, 7213) > 0L) {
            this._ketra = 3;
        } else if (ItemFunctions.getItemCount(this, 7212) > 0L) {
            this._ketra = 2;
        } else if (ItemFunctions.getItemCount(this, 7211) > 0L) {
            this._ketra = 1;
        } else if (ItemFunctions.getItemCount(this, 7225) > 0L) {
            this._varka = 5;
        } else if (ItemFunctions.getItemCount(this, 7224) > 0L) {
            this._varka = 4;
        } else if (ItemFunctions.getItemCount(this, 7223) > 0L) {
            this._varka = 3;
        } else if (ItemFunctions.getItemCount(this, 7222) > 0L) {
            this._varka = 2;
        } else if (ItemFunctions.getItemCount(this, 7221) > 0L) {
            this._varka = 1;
        } else {
            this._varka = 0;
            this._ketra = 0;
        }
    }

    public int getVarka() {
        return this._varka;
    }

    public int getKetra() {
        return this._ketra;
    }

    public void updateRam() {
        this._ram = ItemFunctions.getItemCount(this, 7247) > 0L ? 2 : (ItemFunctions.getItemCount(this, 7246) > 0L ? 1 : 0);
    }

    public int getRam() {
        return this._ram;
    }

    public void setPledgeType(int typeId) {
        this._pledgeType = typeId;
    }

    public int getPledgeType() {
        return this._pledgeType;
    }

    public void setLvlJoinedAcademy(int lvl) {
        this._lvlJoinedAcademy = lvl;
    }

    public int getLvlJoinedAcademy() {
        return this._lvlJoinedAcademy;
    }

    public PledgeRank getPledgeRank() {
        return this._pledgeRank;
    }

    public void updatePledgeRank() {
        if (this.isGM()) {
            this._pledgeRank = PledgeRank.EMPEROR;
            return;
        }
        int CLAN_LEVEL = this._clan == null ? -1 : this._clan.getLevel();
        boolean IN_ACADEMY = this._clan != null && Clan.isAcademy(this._pledgeType);
        boolean IS_GUARD = this._clan != null && Clan.isRoyalGuard(this._pledgeType);
        boolean IS_KNIGHT = this._clan != null && Clan.isOrderOfKnights(this._pledgeType);
        boolean IS_GUARD_CAPTAIN = false;
        boolean IS_KNIGHT_COMMANDER = false;
        boolean IS_LEADER = false;
        SubUnit unit = this.getSubUnit();
        if (unit != null) {
            UnitMember unitMember = unit.getUnitMember(this.getObjectId());
            if (unitMember == null) {
                _log.warn("Player: unitMember null, clan: " + this._clan.getClanId() + "; pledgeType: " + unit.getType());
                return;
            }
            IS_GUARD_CAPTAIN = Clan.isRoyalGuard(unitMember.isLeaderOf());
            IS_KNIGHT_COMMANDER = Clan.isOrderOfKnights(unitMember.isLeaderOf());
            IS_LEADER = unitMember.isLeaderOf() == 0;
        }
        switch (CLAN_LEVEL) {
            case -1: {
                this._pledgeRank = PledgeRank.VAGABOND;
                break;
            }
            case 0: 
            case 1: 
            case 2: 
            case 3: {
                this._pledgeRank = PledgeRank.VASSAL;
                break;
            }
            case 4: {
                if (IS_LEADER) {
                    this._pledgeRank = PledgeRank.KNIGHT;
                    break;
                }
                this._pledgeRank = PledgeRank.VASSAL;
                break;
            }
            case 5: {
                if (IS_LEADER) {
                    this._pledgeRank = PledgeRank.WISEMAN;
                    break;
                }
                if (IN_ACADEMY) {
                    this._pledgeRank = PledgeRank.VASSAL;
                    break;
                }
                this._pledgeRank = PledgeRank.HEIR;
                break;
            }
            case 6: {
                if (IS_LEADER) {
                    this._pledgeRank = PledgeRank.BARON;
                    break;
                }
                if (IN_ACADEMY) {
                    this._pledgeRank = PledgeRank.VASSAL;
                    break;
                }
                if (IS_GUARD_CAPTAIN) {
                    this._pledgeRank = PledgeRank.WISEMAN;
                    break;
                }
                if (IS_GUARD) {
                    this._pledgeRank = PledgeRank.HEIR;
                    break;
                }
                this._pledgeRank = PledgeRank.KNIGHT;
                break;
            }
            case 7: {
                if (IS_LEADER) {
                    this._pledgeRank = PledgeRank.COUNT;
                    break;
                }
                if (IN_ACADEMY) {
                    this._pledgeRank = PledgeRank.VASSAL;
                    break;
                }
                if (IS_GUARD_CAPTAIN) {
                    this._pledgeRank = PledgeRank.VISCOUNT;
                    break;
                }
                if (IS_GUARD) {
                    this._pledgeRank = PledgeRank.KNIGHT;
                    break;
                }
                if (IS_KNIGHT_COMMANDER) {
                    this._pledgeRank = PledgeRank.BARON;
                    break;
                }
                if (IS_KNIGHT) {
                    this._pledgeRank = PledgeRank.HEIR;
                    break;
                }
                this._pledgeRank = PledgeRank.WISEMAN;
                break;
            }
            case 8: {
                if (IS_LEADER) {
                    this._pledgeRank = PledgeRank.MARQUIS;
                    break;
                }
                if (IN_ACADEMY) {
                    this._pledgeRank = PledgeRank.VASSAL;
                    break;
                }
                if (IS_GUARD_CAPTAIN) {
                    this._pledgeRank = PledgeRank.COUNT;
                    break;
                }
                if (IS_GUARD) {
                    this._pledgeRank = PledgeRank.WISEMAN;
                    break;
                }
                if (IS_KNIGHT_COMMANDER) {
                    this._pledgeRank = PledgeRank.VISCOUNT;
                    break;
                }
                if (IS_KNIGHT) {
                    this._pledgeRank = PledgeRank.KNIGHT;
                    break;
                }
                this._pledgeRank = PledgeRank.BARON;
                break;
            }
            case 9: {
                if (IS_LEADER) {
                    this._pledgeRank = PledgeRank.DUKE;
                    break;
                }
                if (IN_ACADEMY) {
                    this._pledgeRank = PledgeRank.VASSAL;
                    break;
                }
                if (IS_GUARD_CAPTAIN) {
                    this._pledgeRank = PledgeRank.MARQUIS;
                    break;
                }
                if (IS_GUARD) {
                    this._pledgeRank = PledgeRank.BARON;
                    break;
                }
                if (IS_KNIGHT_COMMANDER) {
                    this._pledgeRank = PledgeRank.COUNT;
                    break;
                }
                if (IS_KNIGHT) {
                    this._pledgeRank = PledgeRank.WISEMAN;
                    break;
                }
                this._pledgeRank = PledgeRank.VISCOUNT;
                break;
            }
            case 10: {
                if (IS_LEADER) {
                    this._pledgeRank = PledgeRank.GRAND_DUKE;
                    break;
                }
                if (IN_ACADEMY) {
                    this._pledgeRank = PledgeRank.VASSAL;
                    break;
                }
                if (IS_GUARD) {
                    this._pledgeRank = PledgeRank.VISCOUNT;
                    break;
                }
                if (IS_KNIGHT) {
                    this._pledgeRank = PledgeRank.BARON;
                    break;
                }
                if (IS_GUARD_CAPTAIN) {
                    this._pledgeRank = PledgeRank.DUKE;
                    break;
                }
                if (IS_KNIGHT_COMMANDER) {
                    this._pledgeRank = PledgeRank.MARQUIS;
                    break;
                }
                this._pledgeRank = PledgeRank.COUNT;
                break;
            }
            case 11: {
                this._pledgeRank = IS_LEADER ? PledgeRank.DISTINGUISHED_KING : (IN_ACADEMY ? PledgeRank.VASSAL : (IS_GUARD ? PledgeRank.COUNT : (IS_KNIGHT ? PledgeRank.VISCOUNT : (IS_GUARD_CAPTAIN ? PledgeRank.GRAND_DUKE : (IS_KNIGHT_COMMANDER ? PledgeRank.DUKE : PledgeRank.MARQUIS)))));
            }
        }
        if (this.isHero() && this._pledgeRank.ordinal() < PledgeRank.MARQUIS.ordinal()) {
            this._pledgeRank = PledgeRank.MARQUIS;
        }
    }

    public void setPowerGrade(int grade) {
        this._powerGrade = grade;
    }

    public int getPowerGrade() {
        return this._powerGrade;
    }

    public void setApprentice(int apprentice) {
        this._apprentice = apprentice;
    }

    public int getApprentice() {
        return this._apprentice;
    }

    public int getSponsor() {
        return this._clan == null ? 0 : this._clan.getAnyMember(this.getObjectId()).getSponsor();
    }

    @Override
    public int getNameColor() {
        if (this.isInObserverMode()) {
            return Color.black.getRGB();
        }
        return this._nameColor;
    }

    public void setNameColor(int nameColor) {
        if (nameColor != Config.NORMAL_NAME_COLOUR && nameColor != Config.CLANLEADER_NAME_COLOUR && nameColor != Config.GM_NAME_COLOUR && nameColor != Config.SERVICES_OFFLINE_TRADE_NAME_COLOR) {
            this.setVar("namecolor", Integer.toHexString(nameColor));
        } else if (nameColor == Config.NORMAL_NAME_COLOUR) {
            this.unsetVar("namecolor");
        }
        this._nameColor = nameColor;
    }

    public void setNameColor(int red, int green, int blue) {
        this._nameColor = (red & 0xFF) + ((green & 0xFF) << 8) + ((blue & 0xFF) << 16);
        if (this._nameColor != Config.NORMAL_NAME_COLOUR && this._nameColor != Config.CLANLEADER_NAME_COLOUR && this._nameColor != Config.GM_NAME_COLOUR && this._nameColor != Config.SERVICES_OFFLINE_TRADE_NAME_COLOR) {
            this.setVar("namecolor", Integer.toHexString(this._nameColor));
        } else {
            this.unsetVar("namecolor");
        }
    }

    private void restoreVariables() {
        List<CharacterVariable> variables = CharacterVariablesDAO.getInstance().restore(this.getObjectId());
        for (CharacterVariable var : variables) {
            this._variables.put(var.getName(), var);
        }
    }

    public Collection<CharacterVariable> getVariables() {
        return this._variables.values();
    }

    public boolean setVar(String name, Object value) {
        return this.setVar(name, value, -1L);
    }

    public boolean setVar(String name, Object value, long expirationTime) {
        CharacterVariable var = new CharacterVariable(name, String.valueOf(value), expirationTime);
        if (CharacterVariablesDAO.getInstance().insert(this.getObjectId(), var)) {
            this._variables.put(name, var);
            return true;
        }
        return false;
    }

    public boolean unsetVar(String name) {
        if (name == null || name.isEmpty()) {
            return false;
        }
        if (this._variables.containsKey(name) && CharacterVariablesDAO.getInstance().delete(this.getObjectId(), name)) {
            return this._variables.remove(name) != null;
        }
        return false;
    }

    public String getVar(String name) {
        return this.getVar(name, null);
    }

    public String getVar(String name, String defaultValue) {
        CharacterVariable var = this._variables.get(name);
        if (var != null && !var.isExpired()) {
            return var.getValue();
        }
        return defaultValue;
    }

    public long getVarExpireTime(String name) {
        CharacterVariable var = this._variables.get(name);
        if (var != null) {
            return var.getExpireTime();
        }
        return 0L;
    }

    public int getVarInt(String name) {
        return this.getVarInt(name, 0);
    }

    public int getVarInt(String name, int defaultValue) {
        String var = this.getVar(name);
        if (var != null) {
            return Integer.parseInt(var);
        }
        return defaultValue;
    }

    public long getVarLong(String name) {
        return this.getVarLong(name, 0L);
    }

    public long getVarLong(String name, long defaultValue) {
        String var = this.getVar(name);
        if (var != null) {
            return Long.parseLong(var);
        }
        return defaultValue;
    }

    public double getVarDouble(String name) {
        return this.getVarDouble(name, 0.0);
    }

    public double getVarDouble(String name, double defaultValue) {
        String var = this.getVar(name);
        if (var != null) {
            return Double.parseDouble(var);
        }
        return defaultValue;
    }

    public boolean getVarBoolean(String name) {
        return this.getVarBoolean(name, false);
    }

    public boolean getVarBoolean(String name, boolean defaultValue) {
        String var = this.getVar(name);
        if (var != null) {
            return !var.equals("0") && !var.equalsIgnoreCase("false");
        }
        return defaultValue;
    }

    public void setLanguage(String val) {
        this._language = Language.getLanguage(val);
        this.setVar("lang@", this._language.getShortName(), -1L);
    }

    public Language getLanguage() {
        if (Config.USE_CLIENT_LANG && this.getNetConnection() != null) {
            return this.getNetConnection().getLanguage();
        }
        if (Config.CAN_SELECT_LANGUAGE) {
            return this._language;
        }
        return Config.DEFAULT_LANG;
    }

    public int getLocationId() {
        if (this.getNetConnection() != null) {
            return this.getNetConnection().getLanguage().getId();
        }
        return -1;
    }

    public boolean isLangRus() {
        return this.getLanguage() == Language.RUSSIAN || this.getLanguage().getSecondLanguage() == Language.RUSSIAN;
    }

    public void stopWaterTask() {
        if (this._taskWater != null) {
            this._taskWater.cancel(false);
            this._taskWater = null;
            this.sendPacket((IBroadcastPacket)new SetupGaugePacket(this, SetupGaugePacket.Colors.BLUE, 0));
            this.sendChanges();
        }
    }

    public void startWaterTask() {
        if (this.isDead()) {
            this.stopWaterTask();
        } else if (Config.ALLOW_WATER && this._taskWater == null) {
            int timeinwater = (int)(this.getStat().calc(Stats.BREATH, this.getBaseStats().getBreathBonus(), null, null) * 1000.0);
            this.sendPacket((IBroadcastPacket)new SetupGaugePacket(this, SetupGaugePacket.Colors.BLUE, timeinwater));
            if (this.isTransformed() && !this.getTransform().isCanSwim()) {
                this.setTransform(null);
            }
            this._taskWater = ThreadPoolManager.getInstance().scheduleAtFixedRate(new GameObjectTasks.WaterTask(this), timeinwater, 1000L);
            this.sendChanges();
        }
    }

    public void doRevive(double percent) {
        this.restoreExp(percent);
        this.doRevive();
    }

    @Override
    public void doRevive() {
        AgathionTemplate agathionTemplate;
        ItemInstance agathionItem;
        super.doRevive();
        this.unsetVar("lostexp");
        this.updateAbnormalIcons();
        this.autoShot();
        if (this.isMounted()) {
            this._mount.onRevive();
        }
        if ((agathionItem = this.getInventory().getPaperdollItem(19)) != null && (agathionTemplate = agathionItem.getTemplate().getAgathionTemplate()) != null) {
            Agathion agathion = new Agathion(this, agathionTemplate, null);
            agathion.init();
        }
    }

    public void reviveRequest(Player reviver, double percent, boolean pet) {
        ReviveAnswerListener reviveAsk;
        ReviveAnswerListener reviveAnswerListener = reviveAsk = this._askDialog != null && this._askDialog.getValue() instanceof ReviveAnswerListener ? (ReviveAnswerListener)this._askDialog.getValue() : null;
        if (reviveAsk != null) {
            if (reviveAsk.isForPet() == pet && reviveAsk.getPower() >= percent) {
                reviver.sendPacket((IBroadcastPacket)SystemMsg.RESURRECTION_HAS_ALREADY_BEEN_PROPOSED);
                return;
            }
            if (pet && !reviveAsk.isForPet()) {
                reviver.sendPacket((IBroadcastPacket)SystemMsg.A_PET_CANNOT_BE_RESURRECTED_WHILE_ITS_OWNER_IS_IN_THE_PROCESS_OF_RESURRECTING);
                return;
            }
            if (pet && this.isDead()) {
                reviver.sendPacket((IBroadcastPacket)SystemMsg.WHILE_A_PET_IS_BEING_RESURRECTED_IT_CANNOT_HELP_IN_RESURRECTING_ITS_MASTER);
                return;
            }
        }
        if (pet && this.getPet() != null && this.getPet().isDead() || !pet && this.isDead()) {
            ConfirmDlgPacket pkt = new ConfirmDlgPacket(SystemMsg.C1_IS_MAKING_AN_ATTEMPT_TO_RESURRECT_YOU_IF_YOU_CHOOSE_THIS_PATH_S2_EXPERIENCE_WILL_BE_RETURNED_FOR_YOU, 0);
            ((ConfirmDlgPacket)pkt.addName(reviver)).addInteger(Math.round(percent));
            this.ask(pkt, new ReviveAnswerListener(this, percent, pet));
        }
    }

    public void requestCheckBot() {
        BotCheckManager.BotCheckQuestion question = BotCheckManager.generateRandomQuestion();
        int qId = question.getId();
        String qDescr = question.getDescr(this.isLangRus());
        ConfirmDlgPacket pkt = (ConfirmDlgPacket)new ConfirmDlgPacket(SystemMsg.S1, 60000).addString(qDescr);
        this.ask(pkt, new BotCheckAnswerListner(this, qId));
    }

    public void increaseBotRating() {
        int bot_points = this.getBotRating();
        if (bot_points + 1 >= Config.MAX_BOT_POINTS) {
            return;
        }
        this.setBotRating(bot_points + 1);
    }

    public void decreaseBotRating() {
        int bot_points = this.getBotRating();
        if (bot_points - 1 <= Config.MINIMAL_BOT_RATING_TO_BAN) {
            if (this.toJail(Config.AUTO_BOT_BAN_JAIL_TIME)) {
                this.sendMessage("You moved to jail, time to escape - " + Config.AUTO_BOT_BAN_JAIL_TIME + " minutes, reason - botting .");
                if (Config.ANNOUNCE_AUTO_BOT_BAN) {
                    Announcements.announceToAll("Player " + this.getName() + " jailed for botting!");
                }
            }
        } else {
            this.setBotRating(bot_points - 1);
            if (Config.ON_WRONG_QUESTION_KICK) {
                this.kick();
            }
        }
    }

    public void setBotRating(int rating) {
        this._botRating = rating;
    }

    public int getBotRating() {
        return this._botRating;
    }

    public boolean isInJail() {
        return this._isInJail;
    }

    public void setIsInJail(boolean value) {
        this._isInJail = value;
    }

    public boolean toJail(int time) {
        if (this.isInJail()) {
            return false;
        }
        this.setIsInJail(true);
        this.setVar(JAILED_VAR, true, System.currentTimeMillis() + (long)(time * 60000));
        this.startUnjailTask(this, time);
        if (this.getReflection().isMain()) {
            this.setVar("backCoords", this.getLoc().toXYZString(), -1L);
        }
        if (this.isInStoreMode()) {
            this.setPrivateStoreType(0);
            this.storePrivateStore();
        }
        this.teleToLocation((ILocation)Location.findPointToStay(this, AdminFunctions.JAIL_SPAWN, 50, 200), ReflectionManager.JAIL);
        return true;
    }

    public boolean fromJail() {
        if (!this.isInJail()) {
            return false;
        }
        this.setIsInJail(false);
        this.unsetVar(JAILED_VAR);
        this.stopUnjailTask();
        String back = this.getVar("backCoords");
        if (back != null) {
            this.teleToLocation((ILocation)Location.parseLoc(back), ReflectionManager.MAIN);
            this.unsetVar("backCoords");
        }
        return true;
    }

    public void summonCharacterRequest(Creature summoner, Location loc, int summonConsumeCrystal) {
        ConfirmDlgPacket cd = new ConfirmDlgPacket(SystemMsg.C1_WISHES_TO_SUMMON_YOU_FROM_S2, 60000);
        ((ConfirmDlgPacket)cd.addName(summoner)).addZoneName(loc);
        this.ask(cd, new SummonAnswerListener(this, loc, summonConsumeCrystal));
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void updateNoChannel(long time) {
        this.setNoChannel(time);
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            String stmt = "UPDATE characters SET nochannel = ? WHERE obj_Id=?";
            statement = con.prepareStatement("UPDATE characters SET nochannel = ? WHERE obj_Id=?");
            statement.setLong(1, this._NoChannel > 0L ? this._NoChannel / 1000L : this._NoChannel);
            statement.setInt(2, this.getObjectId());
            statement.executeUpdate();
        }
        catch (Exception e) {
            try {
                _log.warn("Could not activate nochannel:" + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this.sendPacket((IBroadcastPacket)new EtcStatusUpdatePacket(this));
    }

    public boolean canTalkWith(Player player) {
        return this._NoChannel >= 0L || player == this;
    }

    private void checkDailyCounters() {
        int daysPassed = 0;
        long lastAccessTime = (long)this._lastAccess * 1000L;
        while (lastAccessTime < System.currentTimeMillis()) {
            long nextDayTime = DAILY_TIME_PATTERN.next(lastAccessTime);
            if (nextDayTime < System.currentTimeMillis()) {
                ++daysPassed;
            }
            lastAccessTime = nextDayTime;
        }
        if (daysPassed > 0) {
            this.restartDailyCounters(true);
        }
    }

    public void restartDailyCounters(boolean onRestore) {
        if (Config.ALLOW_WORLD_CHAT) {
            this.setUsedWorldChatPoints(0);
            if (!onRestore) {
                this.sendPacket((IBroadcastPacket)new ExWorldChatCnt(this));
            }
        }
    }

    private void checkWeeklyCounters() {
        int weeksPassed = 0;
        long lastAccessTime = (long)this._lastAccess * 1000L;
        while (lastAccessTime < System.currentTimeMillis()) {
            long nextDayTime = WEEKLY_TIME_PATTERN.next(lastAccessTime);
            if (nextDayTime < System.currentTimeMillis()) {
                ++weeksPassed;
            }
            lastAccessTime = nextDayTime;
        }
        if (weeksPassed > 0) {
            this.restartWeeklyCounters(true);
        }
    }

    public void restartWeeklyCounters(boolean onRestore) {
    }

    public SubClassList getSubClassList() {
        return this._subClassList;
    }

    public SubClass getBaseSubClass() {
        return this._subClassList.getBaseSubClass();
    }

    public int getBaseClassId() {
        if (this.getBaseSubClass() != null) {
            return this.getBaseSubClass().getClassId();
        }
        return -1;
    }

    public SubClass getActiveSubClass() {
        return this._subClassList.getActiveSubClass();
    }

    public int getActiveClassId() {
        return this.getActiveSubClass().getClassId();
    }

    public boolean isBaseClassActive() {
        return this.getActiveSubClass().isBase();
    }

    public ClassId getClassId() {
        return ClassId.VALUES[this.getActiveClassId()];
    }

    public int getMaxLevel() {
        if (this.getActiveSubClass() != null) {
            return this.getActiveSubClass().getMaxLevel();
        }
        return Experience.getMaxLevel();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private synchronized void changeClassInDb(int oldclass, int newclass) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE character_subclasses SET class_id=? WHERE char_obj_id=? AND class_id=?");
            statement.setInt(1, newclass);
            statement.setInt(2, this.getObjectId());
            statement.setInt(3, oldclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_hennas WHERE char_obj_id=? AND class_index=?");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, newclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE character_hennas SET class_index=? WHERE char_obj_id=? AND class_index=?");
            statement.setInt(1, newclass);
            statement.setInt(2, this.getObjectId());
            statement.setInt(3, oldclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_shortcuts WHERE object_id=? AND class_index=?");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, newclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE character_shortcuts SET class_index=? WHERE object_id=? AND class_index=?");
            statement.setInt(1, newclass);
            statement.setInt(2, this.getObjectId());
            statement.setInt(3, oldclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_skills WHERE char_obj_id=? AND class_index=?");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, newclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE character_skills SET class_index=? WHERE char_obj_id=? AND class_index=?");
            statement.setInt(1, newclass);
            statement.setInt(2, this.getObjectId());
            statement.setInt(3, oldclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_effects_save WHERE object_id=? AND id=?");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, newclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE character_effects_save SET id=? WHERE object_id=? AND id=?");
            statement.setInt(1, newclass);
            statement.setInt(2, this.getObjectId());
            statement.setInt(3, oldclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_skills_save WHERE char_obj_id=? AND class_index=?");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, newclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE character_skills_save SET class_index=? WHERE char_obj_id=? AND class_index=?");
            statement.setInt(1, newclass);
            statement.setInt(2, this.getObjectId());
            statement.setInt(3, oldclass);
            statement.executeUpdate();
            DbUtils.close((Statement)statement);
        }
        catch (SQLException e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public void storeCharSubClasses() {
        SubClass main = this.getActiveSubClass();
        if (main != null) {
            main.setCp(this.getCurrentCp());
            main.setHp(this.getCurrentHp());
            main.setMp(this.getCurrentMp());
        } else {
            _log.warn("Could not store char sub data, main class " + this.getActiveClassId() + " not found for " + this);
        }
        CharacterSubclassDAO.getInstance().store(this);
    }

    public boolean addSubClass(int classId, boolean storeOld, long exp, long sp) {
        return this.addSubClass(classId, storeOld, SubClassType.SUBCLASS, exp, sp);
    }

    public boolean addSubClass(int classId, boolean storeOld, SubClassType type, long exp, long sp) {
        return this.addSubClass(-1, classId, storeOld, type, exp, sp);
    }

    private boolean addSubClass(int oldClassId, int classId, boolean storeOld, SubClassType type, long exp, long sp) {
        ClassId newId = ClassId.VALUES[classId];
        if (newId.isDummy() || newId.isOfLevel(ClassLevel.NONE) || newId.isOfLevel(ClassLevel.FIRST)) {
            return false;
        }
        SubClass newClass = new SubClass(this);
        newClass.setType(type);
        newClass.setClassId(classId);
        if (exp > 0L) {
            newClass.setExp(exp, true);
        }
        if (sp > 0L) {
            newClass.setSp(sp);
        }
        if (!this.getSubClassList().add(newClass)) {
            return false;
        }
        int level = newClass.getLevel();
        double hp = newId.getBaseHp(level);
        double mp = newId.getBaseMp(level);
        double cp = newId.getBaseCp(level);
        if (!CharacterSubclassDAO.getInstance().insert(this.getObjectId(), newClass.getClassId(), newClass.getExp(), newClass.getSp(), hp, mp, cp, hp, mp, cp, level, false, type)) {
            return false;
        }
        this.setActiveSubClass(classId, storeOld, false);
        this.rewardSkills(true, false, true, false);
        this.sendSkillList();
        this.sendSkillList();
        this.setCurrentHpMp(this.getMaxHp(), this.getMaxMp(), true);
        this.setCurrentCp(this.getMaxCp());
        ClassId oldId = oldClassId >= 0 ? ClassId.VALUES[oldClassId] : null;
        this.onReceiveNewClassId(oldId, newId);
        return true;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public boolean modifySubClass(int oldClassId, int newClassId, boolean safeExpSp) {
        TrainingCamp trainingCamp;
        SubClass originalClass = this.getSubClassList().getByClassId(oldClassId);
        if (originalClass == null || originalClass.isBase()) {
            return false;
        }
        SubClassType type = originalClass.getType();
        long exp = 0L;
        long sp = 0L;
        if (safeExpSp) {
            exp = originalClass.getExp();
            sp = originalClass.getSp();
        }
        if ((trainingCamp = TrainingCampManager.getInstance().getTrainingCamp(this)) != null && trainingCamp.getClassIndex() == originalClass.getIndex()) {
            TrainingCampManager.getInstance().removeTrainingCamp(this);
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM character_subclasses WHERE char_obj_id=? AND class_id=? AND type != " + SubClassType.BASE_CLASS.ordinal());
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, oldClassId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_skills WHERE char_obj_id=? AND class_index=? ");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, oldClassId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_skills_save WHERE char_obj_id=? AND class_index=? ");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, oldClassId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_effects_save WHERE object_id=? AND id=? ");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, oldClassId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_hennas WHERE char_obj_id=? AND class_index=? ");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, oldClassId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM character_shortcuts WHERE object_id=? AND class_index=? ");
            statement.setInt(1, this.getObjectId());
            statement.setInt(2, oldClassId);
            statement.execute();
            DbUtils.close((Statement)statement);
        }
        catch (Exception e) {
            try {
                _log.warn("Could not delete char sub-class: " + e);
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        this.getSubClassList().removeByClassId(oldClassId);
        return newClassId < 0 || this.addSubClass(oldClassId, newClassId, false, type, exp, sp);
    }

    public boolean setActiveSubClass(int subId, boolean store, boolean onRestore) {
        SubClass newActiveSub;
        SubClass oldActiveSub;
        this.abortAttack(true, false);
        this.abortCast(true, false);
        if (!onRestore && (oldActiveSub = this.getActiveSubClass()) != null) {
            this.storeDisableSkills();
            if (store) {
                oldActiveSub.setCp(this.getCurrentCp());
                oldActiveSub.setHp(this.getCurrentHp());
                oldActiveSub.setMp(this.getCurrentMp());
            }
        }
        if ((newActiveSub = this._subClassList.changeActiveSubClass(subId)) == null) {
            return false;
        }
        this.setClassId(subId, false);
        this.removeAllSkills();
        this.getAbnormalList().stopAll();
        this.deleteCubics();
        for (Servitor servitor : this.getServitors()) {
            if (servitor == null || !servitor.isSummon()) continue;
            servitor.unSummon(false);
        }
        this.restoreSkills();
        this.rewardSkills(false);
        this.checkSkills();
        this.refreshExpertisePenalty();
        this.getInventory().refreshEquip();
        this.getInventory().validateItems();
        this.getHennaList().restore();
        this.getDailyMissionList().restore();
        EffectsDAO.getInstance().restoreEffects(this);
        this.restoreDisableSkills();
        this.setCurrentCp(newActiveSub.getCp(), false);
        this.setCurrentMp(newActiveSub.getMp(), false);
        this.setCurrentHp(newActiveSub.getHp(), false);
        this.broadcastStatusUpdate();
        this.sendChanges();
        this._shortCuts.restore();
        this.sendPacket((IBroadcastPacket)new ShortCutInitPacket(this));
        this.sendActiveAutoShots();
        this.broadcastPacket(new SocialActionPacket(this.getObjectId(), 2122));
        this.setIncreasedForce(0);
        this.startHourlyTask();
        this.sendSkillList();
        this.broadcastCharInfo();
        this.updateAbnormalIcons();
        this.updateStats();
        return true;
    }

    public void startKickTask(long delayMillis) {
        this.stopKickTask();
        this._kickTask = ThreadPoolManager.getInstance().schedule(new GameObjectTasks.KickTask(this), delayMillis);
    }

    public void stopKickTask() {
        if (this._kickTask != null) {
            this._kickTask.cancel(false);
            this._kickTask = null;
        }
    }

    public boolean givePremiumAccount(PremiumAccountTemplate premiumAccount, int delay) {
        if (this.getNetConnection() == null) {
            return false;
        }
        int type = premiumAccount.getType();
        if (type == 0) {
            return false;
        }
        int expireTime = delay > 0 ? (int)((long)(delay * 60 * 60) + System.currentTimeMillis() / 1000L) : Integer.MAX_VALUE;
        boolean extended = false;
        int oldAccountType = this.getNetConnection().getPremiumAccountType();
        int oldAccountExpire = this.getNetConnection().getPremiumAccountExpire();
        if (oldAccountType == type && (long)oldAccountExpire > System.currentTimeMillis() / 1000L) {
            expireTime += (int)((long)oldAccountExpire - System.currentTimeMillis() / 1000L);
            extended = true;
        }
        if (Config.PREMIUM_ACCOUNT_BASED_ON_GAMESERVER) {
            PremiumAccountDAO.getInstance().insert(this.getAccountName(), type, expireTime);
        } else {
            if (AuthServerCommunication.getInstance().isShutdown()) {
                return false;
            }
            AuthServerCommunication.getInstance().sendPacket(new BonusRequest(this.getAccountName(), type, expireTime));
        }
        this.getNetConnection().setPremiumAccountType(type);
        this.getNetConnection().setPremiumAccountExpire(expireTime);
        if (this.startPremiumAccountTask()) {
            if (!extended) {
                if (this.getParty() != null) {
                    this.getParty().recalculatePartyData();
                }
                this.getAttendanceRewards().onReceivePremiumAccount();
                this.sendPacket((IBroadcastPacket)new ExBR_PremiumStatePacket(this, this.hasPremiumAccount()));
            }
            return true;
        }
        return false;
    }

    public boolean removePremiumAccount() {
        PremiumAccountTemplate oldPremiumAccount = this.getPremiumAccount();
        if (oldPremiumAccount.getType() == 0) {
            return false;
        }
        oldPremiumAccount.onRemove(this);
        this._premiumAccount = PremiumAccountHolder.getInstance().getPremiumAccount(0);
        if (this.getParty() != null) {
            this.getParty().recalculatePartyData();
        }
        if (Config.PREMIUM_ACCOUNT_BASED_ON_GAMESERVER) {
            PremiumAccountDAO.getInstance().delete(this.getAccountName());
        } else {
            AuthServerCommunication.getInstance().sendPacket(new BonusRequest(this.getAccountName(), 0, 0));
        }
        if (this.getNetConnection() != null) {
            this.getNetConnection().setPremiumAccountType(0);
            this.getNetConnection().setPremiumAccountExpire(0);
        }
        this.stopPremiumAccountTask();
        this.removePremiumAccountItems(true);
        this.sendPacket((IBroadcastPacket)new ExBR_PremiumStatePacket(this, this.hasPremiumAccount()));
        this.getAttendanceRewards().onRemovePremiumAccount();
        return true;
    }

    private boolean tryGiveFreePremiumAccount() {
        if (Config.FREE_PA_TYPE == 0 || Config.FREE_PA_DELAY <= 0) {
            return false;
        }
        PremiumAccountTemplate premiumAccount = PremiumAccountHolder.getInstance().getPremiumAccount(Config.FREE_PA_TYPE);
        if (premiumAccount == null) {
            return false;
        }
        boolean recieved = Boolean.parseBoolean(AccountVariablesDAO.getInstance().select(this.getAccountName(), FREE_PA_RECIEVED, "false"));
        if (recieved) {
            return false;
        }
        if (this.givePremiumAccount(premiumAccount, Config.FREE_PA_DELAY)) {
            AccountVariablesDAO.getInstance().insert(this.getAccountName(), FREE_PA_RECIEVED, "true");
            if (Config.ENABLE_FREE_PA_NOTIFICATION) {
                CustomMessage message = null;
                int accountExpire = this.getNetConnection().getPremiumAccountExpire();
                if (accountExpire != Integer.MAX_VALUE) {
                    message = new CustomMessage("l2s.gameserver.model.Player.GiveFreePA");
                    message.addString(TimeUtils.toSimpleFormat((long)accountExpire * 1000L));
                } else {
                    message = new CustomMessage("l2s.gameserver.model.Player.GiveUnlimFreePA");
                }
                this.sendPacket((IBroadcastPacket)new ExShowScreenMessage(message.toString(this), 15000, ExShowScreenMessage.ScreenMessageAlign.TOP_CENTER, true));
            }
            return true;
        }
        return false;
    }

    private boolean startPremiumAccountTask() {
        PremiumAccountTemplate premiumAccount;
        if (!Config.PREMIUM_ACCOUNT_ENABLED) {
            return false;
        }
        this.stopPremiumAccountTask();
        if (this.getNetConnection() == null) {
            return false;
        }
        int accountType = this.getNetConnection().getPremiumAccountType();
        PremiumAccountTemplate premiumAccountTemplate = premiumAccount = accountType == 0 ? null : PremiumAccountHolder.getInstance().getPremiumAccount(accountType);
        if (premiumAccount != null) {
            int accountExpire = this.getNetConnection().getPremiumAccountExpire();
            if ((long)accountExpire > System.currentTimeMillis() / 1000L) {
                this._premiumAccount = premiumAccount;
                premiumAccount.onAdd(this);
                int itemsReceivedType = this.getVarInt(PA_ITEMS_RECIEVED);
                if (itemsReceivedType != premiumAccount.getType()) {
                    this.removePremiumAccountItems(false);
                    List<ItemData> items = premiumAccount.getGiveItemsOnStart();
                    if (!items.isEmpty()) {
                        if (!this.isInventoryFull()) {
                            this.sendPacket((IBroadcastPacket)SystemMsg.THE_PREMIUM_ITEM_FOR_THIS_ACCOUNT_WAS_PROVIDED_IF_THE_PREMIUM_ACCOUNT_IS_TERMINATED_THIS_ITEM_WILL_BE_DELETED);
                            for (ItemData item : items) {
                                ItemFunctions.addItem(this, item.getId(), item.getCount(), true);
                            }
                            this.setVar(PA_ITEMS_RECIEVED, accountType);
                        } else {
                            this.sendPacket((IBroadcastPacket)SystemMsg.THE_PREMIUM_ITEM_CANNOT_BE_RECEIVED_BECAUSE_THE_INVENTORY_WEIGHTQUANTITY_LIMIT_HAS_BEEN_EXCEEDED);
                        }
                    }
                }
                if (accountExpire != Integer.MAX_VALUE) {
                    this._premiumAccountExpirationTask = LazyPrecisionTaskManager.getInstance().startPremiumAccountExpirationTask(this, accountExpire);
                }
                return true;
            }
            if (!Config.PREMIUM_ACCOUNT_BASED_ON_GAMESERVER) {
                AuthServerCommunication.getInstance().sendPacket(new BonusRequest(this.getAccountName(), 0, 0));
            }
        }
        this.removePremiumAccountItems(true);
        if (this.tryGiveFreePremiumAccount()) {
            return false;
        }
        if (Config.PREMIUM_ACCOUNT_BASED_ON_GAMESERVER) {
            PremiumAccountDAO.getInstance().delete(this.getAccountName());
        }
        if (this.getNetConnection() != null) {
            this.getNetConnection().setPremiumAccountType(0);
            this.getNetConnection().setPremiumAccountExpire(0);
        }
        return false;
    }

    private void stopPremiumAccountTask() {
        if (this._premiumAccountExpirationTask != null) {
            this._premiumAccountExpirationTask.cancel(false);
            this._premiumAccountExpirationTask = null;
        }
    }

    private void removePremiumAccountItems(boolean notify) {
        List<ItemData> items;
        PremiumAccountTemplate premiumAccount = PremiumAccountHolder.getInstance().getPremiumAccount(this.getVarInt(PA_ITEMS_RECIEVED));
        if (premiumAccount != null && !(items = premiumAccount.getTakeItemsOnEnd()).isEmpty()) {
            if (notify) {
                this.sendPacket((IBroadcastPacket)SystemMsg.THE_PREMIUM_ACCOUNT_HAS_BEEN_TERMINATED_THE_PROVIDED_PREMIUM_ITEM_WAS_DELETED);
            }
            for (ItemData item : items) {
                ItemFunctions.deleteItem((Playable)this, item.getId(), item.getCount(), notify);
            }
            for (ItemData item : items) {
                ItemFunctions.deleteItemsEverywhere(this, item.getId());
            }
        }
        this.unsetVar(PA_ITEMS_RECIEVED);
    }

    @Override
    public int getInventoryLimit() {
        return (int)this.getStat().calc(Stats.INVENTORY_LIMIT, 0.0, null, null);
    }

    public int getWarehouseLimit() {
        return (int)this.getStat().calc(Stats.STORAGE_LIMIT, 0.0, null, null);
    }

    public int getTradeLimit() {
        return (int)this.getStat().calc(Stats.TRADE_LIMIT, 0.0, null, null);
    }

    public int getDwarvenRecipeLimit() {
        return (int)this.getStat().calc(Stats.DWARVEN_RECIPE_LIMIT, 50.0, null, null) + Config.ALT_ADD_RECIPES;
    }

    public int getCommonRecipeLimit() {
        return (int)this.getStat().calc(Stats.COMMON_RECIPE_LIMIT, 50.0, null, null) + Config.ALT_ADD_RECIPES;
    }

    public boolean getAndSetLastItemAuctionRequest() {
        if (this._lastItemAuctionInfoRequest + 2000L < System.currentTimeMillis()) {
            this._lastItemAuctionInfoRequest = System.currentTimeMillis();
            return true;
        }
        this._lastItemAuctionInfoRequest = System.currentTimeMillis();
        return false;
    }

    @Override
    public int getNpcId() {
        return -2;
    }

    public GameObject getVisibleObject(int id) {
        if (this.getObjectId() == id) {
            return this;
        }
        GameObject target = null;
        if (this.getTargetId() == id) {
            target = this.getTarget();
        }
        if (target == null && this.isInParty()) {
            for (Player p : this._party.getPartyMembers()) {
                if (p == null || p.getObjectId() != id) continue;
                target = p;
                break;
            }
        }
        if (target == null) {
            target = World.getAroundObjectById(this, id);
        }
        return target == null || target.isInvisible(this) ? null : target;
    }

    @Override
    public String getTitle() {
        return super.getTitle();
    }

    public int getTitleColor() {
        return this._titlecolor;
    }

    public void setTitleColor(int titlecolor) {
        if (titlecolor != 0xFFFF77) {
            this.setVar("titlecolor", Integer.toHexString(titlecolor), -1L);
        } else {
            this.unsetVar("titlecolor");
        }
        this._titlecolor = titlecolor;
    }

    @Override
    public boolean isImmobilized() {
        return super.isImmobilized() || this.isOverloaded() || this.isSitting() || this.isFishing() || this.isInTrainingCamp();
    }

    @Override
    public boolean isBlocked() {
        return super.isBlocked() || this.isInMovie() || this.isInObserverMode() || this.isTeleporting() || this.isLogoutStarted() || this.isInTrainingCamp();
    }

    @Override
    public boolean isInvulnerable() {
        return super.isInvulnerable() || this.isInMovie() || this.isInTrainingCamp();
    }

    public void setOverloaded(boolean overloaded) {
        this._overloaded = overloaded;
    }

    public boolean isOverloaded() {
        return this._overloaded;
    }

    public boolean isFishing() {
        return this._fishing.inStarted();
    }

    public Fishing getFishing() {
        return this._fishing;
    }

    public PremiumAccountTemplate getPremiumAccount() {
        return this._premiumAccount;
    }

    public boolean hasPremiumAccount() {
        return this._premiumAccount.getType() > 0;
    }

    public boolean hasVIPAccount() {
        return this.getVIP().getLevel() > 0;
    }

    public int getPremiumAccountLeftTime() {
        GameClient client;
        if (this.hasPremiumAccount() && (client = this.getNetConnection()) != null) {
            return (int)Math.max(0L, (long)client.getPremiumAccountExpire() - System.currentTimeMillis() / 1000L);
        }
        return 0;
    }

    public double getRateAdena() {
        double rate = Config.RATE_DROP_ADENA_BY_LVL[this.getLevel()];
        rate *= this.isInParty() ? this._party.getRateAdena(this) : this.getPremiumAccount().getAdenaRate();
        rate *= this.getVIP().getTemplate().getAdenaRate();
        return rate *= 1.0 + this.getStat().calc(Stats.ADENA_RATE_MULTIPLIER, 0.0, null, null);
    }

    public double getRateItems() {
        double rate = Config.RATE_DROP_ITEMS_BY_LVL[this.getLevel()];
        rate *= this.isInParty() ? this._party.getRateDrop(this) : this.getPremiumAccount().getDropRate();
        rate *= this.getVIP().getTemplate().getDropRate();
        return rate *= 1.0 + this.getStat().calc(Stats.DROP_RATE_MULTIPLIER, 0.0, null, null);
    }

    public double getRateExp() {
        double baseRate;
        double rate = baseRate = Config.RATE_XP_BY_LVL[this.getLevel()] * (this.isInParty() ? this._party.getRateExp(this) : this.getPremiumAccount().getExpRate()) * this.getVIP().getTemplate().getExpRate();
        return rate += baseRate * this.getStat().calc(Stats.EXP_RATE_MULTIPLIER, 0.0, null, null);
    }

    public double getRateSp() {
        double baseRate;
        double rate = baseRate = Config.RATE_SP_BY_LVL[this.getLevel()] * (this.isInParty() ? this._party.getRateSp(this) : this.getPremiumAccount().getSpRate()) * this.getVIP().getTemplate().getSpRate();
        return rate += baseRate * this.getStat().calc(Stats.SP_RATE_MULTIPLIER, 0.0, null, null);
    }

    public double getRateSpoil() {
        double rate = Config.RATE_DROP_SPOIL_BY_LVL[this.getLevel()];
        rate *= this.isInParty() ? this._party.getRateSpoil(this) : this.getPremiumAccount().getSpoilRate();
        rate *= this.getVIP().getTemplate().getSpoilRate();
        return rate *= 1.0 + this.getStat().calc(Stats.SPOIL_RATE_MULTIPLIER, 0.0, null, null);
    }

    public double getRateQuestsDrop() {
        double rate = Config.RATE_QUESTS_DROP;
        rate *= this.getPremiumAccount().getQuestDropRate();
        return rate *= this.getVIP().getTemplate().getQuestDropRate();
    }

    public double getRateQuestsReward() {
        double rate = Config.RATE_QUESTS_REWARD;
        rate *= this.getPremiumAccount().getQuestRewardRate();
        return rate *= this.getVIP().getTemplate().getQuestRewardRate();
    }

    public double getDropChanceMod() {
        double mod = Config.DROP_CHANCE_MODIFIER;
        mod *= this.isInParty() ? this._party.getDropChanceMod(this) : this.getPremiumAccount().getDropChanceModifier();
        mod *= this.getVIP().getTemplate().getDropChanceModifier();
        return mod *= 1.0 + this.getStat().calc(Stats.DROP_CHANCE_MODIFIER, 0.0, null, null);
    }

    public double getDropCountMod() {
        double mod = Config.DROP_COUNT_MODIFIER;
        mod *= this.isInParty() ? this._party.getDropCountMod(this) : this.getPremiumAccount().getDropCountModifier();
        mod *= this.getVIP().getTemplate().getDropCountModifier();
        return mod *= 1.0 + this.getStat().calc(Stats.DROP_COUNT_MODIFIER, 0.0, null, null);
    }

    public double getSpoilChanceMod() {
        double mod = Config.SPOIL_CHANCE_MODIFIER;
        mod *= this.isInParty() ? this._party.getSpoilChanceMod(this) : this.getPremiumAccount().getSpoilChanceModifier();
        mod *= this.getVIP().getTemplate().getSpoilChanceModifier();
        return mod *= 1.0 + this.getStat().calc(Stats.SPOIL_CHANCE_MODIFIER, 0.0, null, null);
    }

    public double getSpoilCountMod() {
        double mod = Config.SPOIL_COUNT_MODIFIER;
        mod *= this.isInParty() ? this._party.getSpoilCountMod(this) : this.getPremiumAccount().getSpoilCountModifier();
        mod *= this.getVIP().getTemplate().getSpoilCountModifier();
        return mod *= 1.0 + this.getStat().calc(Stats.SPOIL_COUNT_MODIFIER, 0.0, null, null);
    }

    public boolean isMaried() {
        return this._maried;
    }

    public void setMaried(boolean state) {
        this._maried = state;
    }

    public void setMaryRequest(boolean state) {
        this._maryrequest = state;
    }

    public boolean isMaryRequest() {
        return this._maryrequest;
    }

    public void setMaryAccepted(boolean state) {
        this._maryaccepted = state;
    }

    public boolean isMaryAccepted() {
        return this._maryaccepted;
    }

    public int getPartnerId() {
        return this._partnerId;
    }

    public void setPartnerId(int partnerid) {
        this._partnerId = partnerid;
    }

    public int getCoupleId() {
        return this._coupleId;
    }

    public void setCoupleId(int coupleId) {
        this._coupleId = coupleId;
    }

    public void addSnooper(Player pci) {
        if (!this._snoopListenerPlayers.contains(pci)) {
            this._snoopListenerPlayers.add(pci);
        }
        if (!this._snoopListenerPlayers.isEmpty() && this._snoopListener == null) {
            this._snoopListener = new SnoopListener();
            this.addListener(this._snoopListener);
        }
    }

    public void removeSnooper(Player pci) {
        this._snoopListenerPlayers.remove(pci);
        if (this._snoopListenerPlayers.isEmpty() && this._snoopListener != null) {
            this.removeListener(this._snoopListener);
            this._snoopListener = null;
        }
    }

    public void resetReuse() {
        this._skillReuses.clear();
        this._sharedGroupReuses.clear();
    }

    public boolean isCharmOfCourage() {
        return this._charmOfCourage;
    }

    public void setCharmOfCourage(boolean val) {
        this._charmOfCourage = val;
        this.sendEtcStatusUpdate();
    }

    @Override
    public int getIncreasedForce() {
        return this._increasedForce;
    }

    @Override
    public void setIncreasedForce(int i) {
        i = Math.min(i, this.getMaxIncreasedForce());
        if ((i = Math.max(i, 0)) != 0 && i > this._increasedForce) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(323).addNumber(i));
        }
        this._increasedForce = i;
        this.sendEtcStatusUpdate();
    }

    public final boolean isFalling(int z) {
        if (!Config.DAMAGE_FROM_FALLING || this.isDead() || this.isFlying() || this.isInWater() || this.isInBoat()) {
            return false;
        }
        if (System.currentTimeMillis() < this._fallingTimestamp) {
            return true;
        }
        double deltaZ = Math.abs(this.getZ() - z);
        if (deltaZ <= this.getBaseStats().getSafeFallHeight()) {
            return false;
        }
        if (!GeoEngine.hasGeo(this.getX(), this.getY(), this.getGeoIndex())) {
            return false;
        }
        int damage = (int)this.getStat().calc(Stats.FALL, deltaZ * (double)this.getMaxHp() / 1000.0, null, null);
        if (damage > 0) {
            this.setCurrentHp(Math.max(1, (int)(this.getCurrentHp() - (double)damage)), false);
            this.sendPacket((IBroadcastPacket)new SystemMessage(296).addNumber(damage));
        }
        this.setFalling();
        return false;
    }

    public final void setFalling() {
        this._fallingTimestamp = System.currentTimeMillis() + 10000L;
    }

    @Override
    public void checkHpMessages(double curHp, double newHp) {
        int[] _hp = new int[]{30, 30};
        int[] skills = new int[]{290, 291};
        int[] _effects_skills_id = new int[]{139, 176, 292, 292, 420};
        int[] _effects_hp = new int[]{30, 30, 30, 60, 30};
        double percent = this.getMaxHp() / 100;
        double _curHpPercent = curHp / percent;
        double _newHpPercent = newHp / percent;
        boolean needsUpdate = false;
        for (int i = 0; i < skills.length; ++i) {
            int level = this.getSkillLevel(skills[i]);
            if (level <= 0) continue;
            if (_curHpPercent > (double)_hp[i] && _newHpPercent <= (double)_hp[i]) {
                this.sendPacket((IBroadcastPacket)new SystemMessage(1133).addSkillName(skills[i], level));
                needsUpdate = true;
                continue;
            }
            if (!(_curHpPercent <= (double)_hp[i]) || !(_newHpPercent > (double)_hp[i])) continue;
            this.sendPacket((IBroadcastPacket)new SystemMessage(1134).addSkillName(skills[i], level));
            needsUpdate = true;
        }
        Integer i = 0;
        while (i < _effects_skills_id.length) {
            if (this.getAbnormalList().contains(_effects_skills_id[i])) {
                if (_curHpPercent > (double)_effects_hp[i] && _newHpPercent <= (double)_effects_hp[i]) {
                    this.sendPacket((IBroadcastPacket)new SystemMessage(1133).addSkillName(_effects_skills_id[i], 1));
                    needsUpdate = true;
                } else if (_curHpPercent <= (double)_effects_hp[i] && _newHpPercent > (double)_effects_hp[i]) {
                    this.sendPacket((IBroadcastPacket)new SystemMessage(1134).addSkillName(_effects_skills_id[i], 1));
                    needsUpdate = true;
                }
            }
            Integer n = i;
            Integer n2 = i = Integer.valueOf(i + 1);
        }
        if (needsUpdate) {
            this.sendChanges();
        }
    }

    public void checkDayNightMessages() {
        int level = this.getSkillLevel(294);
        if (level > 0) {
            if (GameTimeController.getInstance().isNowNight()) {
                this.sendPacket((IBroadcastPacket)new SystemMessage(1131).addSkillName(294, level));
            } else {
                this.sendPacket((IBroadcastPacket)new SystemMessage(1132).addSkillName(294, level));
            }
        }
        this.sendChanges();
    }

    public int getZoneMask() {
        return this._zoneMask;
    }

    @Override
    protected void onUpdateZones(List<Zone> leaving, List<Zone> entering) {
        super.onUpdateZones(leaving, entering);
        if ((leaving == null || leaving.isEmpty()) && (entering == null || entering.isEmpty())) {
            return;
        }
        boolean lastInCombatZone = (this._zoneMask & 0x4000) == 16384;
        boolean lastInDangerArea = (this._zoneMask & 0x100) == 256;
        boolean lastOnSiegeField = (this._zoneMask & 0x800) == 2048;
        boolean lastInPeaceZone = (this._zoneMask & 0x1000) == 4096;
        boolean isInCombatZone = this.isInZoneBattle();
        boolean isInDangerArea = this.isInDangerArea() || this.isInZone(Zone.ZoneType.CHANGED_ZONE);
        boolean isOnSiegeField = this.isInSiegeZone();
        boolean isInPeaceZone = this.isInPeaceZone();
        boolean isInSSQZone = this.isInSSQZone();
        int lastZoneMask = this._zoneMask;
        this._zoneMask = 0;
        if (isInCombatZone) {
            this._zoneMask |= 0x4000;
        }
        if (isInDangerArea) {
            this._zoneMask |= 0x100;
        }
        if (isOnSiegeField) {
            this._zoneMask |= 0x800;
        }
        if (isInPeaceZone) {
            this._zoneMask |= 0x1000;
        }
        if (isInSSQZone) {
            this._zoneMask |= 0x2000;
        }
        if (lastZoneMask != this._zoneMask) {
            this.sendPacket((IBroadcastPacket)new ExSetCompassZoneCode(this));
        }
        boolean broadcastRelation = false;
        if (lastInCombatZone != isInCombatZone) {
            broadcastRelation = true;
        }
        if (lastInDangerArea != isInDangerArea) {
            this.sendPacket((IBroadcastPacket)new EtcStatusUpdatePacket(this));
        }
        if (lastOnSiegeField != isOnSiegeField) {
            broadcastRelation = true;
            if (isOnSiegeField) {
                this.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ENTERED_A_COMBAT_ZONE);
            } else {
                FlagItemAttachment attachment = this.getActiveWeaponFlagAttachment();
                if (attachment != null) {
                    attachment.onLeaveSiegeZone(this);
                }
                this.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_LEFT_A_COMBAT_ZONE);
                if (!this.isTeleporting() && this.getPvpFlag() == 0) {
                    this.startPvPFlag(null);
                }
            }
        }
        if (broadcastRelation) {
            this.broadcastRelation();
        }
        if (this.isInWater()) {
            this.startWaterTask();
        } else {
            this.stopWaterTask();
        }
    }

    public void startAutoSaveTask() {
        if (!Config.AUTOSAVE) {
            return;
        }
        if (this._autoSaveTask == null) {
            this._autoSaveTask = AutoSaveManager.getInstance().addAutoSaveTask(this);
        }
    }

    public void stopAutoSaveTask() {
        if (this._autoSaveTask != null) {
            this._autoSaveTask.cancel(false);
        }
        this._autoSaveTask = null;
    }

    public void startPcBangPointsTask() {
        if (!Config.ALT_PCBANG_POINTS_ENABLED || Config.ALT_PCBANG_POINTS_DELAY <= 0) {
            return;
        }
        if (this._pcCafePointsTask == null) {
            this._pcCafePointsTask = LazyPrecisionTaskManager.getInstance().addPCCafePointsTask(this);
        }
    }

    public void stopPcBangPointsTask() {
        if (this._pcCafePointsTask != null) {
            this._pcCafePointsTask.cancel(false);
        }
        this._pcCafePointsTask = null;
    }

    public void startUnjailTask(Player player, int time) {
        if (this._unjailTask != null) {
            this._unjailTask.cancel(false);
        }
        this._unjailTask = ThreadPoolManager.getInstance().schedule(new GameObjectTasks.UnJailTask(player), time * 60000);
    }

    public void stopUnjailTask() {
        if (this._unjailTask != null) {
            this._unjailTask.cancel(false);
        }
        this._unjailTask = null;
    }

    public void startTrainingCampTask(long timeRemaining) {
        if (this._trainingCampTask == null && this.isInTrainingCamp()) {
            this._trainingCampTask = ThreadPoolManager.getInstance().schedule(() -> TrainingCampManager.getInstance().onExitTrainingCamp(this), timeRemaining);
        }
    }

    public void stopTrainingCampTask() {
        if (this._trainingCampTask != null) {
            this._trainingCampTask.cancel(false);
            this._trainingCampTask = null;
        }
    }

    public boolean isInTrainingCamp() {
        TrainingCamp trainingCamp = TrainingCampManager.getInstance().getTrainingCamp(this);
        return trainingCamp != null && trainingCamp.isTraining() && trainingCamp.isValid(this);
    }

    @Override
    public void sendMessage(String message) {
        this.sendPacket((IBroadcastPacket)new SystemMessage(message));
    }

    public void setUseSeed(int id) {
        this._useSeed = id;
    }

    public int getUseSeed() {
        return this._useSeed;
    }

    @Override
    public int getRelation(Player target) {
        ClanWar war;
        Clan clan = this.getClan();
        Party party = this.getParty();
        Clan targetClan = target.getClan();
        int result = 0;
        if (this.isInZoneBattle()) {
            result |= 1;
        }
        if (this.isPK()) {
            result |= 4;
        }
        if (this.getPvpFlag() != 0) {
            result |= 2;
        }
        if (clan != null) {
            Alliance ally;
            result |= 0x40;
            if (clan == targetClan) {
                result |= 0x100;
            }
            if ((ally = clan.getAlliance()) != null) {
                result |= 0x10000;
                if (ally.getAllyId() == target.getAllyId()) {
                    result |= 0x40000;
                }
            }
            if (this.isClanLeader()) {
                result |= 0x80;
                if (ally != null && clan == ally.getLeader()) {
                    result |= 0x20000;
                }
            }
        }
        if (party != null) {
            result |= 8;
            if (party.isLeader(this)) {
                result |= 0x10;
            }
            if (party == target.getParty()) {
                result |= 0x20;
            }
        }
        if (clan != null && targetClan != null && this.getPledgeType() != -1 && target.getPledgeType() != -1 && (war = clan.getWarWith(target.getClanId())) != null) {
            switch (war.getPeriod()) {
                case PREPARATION: {
                    if (war.isAttacker(clan)) {
                        result |= 0x4000;
                        break;
                    }
                    if (!war.isAttacked(clan)) break;
                    result |= 0x8000;
                    break;
                }
                case MUTUAL: {
                    result |= 0x4000;
                    result |= 0x8000;
                }
            }
        }
        for (Event e : this.getEvents()) {
            result = e.getRelation(this, target, result);
        }
        return result;
    }

    public long getLastPvPAttack() {
        return this.isVioletBoy() ? System.currentTimeMillis() : this._lastPvPAttack;
    }

    public void setLastPvPAttack(long time) {
        this._lastPvPAttack = time;
    }

    @Override
    public void startPvPFlag(Creature target) {
        if (this.isPK() || this.isVioletBoy()) {
            return;
        }
        long startTime = System.currentTimeMillis();
        if (target != null && target.getPvpFlag() != 0) {
            startTime -= (long)(Config.PVP_TIME / 2);
        }
        if (this.getPvpFlag() != 0 && this.getLastPvPAttack() >= startTime) {
            return;
        }
        this._lastPvPAttack = startTime;
        this.updatePvPFlag(1);
        if (this._PvPRegTask == null) {
            this._PvPRegTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new GameObjectTasks.PvPFlagTask(this), 1000L, 1000L);
        }
    }

    public void stopPvPFlag() {
        if (this._PvPRegTask != null) {
            this._PvPRegTask.cancel(false);
            this._PvPRegTask = null;
        }
        this.updatePvPFlag(0);
    }

    public void updatePvPFlag(int value) {
        if (this.getPvpFlag() == value) {
            return;
        }
        this.setPvpFlag(value);
        this.sendStatusUpdate(true, true, 26);
        this.broadcastRelation();
    }

    public void setPvpFlag(int pvpFlag) {
        this._pvpFlag = pvpFlag;
    }

    @Override
    public int getPvpFlag() {
        return this.isVioletBoy() ? 1 : this._pvpFlag;
    }

    public boolean isInDuel() {
        return this.containsEvent(DuelEvent.class);
    }

    public long getLastAttackPacket() {
        return this._lastAttackPacket;
    }

    public void setLastAttackPacket() {
        this._lastAttackPacket = System.currentTimeMillis();
    }

    public long getLastMovePacket() {
        return this._lastMovePacket;
    }

    public void setLastMovePacket() {
        this._lastMovePacket = System.currentTimeMillis();
    }

    public byte[] getKeyBindings() {
        return this._keyBindings;
    }

    public void setKeyBindings(byte[] keyBindings) {
        if (keyBindings == null) {
            keyBindings = ArrayUtils.EMPTY_BYTE_ARRAY;
        }
        this._keyBindings = keyBindings;
    }

    @Override
    public final Collection<SkillEntry> getAllSkills() {
        if (!this.isTransformed()) {
            return super.getAllSkills();
        }
        HashIntObjectMap temp = new HashIntObjectMap();
        for (SkillEntry skillEntry : super.getAllSkills()) {
            Skill skill = skillEntry.getTemplate();
            if (skill.isActive() || skill.isToggle()) continue;
            temp.put(skillEntry.getId(), skillEntry);
        }
        temp.putAll(this._transformSkills);
        return temp.valueCollection();
    }

    public final void addTransformSkill(SkillEntry skillEntry) {
        this._transformSkills.put(skillEntry.getId(), skillEntry);
    }

    public final void removeTransformSkill(SkillEntry skillEntry) {
        this._transformSkills.remove(skillEntry.getId());
    }

    public void deleteAgathion() {
        if (this._agathion != null) {
            this._agathion.delete();
        }
    }

    public void setAgathion(Agathion agathion) {
        if (this._agathion == agathion) {
            return;
        }
        this._agathion = agathion;
        this.sendPacket((IBroadcastPacket)new ExUserInfoCubic(this));
        this.broadcastCharInfo();
    }

    public Agathion getAgathion() {
        return this._agathion;
    }

    public int getAgathionId() {
        return this._agathion == null ? 0 : this._agathion.getId();
    }

    public int getAgathionNpcId() {
        return this._agathion == null ? 0 : this._agathion.getNpcId();
    }

    public int getPcBangPoints() {
        return this._pcBangPoints;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     * Enabled aggressive block sorting
     * Enabled unnecessary exception pruning
     * Enabled aggressive exception aggregation
     */
    public void setPcBangPoints(int val, boolean store) {
        this._pcBangPoints = val;
        if (!store) return;
        if (Config.PC_BANG_POINTS_BY_ACCOUNT) {
            AccountVariablesDAO.getInstance().insert(this.getAccountName(), PC_BANG_POINTS_VAR, String.valueOf(this.getPcBangPoints()));
            return;
        }
        Connection con = null;
        PreparedStatement st = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            st = con.prepareStatement("UPDATE characters SET pcBangPoints = ? WHERE obj_Id = ?");
            st.setInt(1, this.getPcBangPoints());
            st.setInt(2, this.getObjectId());
            st.executeUpdate();
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, st);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)st);
            return;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)st);
        return;
    }

    public void addPcBangPoints(int count, boolean doublePoints, boolean notify) {
        if (doublePoints) {
            count *= 2;
        }
        this.setPcBangPoints(this.getPcBangPoints() + count, true);
        if (count > 0 && notify) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(doublePoints ? 1708 : 1707).addNumber(count));
        }
        this.sendPacket((IBroadcastPacket)new ExPCCafePointInfoPacket(this, count, 1, 2, 12));
    }

    public boolean reducePcBangPoints(int count, boolean notify) {
        if (this.getPcBangPoints() < count) {
            return false;
        }
        this.setPcBangPoints(this.getPcBangPoints() - count, true);
        if (notify) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(1709).addNumber(count));
        }
        this.sendPacket((IBroadcastPacket)new ExPCCafePointInfoPacket(this, 0, 1, 2, 12));
        return true;
    }

    public void setGroundSkillLoc(Location location) {
        this._groundSkillLoc = location;
    }

    public Location getGroundSkillLoc() {
        return this._groundSkillLoc;
    }

    public boolean isLogoutStarted() {
        if (this._isLogout == null) {
            return false;
        }
        return this._isLogout.get();
    }

    public void setOfflineMode(boolean val) {
        if (val == this.isInOfflineMode()) {
            return;
        }
        GameObjectsStorage.remove(this);
        this._offlineStartTime = val ? System.currentTimeMillis() : 0L;
        GameObjectsStorage.put(this);
        if (!this.isInOfflineMode()) {
            this.unsetVar("offline");
        }
    }

    public boolean isInOfflineMode() {
        return this._offlineStartTime > 0L;
    }

    public void storePrivateStore() {
        int storeType = this.getPrivateStoreType();
        if (storeType == 0) {
            this.unsetVar("storemode");
        } else if (Config.ALT_SAVE_PRIVATE_STORE || this.isInOfflineMode()) {
            this.setVar("storemode", storeType);
        }
        List<TradeItem> buyList = this.getBuyList();
        if (!buyList.isEmpty() && (Config.ALT_SAVE_PRIVATE_STORE || this.isInOfflineMode() && storeType == 3)) {
            if (CharacterPrivateStoreDAO.getInstance().insertBuys(this, buyList)) {
                String title = this.getBuyStoreName();
                if (title != null && !title.isEmpty()) {
                    this.setVar("buystorename", title, -1L);
                } else {
                    this.unsetVar("buystorename");
                }
            } else {
                this.unsetVar("buystorename");
            }
        } else {
            CharacterPrivateStoreDAO.getInstance().deleteBuys(this);
            this.unsetVar("buystorename");
        }
        Map<Integer, TradeItem> sellList = this.getSellList(false);
        if (!sellList.isEmpty() && (Config.ALT_SAVE_PRIVATE_STORE || this.isInOfflineMode() && storeType == 1)) {
            if (CharacterPrivateStoreDAO.getInstance().insertSells(this, sellList, false)) {
                String title = this.getSellStoreName();
                if (title != null && !title.isEmpty()) {
                    this.setVar("sellstorename", title, -1L);
                } else {
                    this.unsetVar("sellstorename");
                }
            } else {
                this.unsetVar("sellstorename");
            }
        } else {
            CharacterPrivateStoreDAO.getInstance().deleteSells(this, false);
            this.unsetVar("sellstorename");
        }
        Map<Integer, TradeItem> packageSellList = this.getSellList(true);
        if (!packageSellList.isEmpty() && (Config.ALT_SAVE_PRIVATE_STORE || this.isInOfflineMode() && storeType == 8)) {
            if (CharacterPrivateStoreDAO.getInstance().insertSells(this, packageSellList, true)) {
                String title = this.getPackageSellStoreName();
                if (title != null && !title.isEmpty()) {
                    this.setVar("packagesellstorename", title, -1L);
                } else {
                    this.unsetVar("packagesellstorename");
                }
            } else {
                this.unsetVar("packagesellstorename");
            }
        } else {
            CharacterPrivateStoreDAO.getInstance().deleteSells(this, true);
            this.unsetVar("packagesellstorename");
        }
        Map<Integer, ManufactureItem> createList = this.getCreateList();
        if (!createList.isEmpty() && (Config.ALT_SAVE_PRIVATE_STORE || this.isInOfflineMode() && storeType == 5)) {
            if (CharacterPrivateStoreDAO.getInstance().insertManufactures(this, createList)) {
                String title = this.getManufactureName();
                if (title != null && !title.isEmpty()) {
                    this.setVar("manufacturename", title, -1L);
                } else {
                    this.unsetVar("manufacturename");
                }
            } else {
                this.unsetVar("manufacturename");
            }
        } else {
            CharacterPrivateStoreDAO.getInstance().deleteManufactures(this);
            this.unsetVar("manufacturename");
        }
    }

    public void restorePrivateStore() {
        int storeType;
        Map<Integer, ManufactureItem> createList;
        Map<Integer, TradeItem> packageSellList;
        Map<Integer, TradeItem> sellList;
        List<TradeItem> buyList = CharacterPrivateStoreDAO.getInstance().selectBuys(this);
        if (!buyList.isEmpty()) {
            this.setBuyList(buyList);
            String name = this.getVar("buystorename");
            if (name != null) {
                this.setBuyStoreName(name);
            }
        }
        if (!(sellList = CharacterPrivateStoreDAO.getInstance().selectSells(this, false)).isEmpty()) {
            this.setSellList(false, sellList);
            String name = this.getVar("sellstorename");
            if (name != null) {
                this.setSellStoreName(name);
            }
        }
        if (!(packageSellList = CharacterPrivateStoreDAO.getInstance().selectSells(this, true)).isEmpty()) {
            this.setSellList(true, packageSellList);
            String name = this.getVar("packagesellstorename");
            if (name != null) {
                this.setPackageSellStoreName(name);
            }
        }
        if (!(createList = CharacterPrivateStoreDAO.getInstance().selectManufactures(this)).isEmpty()) {
            this.setCreateList(createList);
            String name = this.getVar("manufacturename");
            if (name != null) {
                this.setManufactureName(name);
            }
        }
        if ((storeType = this.getVarInt("storemode", 0)) != 0) {
            this.setPrivateStoreType(storeType);
            this.setSitting(true);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restoreRecipeBook() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT id FROM character_recipebook WHERE char_id=?");
            statement.setInt(1, this.getObjectId());
            rset = statement.executeQuery();
            while (rset.next()) {
                int id = rset.getInt("id");
                RecipeTemplate recipe = RecipeHolder.getInstance().getRecipeByRecipeId(id);
                this.registerRecipe(recipe, false);
            }
        }
        catch (Exception e) {
            try {
                _log.warn("count not recipe skills:" + e);
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public List<DecoyInstance> getDecoys() {
        return this._decoys;
    }

    public void addDecoy(DecoyInstance decoy) {
        this._decoys.add(decoy);
    }

    public void removeDecoy(DecoyInstance decoy) {
        this._decoys.remove(decoy);
    }

    public MountType getMountType() {
        return this._mount == null ? MountType.NONE : this._mount.getType();
    }

    @Override
    public boolean setReflection(Reflection reflection) {
        if (this.getReflection() == reflection) {
            return true;
        }
        if (!super.setReflection(reflection)) {
            return false;
        }
        for (Servitor servitor : this.getServitors()) {
            if (servitor.isDead()) continue;
            servitor.setReflection(reflection);
        }
        if (!reflection.isMain()) {
            String var = this.getVar("reflection");
            if (var == null || !var.equals(String.valueOf(reflection.getId()))) {
                this.setVar("reflection", String.valueOf(reflection.getId()), -1L);
            }
        } else {
            this.unsetVar("reflection");
        }
        return true;
    }

    public void setBuyListId(int listId) {
        this._buyListId = listId;
    }

    public int getBuyListId() {
        return this._buyListId;
    }

    public int getFame() {
        return this._fame;
    }

    public void setFame(int fame, String log, boolean notify) {
        fame = Math.min(Config.LIM_FAME, fame);
        if (log != null && !log.isEmpty()) {
            Log.add(this._name + "|" + (fame - this._fame) + "|" + fame + "|" + log, "fame");
        }
        if (fame > this._fame && notify) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(2319).addNumber(fame - this._fame));
        }
        this._fame = fame;
        this.sendChanges();
    }

    public int getIncorrectValidateCount() {
        return 0;
    }

    public int setIncorrectValidateCount(int count) {
        return 0;
    }

    public int getExpandInventory() {
        return this._expandInventory;
    }

    public void setExpandInventory(int inventory) {
        this._expandInventory = inventory;
    }

    public int getExpandWarehouse() {
        return this._expandWarehouse;
    }

    public void setExpandWarehouse(int warehouse) {
        this._expandWarehouse = warehouse;
    }

    public boolean isNotShowBuffAnim() {
        return this._notShowBuffAnim;
    }

    public void setNotShowBuffAnim(boolean value) {
        this._notShowBuffAnim = value;
    }

    public boolean canSeeAllShouts() {
        return this._canSeeAllShouts;
    }

    public void setCanSeeAllShouts(boolean b) {
        this._canSeeAllShouts = b;
    }

    public void enterMovieMode() {
        if (this.isInMovie()) {
            return;
        }
        this.abortAttack(true, false);
        this.abortCast(true, false);
        this.setTarget(null);
        this.getMovement().stopMove();
        this.setMovieId(-1);
        this.sendPacket((IBroadcastPacket)CameraModePacket.ENTER);
    }

    public void leaveMovieMode() {
        this.setMovieId(0);
        this.sendPacket((IBroadcastPacket)CameraModePacket.EXIT);
        this.broadcastUserInfo(true);
    }

    public void specialCamera(GameObject target, int dist, int yaw, int pitch, int time, int duration) {
        this.sendPacket((IBroadcastPacket)new SpecialCameraPacket(target.getObjectId(), dist, yaw, pitch, time, duration));
    }

    public void specialCamera(GameObject target, int dist, int yaw, int pitch, int time, int duration, int turn, int rise, int widescreen, int unk) {
        this.sendPacket((IBroadcastPacket)new SpecialCameraPacket(target.getObjectId(), dist, yaw, pitch, time, duration, turn, rise, widescreen, unk));
    }

    public void setMovieId(int id) {
        this._movieId = id;
    }

    public int getMovieId() {
        return this._movieId;
    }

    public boolean isInMovie() {
        return this._movieId != 0 && !this.isFakePlayer();
    }

    public void startScenePlayer(SceneMovie movie) {
        if (this.isInMovie()) {
            return;
        }
        this.sendActionFailed();
        this.setTarget(null);
        this.getMovement().stopMove();
        this.setMovieId(movie.getId());
        this.sendPacket((IBroadcastPacket)movie.packet(this));
        this._sceneMovieEndTask = ThreadPoolManager.getInstance().schedule(() -> {
            if (this._sceneMovieEndTask != null) {
                this._sceneMovieEndTask.cancel(false);
                this._sceneMovieEndTask = null;
            }
            this.endScenePlayer(true);
        }, (long)movie.getDuration() + 500L);
    }

    public void startScenePlayer(int movieId) {
        SceneMovie movie = SceneMovie.getMovie(movieId);
        if (movie != null) {
            this.startScenePlayer(movie);
        }
    }

    public void endScenePlayer(boolean force) {
        if (!this.isInMovie()) {
            return;
        }
        SceneMovie movie = SceneMovie.getMovie(this.getMovieId());
        if (movie != null ? force && !movie.isCancellable() && this._sceneMovieEndTask != null : force) {
            return;
        }
        if (this._sceneMovieEndTask != null) {
            this._sceneMovieEndTask.cancel(false);
            this._sceneMovieEndTask = null;
        }
        this.setMovieId(0);
        if (force && movie != null) {
            this.sendPacket((IBroadcastPacket)new ExStopScenePlayerPacket(movie.getId()));
        }
    }

    public void setAutoLoot(boolean enable) {
        if (Config.AUTO_LOOT_INDIVIDUAL) {
            this._autoLoot = enable;
            this.setVar("AutoLoot", String.valueOf(enable), -1L);
        }
    }

    public void setAutoLootOnlyAdena(boolean enable) {
        if (Config.AUTO_LOOT_INDIVIDUAL && Config.AUTO_LOOT_ONLY_ADENA) {
            this._autoLootOnlyAdena = enable;
            this.setVar("AutoLootOnlyAdena", String.valueOf(enable), -1L);
        }
    }

    public void setAutoLootHerbs(boolean enable) {
        if (Config.AUTO_LOOT_INDIVIDUAL) {
            this.AutoLootHerbs = enable;
            this.setVar("AutoLootHerbs", String.valueOf(enable), -1L);
        }
    }

    public boolean isAutoLootEnabled() {
        return this._autoLoot;
    }

    public boolean isAutoLootOnlyAdenaEnabled() {
        return this._autoLootOnlyAdena;
    }

    public boolean isAutoLootHerbsEnabled() {
        return this.AutoLootHerbs;
    }

    public final void reName(String name, boolean saveToDB) {
        Clan clan;
        this.setName(name);
        if (saveToDB) {
            this.saveNameToDB();
            OlympiadParticipiantData participant = Olympiad.getParticipantInfo(this.getObjectId());
            if (participant != null) {
                participant.setName(name);
            }
        }
        this.sendUserInfo(true);
        for (Player p : World.getAroundObservers(this)) {
            p.sendPacket(p.removeVisibleObject(this, null));
            if (this.isVisible() && !this.isInvisible(p)) {
                p.sendPacket(p.addVisibleObject(this, null));
            }
            p.getFriendList().notifyChangeName(this.getObjectId());
            p.getBlockList().notifyChangeName(this.getObjectId());
        }
        Party party = this.getParty();
        if (party != null) {
            party.updatePartyInfo();
        }
        if ((clan = this.getClan()) != null) {
            clan.broadcastClanStatus(true, false, false);
        }
    }

    public final void reName(String name) {
        this.reName(name, false);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public final void saveNameToDB() {
        Connection con = null;
        PreparedStatement st = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            st = con.prepareStatement("UPDATE characters SET char_name = ? WHERE obj_Id = ?");
            st.setString(1, this.getName());
            st.setInt(2, this.getObjectId());
            st.executeUpdate();
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, st);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)st);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)st);
    }

    @Override
    public Player getPlayer() {
        return this;
    }

    public BypassStorage getBypassStorage() {
        return this._bypassStorage;
    }

    public int getTalismanCount() {
        return (int)this.getStat().calc(Stats.TALISMANS_LIMIT, 0.0, null, null);
    }

    public int getJewelsLimit() {
        return (int)this.getStat().calc(Stats.JEWELS_LIMIT, 0.0, null, null);
    }

    public int getAgathionsLimit() {
        return (int)this.getStat().calc(Stats.AGATHIONS_LIMIT, 0.0, null, null);
    }

    public boolean isActiveMainAgathionSlot() {
        return this.getAgathionsLimit() > 0;
    }

    public int getSubAgathionsLimit() {
        return this.getAgathionsLimit() - 1;
    }

    public final void disableDrop(int time) {
        this._dropDisabled = System.currentTimeMillis() + (long)time;
    }

    public final boolean isDropDisabled() {
        return this._dropDisabled > System.currentTimeMillis();
    }

    public void setPetControlItem(int itemObjId) {
        this.setPetControlItem(this.getInventory().getItemByObjectId(itemObjId));
    }

    public void setPetControlItem(ItemInstance item) {
        this._petControlItem = item;
    }

    public ItemInstance getPetControlItem() {
        return this._petControlItem;
    }

    public boolean isActive() {
        return this.isActive.get();
    }

    public void setActive() {
        this.endScenePlayer(true);
        this.setNonAggroTime(0L);
        this.setNonPvpTime(0L);
        if (this.isActive.getAndSet(true)) {
            return;
        }
        this.onActive();
    }

    private void onActive() {
        this.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_NO_LONGER_PROTECTED_FROM_AGGRESSIVE_MONSTERS);
        if (this.getPetControlItem() != null || this._restoredSummons != null && !this._restoredSummons.isEmpty()) {
            ThreadPoolManager.getInstance().execute(() -> {
                if (this.getPetControlItem() != null) {
                    this.summonPet();
                }
                if (this._restoredSummons != null && !this._restoredSummons.isEmpty()) {
                    this.spawnRestoredSummons();
                }
            });
        }
        this.broadcastRelation();
    }

    public void summonPet() {
        if (this.getPet() != null) {
            return;
        }
        ItemInstance controlItem = this.getInventory().getItemByObjectId(this.getPetControlItem().getObjectId());
        if (controlItem == null) {
            this.setPetControlItem(null);
            return;
        }
        PetData petTemplate = PetDataHolder.getInstance().getTemplateByItemId(controlItem.getItemId());
        if (petTemplate == null) {
            this.setPetControlItem(null);
            return;
        }
        NpcTemplate npcTemplate = NpcHolder.getInstance().getTemplate(petTemplate.getNpcId());
        if (npcTemplate == null) {
            this.setPetControlItem(null);
            return;
        }
        PetInstance pet = PetInstance.restore(controlItem, npcTemplate, this);
        if (pet == null) {
            this.setPetControlItem(null);
            return;
        }
        this.setPet(pet);
        pet.setTitle("%OWNER_NAME%");
        if (!pet.isRespawned()) {
            pet.setCurrentHp(pet.getMaxHp(), false);
            pet.setCurrentMp(pet.getMaxMp());
            pet.setCurrentFed(pet.getMaxFed(), false);
            pet.updateControlItem();
            pet.store();
        }
        pet.getInventory().restore();
        pet.setNonAggroTime(System.currentTimeMillis() + Config.NONAGGRO_TIME_ONTELEPORT);
        pet.setNonPvpTime(System.currentTimeMillis() + Config.NONPVP_TIME_ONTELEPORT);
        pet.setReflection(this.getReflection());
        pet.spawnMe(Location.findPointToStay(this, 50, 70));
        pet.setRunning();
        pet.setFollowMode(true);
        pet.getInventory().validateItems();
        if (pet instanceof PetBabyInstance) {
            ((PetBabyInstance)pet).startBuffTask();
        }
        this.getListeners().onSummonServitor(pet);
    }

    public void restoreSummons() {
        this._restoredSummons = SummonsDAO.getInstance().restore(this);
    }

    private void spawnRestoredSummons() {
        if (this._restoredSummons == null || this._restoredSummons.isEmpty()) {
            return;
        }
        for (SummonInstance.RestoredSummon summon : this._restoredSummons) {
            Skill skill = SkillHolder.getInstance().getSkill(summon.skillId, summon.skillLvl);
            if (skill == null || !(skill instanceof Summon)) continue;
            ((Summon)skill).summon(this, null, summon);
        }
        this._restoredSummons.clear();
        this._restoredSummons = null;
    }

    public List<TrapInstance> getTraps() {
        return this._traps;
    }

    public void addTrap(TrapInstance trap) {
        if (this._traps == (List)Collections.emptyList()) {
            this._traps = new CopyOnWriteArrayList<TrapInstance>();
        }
        this._traps.add(trap);
    }

    public void removeTrap(TrapInstance trap) {
        this._traps.remove(trap);
    }

    public void destroyAllTraps() {
        for (TrapInstance t : this._traps) {
            t.deleteMe();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public PlayerListenerList getListeners() {
        if (this.listeners == null) {
            Player player = this;
            synchronized (player) {
                if (this.listeners == null) {
                    this.listeners = new PlayerListenerList(this);
                }
            }
        }
        return (PlayerListenerList)this.listeners;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public PlayerStatsChangeRecorder getStatsRecorder() {
        if (this._statsRecorder == null) {
            Player player = this;
            synchronized (player) {
                if (this._statsRecorder == null) {
                    this._statsRecorder = new PlayerStatsChangeRecorder(this);
                }
            }
        }
        return (PlayerStatsChangeRecorder)this._statsRecorder;
    }

    public AtomicInteger getHoursInGame() {
        return this._hoursInGame;
    }

    public void startHourlyTask() {
        this._hourlyTask = ThreadPoolManager.getInstance().scheduleAtFixedRate(new GameObjectTasks.HourlyTask(this), TimeUnit.HOURS.toMillis(1L), TimeUnit.HOURS.toMillis(1L));
    }

    public void stopHourlyTask() {
        if (this._hourlyTask != null) {
            this._hourlyTask.cancel(false);
            this._hourlyTask = null;
        }
    }

    public long getPremiumPoints() {
        if (Config.IM_PAYMENT_ITEM_ID > 0) {
            return ItemFunctions.getItemCount(this, Config.IM_PAYMENT_ITEM_ID);
        }
        if (this.getNetConnection() != null) {
            return this.getNetConnection().getPoints();
        }
        return 0L;
    }

    public boolean addPremiumPoints(int val) {
        if (Config.IM_PAYMENT_ITEM_ID > 0) {
            return !ItemFunctions.addItem(this, Config.IM_PAYMENT_ITEM_ID, val, true).isEmpty();
        }
        if (this.getNetConnection() != null) {
            this.getNetConnection().setPoints((int)(this.getPremiumPoints() + (long)val));
            AuthServerCommunication.getInstance().sendPacket(new ReduceAccountPoints(this.getAccountName(), -val));
            return true;
        }
        return false;
    }

    public boolean reducePremiumPoints(int val) {
        if (Config.IM_PAYMENT_ITEM_ID > 0) {
            return ItemFunctions.deleteItem((Playable)this, Config.IM_PAYMENT_ITEM_ID, (long)val, true);
        }
        if (this.getNetConnection() != null) {
            this.getNetConnection().setPoints((int)(this.getPremiumPoints() - (long)val));
            AuthServerCommunication.getInstance().sendPacket(new ReduceAccountPoints(this.getAccountName(), val));
            return true;
        }
        return false;
    }

    public boolean isAgathionResAvailable() {
        return this._agathionResAvailable;
    }

    public void setAgathionRes(boolean val) {
        this._agathionResAvailable = val;
    }

    public String getSessionVar(String key) {
        if (this._userSession == null) {
            return null;
        }
        return this._userSession.get(key);
    }

    public void setSessionVar(String key, String val) {
        if (this._userSession == null) {
            this._userSession = new ConcurrentHashMap<String, String>();
        }
        if (val == null || val.isEmpty()) {
            this._userSession.remove(key);
        } else {
            this._userSession.put(key, val);
        }
    }

    public BlockList getBlockList() {
        return this._blockList;
    }

    public FriendList getFriendList() {
        return this._friendList;
    }

    public PremiumItemList getPremiumItemList() {
        return this._premiumItemList;
    }

    public ProductHistoryList getProductHistoryList() {
        return this._productHistoryList;
    }

    public HennaList getHennaList() {
        return this._hennaList;
    }

    public AttendanceRewards getAttendanceRewards() {
        return this._attendanceRewards;
    }

    public DailyMissionList getDailyMissionList() {
        return this._dailiyMissionList;
    }

    public VIP getVIP() {
        return this._vip;
    }

    public boolean isNotShowTraders() {
        return this._notShowTraders;
    }

    public void setNotShowTraders(boolean notShowTraders) {
        this._notShowTraders = notShowTraders;
    }

    public boolean isDebug() {
        return this._debug && (Config.ALT_DEBUG_ENABLED || this.getPlayerAccess().CanDebug);
    }

    public void setDebug(boolean b) {
        this._debug = b;
    }

    public void sendItemList(boolean show) {
        ItemInstance[] items = this.getInventory().getItems();
        LockType lockType = this.getInventory().getLockType();
        int[] lockItems = this.getInventory().getLockItems();
        int allSize = items.length;
        int questItemsSize = 0;
        int agathionItemsSize = 0;
        for (ItemInstance item : items) {
            if (item.getTemplate().isQuest()) {
                ++questItemsSize;
            }
            if (item.getTemplate().getAgathionMaxEnergy() <= 0) continue;
            ++agathionItemsSize;
        }
        this.sendPacket((IBroadcastPacket)new ItemListPacket(1, this, allSize - questItemsSize, items, show, lockType, lockItems));
        if (allSize - questItemsSize > 0) {
            this.sendPacket((IBroadcastPacket)new ItemListPacket(2, this, allSize - questItemsSize, items, show, lockType, lockItems));
        }
        this.sendPacket((IBroadcastPacket)new ExQuestItemListPacket(1, questItemsSize, items, lockType, lockItems));
        if (questItemsSize > 0) {
            this.sendPacket((IBroadcastPacket)new ExQuestItemListPacket(2, questItemsSize, items, lockType, lockItems));
        }
        if (agathionItemsSize > 0) {
            this.sendPacket((IBroadcastPacket)new ExBR_AgathionEnergyInfoPacket(agathionItemsSize, items));
        }
    }

    public int getBeltInventoryIncrease() {
        ItemInstance item = this.getInventory().getPaperdollItem(30);
        if (item != null && item.getTemplate().getAttachedSkills() != null) {
            for (SkillEntry skillEntry : item.getTemplate().getAttachedSkills()) {
                for (FuncTemplate func : skillEntry.getTemplate().getAttachedFuncs()) {
                    if (func._stat != Stats.INVENTORY_LIMIT) continue;
                    return (int)func._value;
                }
            }
        }
        return 0;
    }

    @Override
    public boolean isPlayer() {
        return true;
    }

    public boolean checkCoupleAction(Player target) {
        if (target.getPrivateStoreType() != 0) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3123).addName(target));
            return false;
        }
        if (target.isFishing()) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3124).addName(target));
            return false;
        }
        if (target.isInTrainingCamp()) {
            this.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REQUEST_TO_A_CHARACTER_WHO_IS_ENTERING_THE_TRAINING_CAMP);
            return false;
        }
        if (target.isTransformed()) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3133).addName(target));
            return false;
        }
        if (target.isInCombat() || target.isVisualTransformed()) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3125).addName(target));
            return false;
        }
        if (target.isInOlympiadMode()) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3128).addName(target));
            return false;
        }
        if (target.isInSiegeZone()) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3130).addName(target));
            return false;
        }
        if (target.isInBoat() || target.getMountNpcId() != 0) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3131).addName(target));
            return false;
        }
        if (target.isTeleporting()) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3132).addName(target));
            return false;
        }
        if (target.isDead()) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(3139).addName(target));
            return false;
        }
        return true;
    }

    @Override
    public void startAttackStanceTask() {
        this.startAttackStanceTask0();
        for (Servitor servitor : this.getServitors()) {
            servitor.startAttackStanceTask0();
        }
    }

    @Override
    public void displayGiveDamageMessage(Creature target, Skill skill, int damage, Servitor servitorTransferedDamage, int transferedDamage, boolean crit, boolean miss, boolean shld, boolean blocked) {
        super.displayGiveDamageMessage(target, skill, damage, servitorTransferedDamage, transferedDamage, crit, miss, shld, blocked);
        if (miss) {
            if (skill == null) {
                this.sendPacket((IBroadcastPacket)new SystemMessage(2265).addName(this));
            } else {
                this.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(this.getObjectId(), target.getObjectId(), 4));
            }
            return;
        }
        if (crit) {
            if (skill != null) {
                if (skill.isMagic()) {
                    this.sendPacket((IBroadcastPacket)SystemMsg.MAGIC_CRITICAL_HIT);
                }
                this.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(this.getObjectId(), target.getObjectId(), 1));
            } else {
                this.sendPacket((IBroadcastPacket)new SystemMessage(2266).addName(this));
            }
        }
        if (blocked) {
            this.sendPacket((IBroadcastPacket)SystemMsg.THE_ATTACK_HAS_BEEN_BLOCKED);
            this.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(this.getObjectId(), target.getObjectId(), target.isInvulnerable() ? 7 : 5));
        } else if (target.isDoor() || target instanceof SiegeToggleNpcInstance) {
            this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_HIT_FOR_S1_DAMAGE).addInteger(damage));
        } else {
            if (servitorTransferedDamage != null && transferedDamage > 0) {
                SystemMessagePacket sm = new SystemMessagePacket(SystemMsg.C1_INFLICTED_S3_DAMAGE_ON_C2_AND_S4_DAMAGE_ON_THE_DAMAGE_TRANSFER_TARGET);
                sm.addName(this);
                sm.addInteger(damage);
                sm.addName(target);
                sm.addInteger(transferedDamage);
                sm.addHpChange(target.getObjectId(), this.getObjectId(), -damage);
                sm.addHpChange(servitorTransferedDamage.getObjectId(), this.getObjectId(), -transferedDamage);
                this.sendPacket((IBroadcastPacket)sm);
            } else {
                this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_DONE_S3_POINTS_OF_DAMAGE_TO_C2).addName(this)).addName(target)).addInteger(damage)).addHpChange(target.getObjectId(), this.getObjectId(), -damage));
            }
            if (shld) {
                if (damage == Config.EXCELLENT_SHIELD_BLOCK_RECEIVED_DAMAGE) {
                    if (skill != null && skill.isMagic()) {
                        this.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_RESISTED_C2S_MAGIC).addName(target)).addName(this));
                        this.sendPacket((IBroadcastPacket)new ExMagicAttackInfo(this.getObjectId(), target.getObjectId(), 6));
                    }
                } else if (damage > 0 && skill != null && skill.isMagic()) {
                    this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUR_OPPONENT_HAS_RESISTANCE_TO_MAGIC_THE_DAMAGE_WAS_DECREASED));
                }
            }
        }
    }

    @Override
    public void displayReceiveDamageMessage(Creature attacker, int damage) {
        if (attacker != this) {
            this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.C1_HAS_RECEIVED_S3_DAMAGE_FROM_C2).addName(this)).addName(attacker)).addInteger(damage)).addHpChange(this.getObjectId(), attacker.getObjectId(), -damage));
        }
    }

    public IntObjectMap<String> getPostFriends() {
        return this._postFriends;
    }

    public void setPostFriends(IntObjectMap<String> val) {
        this._postFriends = val;
    }

    public void sendReuseMessage(ItemInstance item) {
        TimeStamp sts = this.getSharedGroupReuse(item.getTemplate().getReuseGroup());
        if (sts == null || !sts.hasNotPassed()) {
            return;
        }
        long timeleft = sts.getReuseCurrent();
        long hours = timeleft / 3600000L;
        long minutes = (timeleft - hours * 3600000L) / 60000L;
        long seconds = (long)Math.max(1.0, Math.ceil((double)(timeleft - hours * 3600000L - minutes * 60000L) / 1000.0));
        if (hours > 0L) {
            this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(item.getTemplate().getReuseType().getMessages()[2]).addItemName(item.getTemplate().getItemId())).addInteger(hours)).addInteger(minutes)).addInteger(seconds));
        } else if (minutes > 0L) {
            this.sendPacket((IBroadcastPacket)((SystemMessagePacket)((SystemMessagePacket)new SystemMessagePacket(item.getTemplate().getReuseType().getMessages()[1]).addItemName(item.getTemplate().getItemId())).addInteger(minutes)).addInteger(seconds));
        } else {
            this.sendPacket((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(item.getTemplate().getReuseType().getMessages()[0]).addItemName(item.getTemplate().getItemId())).addInteger(seconds));
        }
    }

    public void ask(ConfirmDlgPacket dlg, OnAnswerListener listener) {
        if (this._askDialog != null) {
            return;
        }
        int rnd = Rnd.nextInt();
        this._askDialog = new IntObjectPairImpl(rnd, (Object)listener);
        dlg.setRequestId(rnd);
        this.sendPacket((IBroadcastPacket)dlg);
    }

    public IntObjectPair<OnAnswerListener> getAskListener(boolean clear) {
        if (!clear) {
            return this._askDialog;
        }
        IntObjectPair<OnAnswerListener> ask = this._askDialog;
        this._askDialog = null;
        return ask;
    }

    @Override
    public boolean isDead() {
        return this.isInOlympiadMode() || this.isInDuel() ? this.getCurrentHp() <= 1.0 : super.isDead();
    }

    @Override
    public int getAgathionEnergy() {
        ItemInstance item = this.getInventory().getPaperdollItem(18);
        return item == null ? 0 : item.getAgathionEnergy();
    }

    @Override
    public void setAgathionEnergy(int val) {
        ItemInstance item = this.getInventory().getPaperdollItem(18);
        if (item == null) {
            return;
        }
        item.setAgathionEnergy(val);
        item.setJdbcState(JdbcEntityState.UPDATED);
        this.sendPacket((IBroadcastPacket)new ExBR_AgathionEnergyInfoPacket(1, item));
    }

    public boolean hasPrivilege(Privilege privilege) {
        return this._clan != null && (this.getClanPrivileges() & privilege.mask()) == privilege.mask();
    }

    public MatchingRoom getMatchingRoom() {
        return this._matchingRoom;
    }

    public void setMatchingRoom(MatchingRoom matchingRoom) {
        this._matchingRoom = matchingRoom;
        if (matchingRoom == null) {
            this._matchingRoomWindowOpened = false;
        }
    }

    public boolean isMatchingRoomWindowOpened() {
        return this._matchingRoomWindowOpened;
    }

    public void setMatchingRoomWindowOpened(boolean b) {
        this._matchingRoomWindowOpened = b;
    }

    public void dispelBuffs() {
        for (Abnormal e : this.getAbnormalList()) {
            if (!e.isOffensive() || e.getSkill().isNewbie() || !e.isCancelable() || e.getSkill().isPreservedOnDeath() || this.isSpecialAbnormal(e.getSkill())) continue;
            this.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(e.getSkill().getId(), e.getSkill().getLevel()));
            e.exit();
        }
        for (Servitor servitor : this.getServitors()) {
            for (Abnormal e : servitor.getAbnormalList()) {
                if (e.isOffensive() || e.getSkill().isNewbie() || !e.isCancelable() || e.getSkill().isPreservedOnDeath() || servitor.isSpecialAbnormal(e.getSkill())) continue;
                e.exit();
            }
        }
    }

    public void setInstanceReuse(int id, long time, boolean notify) {
        if (notify) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(2720).addString(this.getName()));
        }
        this._instancesReuses.put(id, time);
        mysql.set("REPLACE INTO character_instances (obj_id, id, reuse) VALUES (?,?,?)", this.getObjectId(), id, time);
    }

    public void removeInstanceReuse(int id) {
        if (this._instancesReuses.remove(id) != null) {
            mysql.set("DELETE FROM `character_instances` WHERE `obj_id`=? AND `id`=? LIMIT 1", this.getObjectId(), id);
        }
    }

    public void removeAllInstanceReuses() {
        this._instancesReuses.clear();
        mysql.set("DELETE FROM `character_instances` WHERE `obj_id`=?", this.getObjectId());
    }

    public void removeInstanceReusesByGroupId(int groupId) {
        for (int i : InstantZoneHolder.getInstance().getSharedReuseInstanceIdsByGroup(groupId)) {
            if (this.getInstanceReuse(i) == null) continue;
            this.removeInstanceReuse(i);
        }
    }

    public Long getInstanceReuse(int id) {
        return this._instancesReuses.get(id);
    }

    public Map<Integer, Long> getInstanceReuses() {
        return this._instancesReuses;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void loadInstanceReuses() {
        Connection con = null;
        PreparedStatement offline = null;
        ResultSet rs = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            offline = con.prepareStatement("SELECT * FROM character_instances WHERE obj_id = ?");
            offline.setInt(1, this.getObjectId());
            rs = offline.executeQuery();
            while (rs.next()) {
                int id = rs.getInt("id");
                long reuse = rs.getLong("reuse");
                this._instancesReuses.put(id, reuse);
            }
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, offline, rs);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)offline, rs);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)offline, (ResultSet)rs);
    }

    public void setActiveReflection(Reflection reflection) {
        this._activeReflection = reflection;
    }

    public Reflection getActiveReflection() {
        return this._activeReflection;
    }

    public boolean canEnterInstance(int instancedZoneId) {
        InstantZone iz = InstantZoneHolder.getInstance().getInstantZone(instancedZoneId);
        if (this.isDead()) {
            return false;
        }
        if (ReflectionManager.getInstance().size() > Config.MAX_REFLECTIONS_COUNT) {
            this.sendPacket((IBroadcastPacket)SystemMsg.THE_MAXIMUM_NUMBER_OF_INSTANCE_ZONES_HAS_BEEN_EXCEEDED);
            return false;
        }
        if (iz == null) {
            this.sendPacket((IBroadcastPacket)SystemMsg.SYSTEM_ERROR);
            return false;
        }
        if (ReflectionManager.getInstance().getCountByIzId(instancedZoneId) >= iz.getMaxChannels()) {
            this.sendPacket((IBroadcastPacket)SystemMsg.THE_MAXIMUM_NUMBER_OF_INSTANCE_ZONES_HAS_BEEN_EXCEEDED);
            return false;
        }
        return iz.getEntryType(this).canEnter(this, iz);
    }

    public boolean canReenterInstance(int instancedZoneId) {
        if (this.getActiveReflection() != null && this.getActiveReflection().getInstancedZoneId() != instancedZoneId || !this.getReflection().isMain()) {
            this.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ENTERED_ANOTHER_INSTANCE_ZONE_THEREFORE_YOU_CANNOT_ENTER_CORRESPONDING_DUNGEON);
            return false;
        }
        InstantZone iz = InstantZoneHolder.getInstance().getInstantZone(instancedZoneId);
        if (iz.isDispelBuffs()) {
            this.dispelBuffs();
        }
        return iz.getEntryType(this).canReEnter(this, iz);
    }

    public int getBattlefieldChatId() {
        return this._battlefieldChatId;
    }

    public void setBattlefieldChatId(int battlefieldChatId) {
        this._battlefieldChatId = battlefieldChatId;
    }

    @Override
    public void broadCast(IBroadcastPacket ... packet) {
        this.sendPacket(packet);
    }

    @Override
    public int getMemberCount() {
        return 1;
    }

    @Override
    public Player getGroupLeader() {
        return this;
    }

    @Override
    public Iterator<Player> iterator() {
        return Collections.singleton(this).iterator();
    }

    public PlayerGroup getPlayerGroup() {
        if (this.getParty() != null) {
            if (this.getParty().getCommandChannel() != null) {
                return this.getParty().getCommandChannel();
            }
            return this.getParty();
        }
        return this;
    }

    public boolean isActionBlocked(String action) {
        return this._blockedActions.contains(action);
    }

    public void blockActions(String ... actions) {
        Collections.addAll(this._blockedActions, actions);
    }

    public void unblockActions(String ... actions) {
        for (String action : actions) {
            this._blockedActions.remove(action);
        }
    }

    public OlympiadGame getOlympiadGame() {
        return this._olympiadGame;
    }

    public void setOlympiadGame(OlympiadGame olympiadGame) {
        this._olympiadGame = olympiadGame;
    }

    public void addRadar(int x, int y, int z) {
        this.sendPacket((IBroadcastPacket)new RadarControlPacket(0, 1, x, y, z));
    }

    public void addRadarWithMap(int x, int y, int z) {
        this.sendPacket((IBroadcastPacket)new RadarControlPacket(0, 2, x, y, z));
    }

    public PetitionMainGroup getPetitionGroup() {
        return this._petitionGroup;
    }

    public void setPetitionGroup(PetitionMainGroup petitionGroup) {
        this._petitionGroup = petitionGroup;
    }

    public int getLectureMark() {
        return this._lectureMark;
    }

    public void setLectureMark(int lectureMark) {
        this._lectureMark = lectureMark;
    }

    public boolean isUserRelationActive() {
        return this._enableRelationTask == null;
    }

    public void startEnableUserRelationTask(long time, SiegeEvent<?, ?> siegeEvent) {
        if (this._enableRelationTask != null) {
            return;
        }
        this._enableRelationTask = ThreadPoolManager.getInstance().schedule(new EnableUserRelationTask(this, siegeEvent), time);
    }

    public void stopEnableUserRelationTask() {
        if (this._enableRelationTask != null) {
            this._enableRelationTask.cancel(false);
            this._enableRelationTask = null;
        }
    }

    public void broadcastRelation() {
        if (!this.isVisible()) {
            return;
        }
        for (Player target : World.getAroundObservers(this)) {
            if (this.isInvisible(target)) continue;
            RelationChangedPacket relationChanged = new RelationChangedPacket(this, target);
            for (Servitor servitor : this.getServitors()) {
                relationChanged.add(servitor, target);
            }
            target.sendPacket((IBroadcastPacket)relationChanged);
        }
    }

    @Override
    public int getINT() {
        return Math.max(this.getTemplate().getMinINT(), Math.min(this.getTemplate().getMaxINT(), super.getINT()));
    }

    @Override
    public int getSTR() {
        return Math.max(this.getTemplate().getMinSTR(), Math.min(this.getTemplate().getMaxSTR(), super.getSTR()));
    }

    @Override
    public int getCON() {
        return Math.max(this.getTemplate().getMinCON(), Math.min(this.getTemplate().getMaxCON(), super.getCON()));
    }

    @Override
    public int getMEN() {
        return Math.max(this.getTemplate().getMinMEN(), Math.min(this.getTemplate().getMaxMEN(), super.getMEN()));
    }

    @Override
    public int getDEX() {
        return Math.max(this.getTemplate().getMinDEX(), Math.min(this.getTemplate().getMaxDEX(), super.getDEX()));
    }

    @Override
    public int getWIT() {
        return Math.max(this.getTemplate().getMinWIT(), Math.min(this.getTemplate().getMaxWIT(), super.getWIT()));
    }

    public BookMarkList getBookMarkList() {
        return this._bookmarks;
    }

    public AntiFlood getAntiFlood() {
        return this._antiFlood;
    }

    public int getNpcDialogEndTime() {
        return this._npcDialogEndTime;
    }

    public void setNpcDialogEndTime(int val) {
        this._npcDialogEndTime = val;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    @Override
    public boolean useItem(ItemInstance item, boolean ctrl, boolean sendMsg) {
        if (!this._isUsingItem.compareAndSet(false, true)) {
            return false;
        }
        try {
            if (!ItemFunctions.checkForceUseItem(this, item, sendMsg)) {
                boolean bl = false;
                return bl;
            }
            ItemTemplate template = item.getTemplate();
            if (template.useItem(this, item, ctrl, true)) {
                boolean bl = true;
                return bl;
            }
            if (!ItemFunctions.checkUseItem(this, item, sendMsg)) {
                boolean bl = false;
                return bl;
            }
            if (template.useItem(this, item, ctrl, false)) {
                long nextTimeUse = template.getReuseType().next(item);
                if (nextTimeUse > System.currentTimeMillis()) {
                    TimeStamp timeStamp = new TimeStamp(item.getItemId(), nextTimeUse, (long)template.getReuseDelay());
                    this.addSharedGroupReuse(template.getReuseGroup(), timeStamp);
                    this.sendPacket((IBroadcastPacket)new InventoryUpdatePacket().addModifiedItem(this, item));
                    if (template.getReuseDelay() > 0) {
                        this.sendPacket((IBroadcastPacket)new ExUseSharedGroupItem(template.getDisplayReuseGroup(), timeStamp));
                    }
                }
                boolean bl = true;
                return bl;
            }
        }
        finally {
            this._isUsingItem.set(false);
        }
        return false;
    }

    public int getSkillsElementID() {
        return (int)this.getStat().calc(Stats.SKILLS_ELEMENT_ID, -1.0, null, null);
    }

    public Location getStablePoint() {
        return this._stablePoint;
    }

    public void setStablePoint(Location point) {
        this._stablePoint = point;
    }

    public boolean isInSameParty(Player target) {
        return this.getParty() != null && target.getParty() != null && this.getParty() == target.getParty();
    }

    public boolean isInSameChannel(Player target) {
        CommandChannel chan;
        Party activeCharP = this.getParty();
        Party targetP = target.getParty();
        return activeCharP != null && targetP != null && (chan = activeCharP.getCommandChannel()) != null && chan == targetP.getCommandChannel();
    }

    public boolean isInSameClan(Player target) {
        return this.getClanId() != 0 && this.getClanId() == target.getClanId();
    }

    public final boolean isInSameAlly(Player target) {
        return this.getAllyId() != 0 && this.getAllyId() == target.getAllyId();
    }

    public boolean isInPvPEvent() {
        PvPEvent event = this.getEvent(PvPEvent.class);
        return event != null && event.isBattleActive();
    }

    public boolean isRelatedTo(Creature character) {
        Player pc;
        if (character == this) {
            return true;
        }
        if (character.isServitor()) {
            Player Spc;
            if (this.isMyServitor(character.getObjectId())) {
                return true;
            }
            if (character.getPlayer() != null && (this.isInSameParty(Spc = character.getPlayer()) || this.isInSameChannel(Spc) || this.isInSameClan(Spc) || this.isInSameAlly(Spc))) {
                return true;
            }
        } else if (character.isPlayer() && (this.isInSameParty(pc = character.getPlayer()) || this.isInSameChannel(pc) || this.isInSameClan(pc) || this.isInSameAlly(pc))) {
            return true;
        }
        return false;
    }

    public boolean isAutoSearchParty() {
        return this._autoSearchParty;
    }

    public void enableAutoSearchParty() {
        this._autoSearchParty = true;
        PartySubstituteManager.getInstance().addWaitingPlayer(this);
        this.sendPacket((IBroadcastPacket)ExWaitWaitingSubStituteInfo.OPEN);
    }

    public void disablePartySearch(boolean disableFlag) {
        if (this._autoSearchParty) {
            PartySubstituteManager.getInstance().removeWaitingPlayer(this);
            this.sendPacket((IBroadcastPacket)ExWaitWaitingSubStituteInfo.CLOSE);
            this._autoSearchParty = !disableFlag;
        }
    }

    public boolean refreshPartySearchStatus(boolean sendMsg) {
        if (!this.mayPartySearch(false, sendMsg)) {
            this.disablePartySearch(false);
            return false;
        }
        if (this.isAutoSearchParty()) {
            this.enableAutoSearchParty();
            return true;
        }
        return false;
    }

    public boolean mayPartySearch(boolean first, boolean msg) {
        if (this.getParty() != null) {
            return false;
        }
        if (this.isPK()) {
            if (msg) {
                if (first) {
                    this.sendPacket((IBroadcastPacket)SystemMsg.WAITING_LIST_REGISTRATION_IS_NOT_ALLOWED_WHILE_THE_CURSED_SWORD_IS_BEING_USED_OR_THE_STATUS_IS_IN_A_CHAOTIC_STATE);
                } else {
                    this.sendPacket((IBroadcastPacket)SystemMsg.WAITING_LIST_REGISTRATION_IS_CANCELLED_BECAUSE_THE_CURSED_SWORD_IS_BEING_USED_OR_THE_STATUS_IS_IN_A_CHAOTIC_STATE);
                }
            }
            return false;
        }
        if (this.isInDuel() && this.getTeam() != TeamType.NONE) {
            if (msg) {
                if (first) {
                    this.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REGISTER_IN_THE_WAITING_LIST_DURING_A_DUEL);
                } else {
                    this.sendPacket((IBroadcastPacket)SystemMsg.WAITING_LIST_REGISTRATION_IS_CANCELLED_BECAUSE_YOU_ARE_IN_A_DUEL);
                }
            }
            return false;
        }
        if (this.isInOlympiadMode()) {
            if (msg) {
                if (first) {
                    this.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REGISTER_IN_THE_WAITING_LIST_WHILE_PARTICIPATING_IN_OLYMPIAD);
                } else {
                    this.sendPacket((IBroadcastPacket)SystemMsg.WAITING_LIST_REGISTRATION_IS_CANCELLED_BECAUSE_YOU_ARE_CURRENTLY_PARTICIPATING_IN_OLYMPIAD);
                }
            }
            return false;
        }
        if (this.isInSiegeZone()) {
            if (msg && first) {
                this.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REGISTER_IN_THE_WAITING_LIST_WHILE_BEING_INSIDE_OF_A_BATTLEGROUND_CASTLE_SIEGEFORTRESS_SIEGETERRITORY_WAR);
            }
            return false;
        }
        if (this.isInZoneBattle() || this.getReflectionId() != 0) {
            if (msg && first) {
                this.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REGISTER_IN_THE_WAITING_LIST_WHILE_PARTICIPATING_IN_BLOCK_CHECKERCOLISEUMKRATEIS_CUBE);
            }
            return false;
        }
        if (this.isInZone(Zone.ZoneType.no_escape) || this.isInZone(Zone.ZoneType.epic)) {
            return false;
        }
        return Config.ENABLE_PARTY_SEARCH;
    }

    public void startSubstituteTask() {
        if (!this.isPartySubstituteStarted()) {
            this._substituteTask = PartySubstituteManager.getInstance().SubstituteSearchTask(this);
            this.sendUserInfo();
            if (this.isInParty()) {
                this.getParty().getPartyLeader().sendPacket((IBroadcastPacket)new PartySmallWindowUpdatePacket(this));
            }
        }
    }

    public void stopSubstituteTask() {
        if (this.isPartySubstituteStarted()) {
            PartySubstituteManager.getInstance().removePartyMember(this);
            this._substituteTask.cancel(true);
            this.sendUserInfo();
            if (this.isInParty()) {
                this.getParty().getPartyLeader().sendPacket((IBroadcastPacket)new PartySmallWindowUpdatePacket(this));
            }
        }
    }

    public boolean isPartySubstituteStarted() {
        return this.getParty() != null && this._substituteTask != null && !this._substituteTask.isDone() && !this._substituteTask.isCancelled();
    }

    @Override
    public int getSkillLevel(int skillId) {
        switch (skillId) {
            case 1566: 
            case 1567: 
            case 1568: 
            case 1569: 
            case 17192: {
                return 1;
            }
        }
        return super.getSkillLevel(skillId);
    }

    public SymbolInstance getSymbol() {
        return this._symbol;
    }

    public void setSymbol(SymbolInstance symbol) {
        this._symbol = symbol;
    }

    public void setRegisteredInEvent(boolean inEvent) {
        this._registeredInEvent = inEvent;
    }

    public boolean isRegisteredInEvent() {
        return this._registeredInEvent;
    }

    private boolean checkActiveToggleEffects() {
        boolean dispelled = false;
        for (Abnormal effect : this.getAbnormalList()) {
            Skill skill = effect.getSkill();
            if (skill == null || !skill.isToggle() || this.getAllSkills().contains(skill)) continue;
            effect.exit();
        }
        return dispelled;
    }

    @Override
    public Servitor getServitorForTransfereDamage(double transferDamage) {
        SummonInstance summon = this.getSummon();
        if (summon == null || summon.isDead() || summon.getCurrentHp() < transferDamage) {
            return null;
        }
        if (summon.isInRangeZ(this, 1200)) {
            return summon;
        }
        return null;
    }

    @Override
    public double getDamageForTransferToServitor(double damage) {
        double transferToSummonDam = this.getStat().calc(Stats.TRANSFER_TO_SUMMON_DAMAGE_PERCENT, 0.0);
        if (transferToSummonDam > 0.0) {
            return damage * transferToSummonDam * 0.01;
        }
        return 0.0;
    }

    public boolean canFixedRessurect() {
        if (this.getPlayerAccess().ResurectFixed) {
            return true;
        }
        return !this.isInSiegeZone() && this.getInventory().getCountOf(10649) > 0L;
    }

    @Override
    public double getLevelBonus() {
        if (this.getTransform() != null && this.getTransform().getLevelBonus(this.getLevel()) > 0.0) {
            return this.getTransform().getLevelBonus(this.getLevel());
        }
        return super.getLevelBonus();
    }

    @Override
    public PlayerBaseStats getBaseStats() {
        if (this._baseStats == null) {
            this._baseStats = new PlayerBaseStats(this);
        }
        return (PlayerBaseStats)this._baseStats;
    }

    @Override
    public PlayerStat getStat() {
        if (this._stat == null) {
            this._stat = new PlayerStat(this);
        }
        return (PlayerStat)this._stat;
    }

    @Override
    public PlayerFlags getFlags() {
        if (this._statuses == null) {
            this._statuses = new PlayerFlags(this);
        }
        return (PlayerFlags)this._statuses;
    }

    @Override
    public final String getVisibleName(Player receiver) {
        for (Event event : this.getEvents()) {
            String name = event.getVisibleName(this, receiver);
            if (name == null) continue;
            return name;
        }
        return this.getName();
    }

    @Override
    public final String getVisibleTitle(Player receiver) {
        OfflineBufferManager.BufferData bufferData;
        if (this.isInBuffStore() && (bufferData = OfflineBufferManager.getInstance().getBuffStore(this.getObjectId())) != null) {
            return bufferData.getSaleTitle();
        }
        if (this.getPrivateStoreType() != 0) {
            if (this.getReflection() == ReflectionManager.GIRAN_HARBOR) {
                return "";
            }
            if (this.getReflection() == ReflectionManager.PARNASSUS) {
                return "";
            }
        }
        if (this.isInAwayingMode()) {
            String awayText = AwayManager.getInstance().getAwayText(this);
            if (awayText == null || awayText.length() <= 1) {
                return this.isLangRus() ? "<\u041e\u0442\u043e\u0448\u0435\u043b>" : "<Away>";
            }
            return (this.isLangRus() ? "<\u041e\u0442\u043e\u0448\u0435\u043b>" : "<Away>") + " - " + awayText + "*";
        }
        for (Event event : this.getEvents()) {
            String title = event.getVisibleTitle(this, receiver);
            if (title == null) continue;
            return title;
        }
        return this.getTitle();
    }

    public final int getVisibleNameColor(Player receiver) {
        OfflineBufferManager.BufferData bufferData;
        if (this.isInBuffStore() && (bufferData = OfflineBufferManager.getInstance().getBuffStore(this.getObjectId())) != null) {
            if (this.isInOfflineMode()) {
                return Config.BUFF_STORE_OFFLINE_NAME_COLOR;
            }
            return Config.BUFF_STORE_NAME_COLOR;
        }
        if (this.isInStoreMode() && this.isInOfflineMode()) {
            return Config.SERVICES_OFFLINE_TRADE_NAME_COLOR;
        }
        for (Event event : this.getEvents()) {
            Integer color = event.getVisibleNameColor(this, receiver);
            if (color == null) continue;
            return color;
        }
        int premiumNameColor = this.getPremiumAccount().getNameColor();
        if (premiumNameColor != -1) {
            return premiumNameColor;
        }
        int vipNameColor = this.getVIP().getTemplate().getNameColor();
        if (vipNameColor != -1) {
            return vipNameColor;
        }
        return this.getNameColor();
    }

    public final int getVisibleTitleColor(Player receiver) {
        OfflineBufferManager.BufferData bufferData;
        if (this.isInBuffStore() && (bufferData = OfflineBufferManager.getInstance().getBuffStore(this.getObjectId())) != null && !this.isInOfflineMode()) {
            return Config.BUFF_STORE_TITLE_COLOR;
        }
        if (this.isInAwayingMode()) {
            return Config.AWAY_TITLE_COLOR;
        }
        for (Event event : this.getEvents()) {
            Integer color = event.getVisibleTitleColor(this, receiver);
            if (color == null) continue;
            return color;
        }
        int premiumTitleColor = this.getPremiumAccount().getTitleColor();
        if (premiumTitleColor != -1) {
            return premiumTitleColor;
        }
        int vipTitleColor = this.getVIP().getTemplate().getTitleColor();
        if (vipTitleColor != -1) {
            return vipTitleColor;
        }
        return this.getTitleColor();
    }

    public final boolean isPledgeVisible(Player receiver) {
        if (this.getPrivateStoreType() != 0) {
            if (this.getReflection() == ReflectionManager.GIRAN_HARBOR) {
                return false;
            }
            if (this.getReflection() == ReflectionManager.PARNASSUS) {
                return false;
            }
        }
        for (Event event : this.getEvents()) {
            if (event.isPledgeVisible(this, receiver)) continue;
            return false;
        }
        return true;
    }

    public void checkAndDeleteOlympiadItems() {
        if (!this.isHero()) {
            ItemFunctions.deleteItemsEverywhere(this, 6842);
            int rank = Olympiad.getRank(this);
            if (rank != 2 && rank != 3) {
                ItemFunctions.deleteItemsEverywhere(this, 30373);
            }
            for (int itemId : ItemTemplate.HERO_WEAPON_IDS) {
                ItemFunctions.deleteItemsEverywhere(this, itemId);
            }
        }
    }

    public double getEnchantChanceModifier() {
        return this.getStat().calc(Stats.ENCHANT_CHANCE_MODIFIER);
    }

    @Override
    public boolean isSpecialAbnormal(Skill skill) {
        if (this.getClan() != null && this.getClan().isSpecialAbnormal(skill)) {
            return true;
        }
        if (skill.isNecessaryToggle()) {
            return true;
        }
        int skillId = skill.getId();
        return skillId == 7008 || skillId == 6038 || skillId == 6039 || skillId == 6040 || skillId == 6055 || skillId == 6056 || skillId == 6057 || skillId == 6058;
    }

    @Override
    public void removeAllSkills() {
        this._dontRewardSkills = true;
        super.removeAllSkills();
        this._dontRewardSkills = false;
    }

    public void setLastMultisellBuyTime(long val) {
        this._lastMultisellBuyTime = val;
    }

    public long getLastMultisellBuyTime() {
        return this._lastMultisellBuyTime;
    }

    public void setLastEnchantItemTime(long val) {
        this._lastEnchantItemTime = val;
    }

    public long getLastEnchantItemTime() {
        return this._lastEnchantItemTime;
    }

    public void setLastAttributeItemTime(long val) {
        this._lastAttributeItemTime = val;
    }

    public long getLastAttributeItemTime() {
        return this._lastAttributeItemTime;
    }

    public void checkLevelUpReward(boolean onRestore) {
        int i;
        int lastRewarded = this.getVarInt(LVL_UP_REWARD_VAR);
        int lastRewardedByClass = this.getVarInt("@lvl_up_reward_" + this.getActiveSubClass().getIndex());
        int playerLvl = this.getLevel();
        boolean rewarded = false;
        int clanPoints = 0;
        if (playerLvl > lastRewarded) {
            for (i = playerLvl; i > lastRewarded; --i) {
                TIntLongMap items = LevelUpRewardHolder.getInstance().getRewardData(i);
                if (items == null) continue;
                TIntLongIterator iterator = items.iterator();
                while (iterator.hasNext()) {
                    iterator.advance();
                    this.getPremiumItemList().add(new PremiumItem(iterator.key(), iterator.value(), ""));
                    rewarded = true;
                }
            }
            this.setVar(LVL_UP_REWARD_VAR, playerLvl);
        }
        if (playerLvl > lastRewardedByClass) {
            for (i = playerLvl; i > lastRewardedByClass; --i) {
                if (this.getClan() == null || this.getClan().getLevel() < 3) continue;
                int earnedPoints = 0;
                switch (i) {
                    case 20: {
                        earnedPoints = 2;
                        break;
                    }
                    case 21: {
                        earnedPoints = 2;
                        break;
                    }
                    case 22: {
                        earnedPoints = 2;
                        break;
                    }
                    case 23: {
                        earnedPoints = 2;
                        break;
                    }
                    case 24: {
                        earnedPoints = 2;
                        break;
                    }
                    case 25: {
                        earnedPoints = 2;
                        break;
                    }
                    case 26: {
                        earnedPoints = 4;
                        break;
                    }
                    case 27: {
                        earnedPoints = 4;
                        break;
                    }
                    case 28: {
                        earnedPoints = 4;
                        break;
                    }
                    case 29: {
                        earnedPoints = 4;
                        break;
                    }
                    case 30: {
                        earnedPoints = 4;
                        break;
                    }
                    case 31: {
                        earnedPoints = 6;
                        break;
                    }
                    case 32: {
                        earnedPoints = 6;
                        break;
                    }
                    case 33: {
                        earnedPoints = 6;
                        break;
                    }
                    case 34: {
                        earnedPoints = 6;
                        break;
                    }
                    case 35: {
                        earnedPoints = 6;
                        break;
                    }
                    case 36: {
                        earnedPoints = 8;
                        break;
                    }
                    case 37: {
                        earnedPoints = 8;
                        break;
                    }
                    case 38: {
                        earnedPoints = 8;
                        break;
                    }
                    case 39: {
                        earnedPoints = 8;
                        break;
                    }
                    case 40: {
                        earnedPoints = 8;
                        break;
                    }
                    case 41: {
                        earnedPoints = 10;
                        break;
                    }
                    case 42: {
                        earnedPoints = 10;
                        break;
                    }
                    case 43: {
                        earnedPoints = 10;
                        break;
                    }
                    case 44: {
                        earnedPoints = 10;
                        break;
                    }
                    case 45: {
                        earnedPoints = 10;
                        break;
                    }
                    case 46: {
                        earnedPoints = 12;
                        break;
                    }
                    case 47: {
                        earnedPoints = 12;
                        break;
                    }
                    case 48: {
                        earnedPoints = 12;
                        break;
                    }
                    case 49: {
                        earnedPoints = 12;
                        break;
                    }
                    case 50: {
                        earnedPoints = 12;
                        break;
                    }
                    case 51: {
                        earnedPoints = 14;
                        break;
                    }
                    case 52: {
                        earnedPoints = 14;
                        break;
                    }
                    case 53: {
                        earnedPoints = 14;
                        break;
                    }
                    case 54: {
                        earnedPoints = 14;
                        break;
                    }
                    case 55: {
                        earnedPoints = 14;
                        break;
                    }
                    case 56: {
                        earnedPoints = 16;
                        break;
                    }
                    case 57: {
                        earnedPoints = 16;
                        break;
                    }
                    case 58: {
                        earnedPoints = 16;
                        break;
                    }
                    case 59: {
                        earnedPoints = 16;
                        break;
                    }
                    case 60: {
                        earnedPoints = 16;
                        break;
                    }
                    case 61: {
                        earnedPoints = 18;
                        break;
                    }
                    case 62: {
                        earnedPoints = 18;
                        break;
                    }
                    case 63: {
                        earnedPoints = 18;
                        break;
                    }
                    case 64: {
                        earnedPoints = 18;
                        break;
                    }
                    case 65: {
                        earnedPoints = 18;
                        break;
                    }
                    case 66: {
                        earnedPoints = 21;
                        break;
                    }
                    case 67: {
                        earnedPoints = 21;
                        break;
                    }
                    case 68: {
                        earnedPoints = 21;
                        break;
                    }
                    case 69: {
                        earnedPoints = 21;
                        break;
                    }
                    case 70: {
                        earnedPoints = 21;
                        break;
                    }
                    case 71: {
                        earnedPoints = 25;
                        break;
                    }
                    case 72: {
                        earnedPoints = 25;
                        break;
                    }
                    case 73: {
                        earnedPoints = 25;
                        break;
                    }
                    case 74: {
                        earnedPoints = 25;
                        break;
                    }
                    case 75: {
                        earnedPoints = 25;
                    }
                }
                if (earnedPoints <= 0) continue;
                clanPoints += earnedPoints;
            }
            this.setVar("@lvl_up_reward_" + this.getActiveSubClass().getIndex(), playerLvl);
        }
        if (rewarded) {
            this.sendPacket((IBroadcastPacket)ExNotifyPremiumItem.STATIC);
        }
        if (clanPoints > 0) {
            this.getClan().incReputation(clanPoints, true, "ClanMemberLvlUp");
        }
    }

    public void checkHeroSkills() {
        boolean hero = this.isHero() && this.isBaseClassActive();
        for (SkillLearn sl : SkillAcquireHolder.getInstance().getAvailableMaxLvlSkills(hero ? this : null, AcquireType.HERO)) {
            SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, sl.getId(), sl.getLevel());
            if (skillEntry == null) continue;
            if (hero) {
                if (this.getSkillLevel(skillEntry.getId()) >= skillEntry.getLevel()) continue;
                this.addSkill(skillEntry, true);
                continue;
            }
            this.removeSkill(skillEntry, true);
        }
    }

    public void activateHeroSkills(boolean activate) {
        for (SkillLearn sl : SkillAcquireHolder.getInstance().getAvailableMaxLvlSkills(null, AcquireType.HERO)) {
            Skill skill = SkillHolder.getInstance().getSkill(sl.getId(), sl.getLevel());
            if (skill == null) continue;
            if (!activate) {
                this.addUnActiveSkill(skill);
                continue;
            }
            this.removeUnActiveSkill(skill);
        }
    }

    public void giveGMSkills() {
        if (!this.isGM()) {
            return;
        }
        for (SkillLearn sl : SkillAcquireHolder.getInstance().getAvailableMaxLvlSkills(this, AcquireType.GM)) {
            SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, sl.getId(), sl.getLevel());
            if (skillEntry == null || this.getSkillLevel(skillEntry.getId()) >= skillEntry.getLevel()) continue;
            this.addSkill(skillEntry, true);
        }
    }

    public void setblockUntilTime(long time) {
        this._blockUntilTime = time;
    }

    public long getblockUntilTime() {
        return this._blockUntilTime;
    }

    public int getWorldChatPoints() {
        int points = (this.hasPremiumAccount() ? Config.WORLD_CHAT_POINTS_PER_DAY_PA : Config.WORLD_CHAT_POINTS_PER_DAY) - this._usedWorldChatPoints;
        points = (int)this.getStat().calc(Stats.WORLD_CHAT_POINTS, points);
        points = Math.max(0, points);
        return points;
    }

    public int getUsedWorldChatPoints() {
        return this._usedWorldChatPoints;
    }

    public void setUsedWorldChatPoints(int value) {
        this._usedWorldChatPoints = value;
    }

    public int getArmorSetEnchant() {
        return this._armorSetEnchant;
    }

    public void setArmorSetEnchant(int value) {
        this._armorSetEnchant = value;
    }

    public boolean hideHeadAccessories() {
        return this._hideHeadAccessories;
    }

    public void setHideHeadAccessories(boolean value) {
        this._hideHeadAccessories = value;
    }

    public ItemInstance getSynthesisItem1() {
        return this._synthesisItem1;
    }

    public void setSynthesisItem1(ItemInstance value) {
        this._synthesisItem1 = value;
    }

    public ItemInstance getSynthesisItem2() {
        return this._synthesisItem2;
    }

    public void setSynthesisItem2(ItemInstance value) {
        this._synthesisItem2 = value;
    }

    @Override
    public int getAdditionalVisualSSEffect() {
        for (int id : ADDITIONAL_SS_EFFECTS) {
            if (!ItemFunctions.checkIsEquipped(this, -1, id, 0)) continue;
            return id;
        }
        return 0;
    }

    @Override
    public SkillEntry getAdditionalSSEffect(boolean spiritshot, boolean blessed) {
        if (!spiritshot) {
            if (!blessed) {
                if (ItemFunctions.checkIsEquipped(this, -1, 70455, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17817, 1);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 70454, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17816, 1);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 70453, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17815, 1);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 70452, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17814, 2);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 70451, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17814, 1);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90332, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17817, 1);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90331, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17816, 1);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90330, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17815, 1);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90329, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17814, 2);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90328, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17814, 1);
                }
            } else {
                if (ItemFunctions.checkIsEquipped(this, -1, 70455, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17817, 2);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 70454, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17816, 2);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 70453, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17815, 2);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 70452, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17814, 4);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 70451, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17814, 3);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90332, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17817, 2);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90331, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17816, 2);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90330, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17815, 2);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90329, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17814, 4);
                }
                if (ItemFunctions.checkIsEquipped(this, -1, 90328, 0)) {
                    return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17814, 3);
                }
            }
        } else if (!blessed) {
            if (ItemFunctions.checkIsEquipped(this, -1, 70460, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17821, 1);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 70459, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17820, 1);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 70458, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17819, 1);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 70457, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17818, 2);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 70456, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17818, 1);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90337, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17821, 1);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90336, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17820, 1);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90335, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17819, 1);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90334, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17818, 2);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90333, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17818, 1);
            }
        } else {
            if (ItemFunctions.checkIsEquipped(this, -1, 70460, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17821, 2);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 70459, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17820, 2);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 70458, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17819, 2);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 70457, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17818, 4);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 70456, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17818, 3);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90337, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17821, 2);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90336, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17820, 2);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90335, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17819, 2);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90334, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17818, 4);
            }
            if (ItemFunctions.checkIsEquipped(this, -1, 90333, 0)) {
                return SkillEntry.makeSkillEntry(SkillEntryType.CUNSUMABLE_ITEM, 17818, 3);
            }
        }
        return null;
    }

    public String getHWID() {
        return this.getNetConnection().getHWID();
    }

    public boolean isInAwayingMode() {
        return this._awaying;
    }

    public void setAwayingMode(boolean awaying) {
        this._awaying = awaying;
    }

    public double getMPCostDiff(Skill.SkillMagicType type) {
        double value = 0.0;
        switch (type) {
            case PHYSIC: {
                value = this.getStat().calc(Stats.MP_PHYSICAL_SKILL_CONSUME, 10000.0) / 10000.0 * 100.0 - 100.0;
                break;
            }
            case MAGIC: {
                value = this.getStat().calc(Stats.MP_MAGIC_SKILL_CONSUME, 10000.0) / 10000.0 * 100.0 - 100.0;
                break;
            }
            case MUSIC: {
                value = this.getStat().calc(Stats.MP_DANCE_SKILL_CONSUME, 10000.0) / 10000.0 * 100.0 - 100.0;
            }
        }
        return value;
    }

    public int getExpertiseIndex() {
        return this.getSkillLevel(239, 0);
    }

    public void addListenerHook(ListenerHookType type, ListenerHook hook) {
        if (!this.scriptHookTypeList.containsKey((Object)type)) {
            CopyOnWriteArraySet<ListenerHook> hooks = new CopyOnWriteArraySet<ListenerHook>();
            hooks.add(hook);
            this.scriptHookTypeList.put(type, hooks);
        } else {
            CopyOnWriteArraySet<ListenerHook> hooks = this.scriptHookTypeList.get(type);
            hooks.add(hook);
        }
    }

    public void removeListenerHookType(ListenerHookType type, ListenerHook hook) {
        if (this.scriptHookTypeList.containsKey((Object)type)) {
            Set hooks = this.scriptHookTypeList.get(type);
            hooks.remove(hook);
        }
    }

    public Set<ListenerHook> getListenerHooks(ListenerHookType type) {
        Set<ListenerHook> hooks = (Set<ListenerHook>)this.scriptHookTypeList.get(type);
        if (hooks == null) {
            hooks = Collections.emptySet();
        }
        return hooks;
    }

    @Override
    public boolean isFakePlayer() {
        return this.getAI() != null && this.getAI().isFake();
    }

    public OptionDataTemplate addOptionData(OptionDataTemplate optionData) {
        if (optionData == null) {
            return null;
        }
        OptionDataTemplate oldOptionData = (OptionDataTemplate)this._options.get(optionData.getId());
        if (optionData == oldOptionData) {
            return oldOptionData;
        }
        this._options.put(optionData.getId(), optionData);
        this.addTriggers(optionData);
        this.getStat().addFuncs(optionData.getStatFuncs(optionData));
        for (SkillEntry skillEntry : optionData.getSkills()) {
            this.addSkill(skillEntry);
        }
        return oldOptionData;
    }

    public OptionDataTemplate removeOptionData(int id) {
        OptionDataTemplate oldOptionData = (OptionDataTemplate)this._options.remove(id);
        if (oldOptionData != null) {
            this.removeTriggers(oldOptionData);
            this.getStat().removeFuncsByOwner(oldOptionData);
            for (SkillEntry skillEntry : oldOptionData.getSkills()) {
                this.removeSkill(skillEntry);
            }
        }
        return oldOptionData;
    }

    public long getReceivedExp() {
        return this._receivedExp;
    }

    @Override
    protected void onSpawn() {
        super.onSpawn();
        this.getAI().notifyEvent(CtrlEvent.EVT_SPAWN);
    }

    @Override
    protected void onDespawn() {
        this.getAI().notifyEvent(CtrlEvent.EVT_DESPAWN);
        super.onDespawn();
    }

    public void setQuestZoneId(int id) {
        this._questZoneId = id;
    }

    public int getQuestZoneId() {
        return this._questZoneId;
    }

    @Override
    protected void onAddSkill(SkillEntry skillEntry) {
        Skill skill = skillEntry.getTemplate();
        if (skill.isNecessaryToggle()) {
            if (skill.isToggleGrouped() && skill.getToggleGroupId() > 0) {
                for (Abnormal abnormal : this.getAbnormalList()) {
                    if (!abnormal.getSkill().isToggleGrouped() || abnormal.getSkill().getToggleGroupId() != skill.getToggleGroupId()) continue;
                    return;
                }
            }
            this.forceUseSkill(skillEntry, this);
        }
    }

    public void setCustomHero(int hours) {
        this.setHero(true);
        this.updatePledgeRank();
        this.broadcastPacket(new SocialActionPacket(this.getObjectId(), 20016));
        this.checkHeroSkills();
        int time = hours == -1 ? -1 : (int)(System.currentTimeMillis() / 1000L) + hours * 60 * 60;
        CustomHeroDAO.getInstance().addCustomHero(this.getObjectId(), time);
    }

    public void setSelectedMultiClassId(ClassId classId) {
        this._selectedMultiClassId = classId;
    }

    public ClassId getSelectedMultiClassId() {
        return this._selectedMultiClassId;
    }

    @Override
    public int getPAtk(Creature target) {
        return (int)((double)super.getPAtk(target) * Config.PLAYER_P_ATK_MODIFIER);
    }

    @Override
    public int getMAtk(Creature target, Skill skill) {
        return (int)((double)super.getMAtk(target, skill) * Config.PLAYER_M_ATK_MODIFIER);
    }

    @Override
    public void onZoneEnter(Zone zone) {
        DuelEvent duel;
        boolean sendBuffStore = true;
        boolean sendEnterMessage = true;
        boolean blockActions = true;
        for (Zone z : this.getZones()) {
            if (z == zone) continue;
            if (zone.getType() == Zone.ZoneType.buff_store && z.getType() == Zone.ZoneType.buff_store) {
                sendBuffStore = false;
            }
            if (zone.getEnteringMessageId() == z.getEnteringMessageId()) {
                sendEnterMessage = false;
            }
            if (!Arrays.equals(zone.getTemplate().getBlockedActions(), z.getTemplate().getBlockedActions())) continue;
            blockActions = false;
        }
        if (zone.getType() == Zone.ZoneType.SIEGE) {
            for (CastleSiegeEvent siegeEvent : zone.getEvents(CastleSiegeEvent.class)) {
                if (!this.containsEvent(siegeEvent)) continue;
                siegeEvent.addVisitedParticipant(this);
            }
        }
        if (sendBuffStore && zone.getType() == Zone.ZoneType.buff_store && Config.BUFF_STORE_ALLOWED_CLASS_LIST.contains(this.getClassId().getId())) {
            this.sendPacket((IBroadcastPacket)new SayPacket2(0, ChatType.BATTLEFIELD, this.getName(), new CustomMessage("l2s.gameserver.model.Player.EnterOfflineBufferZone").toString(this)));
        }
        if (sendEnterMessage && zone.getEnteringMessageId() != 0) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(zone.getEnteringMessageId()));
        }
        if (blockActions && zone.getTemplate().getBlockedActions() != null) {
            this.blockActions(zone.getTemplate().getBlockedActions());
        }
        if (zone.getType() == Zone.ZoneType.peace_zone && (duel = this.getEvent(DuelEvent.class)) != null) {
            duel.abortDuel(this);
        }
    }

    @Override
    public void onZoneLeave(Zone zone) {
        boolean sendBuffStore = true;
        boolean sendLeavingMessage = true;
        boolean unblockActions = true;
        for (Zone z : this.getZones()) {
            if (z == zone) continue;
            if (zone.getType() == Zone.ZoneType.buff_store && z.getType() == Zone.ZoneType.buff_store) {
                sendBuffStore = false;
            }
            if (zone.getLeavingMessageId() == z.getLeavingMessageId()) {
                sendLeavingMessage = false;
            }
            if (!Arrays.equals(zone.getTemplate().getBlockedActions(), z.getTemplate().getBlockedActions())) continue;
            unblockActions = false;
        }
        if (sendBuffStore && zone.getType() == Zone.ZoneType.buff_store && Config.BUFF_STORE_ALLOWED_CLASS_LIST.contains(this.getClassId().getId())) {
            this.sendPacket((IBroadcastPacket)new SayPacket2(0, ChatType.BATTLEFIELD, this.getName(), new CustomMessage("l2s.gameserver.model.Player.ExitOfflineBufferZone").toString(this)));
        }
        if (sendLeavingMessage && zone.getLeavingMessageId() != 0) {
            this.sendPacket((IBroadcastPacket)new SystemMessage(zone.getLeavingMessageId()));
        }
        if (unblockActions && zone.getTemplate().getBlockedActions() != null) {
            this.unblockActions(zone.getTemplate().getBlockedActions());
        }
    }

    @Override
    public boolean hasBasicPropertyResist() {
        return false;
    }

    public boolean addTask(ScheduledFuture<?> task) {
        if (task != null) {
            return this._tasks.add(task);
        }
        return false;
    }

    public boolean removeTask(ScheduledFuture<?> task) {
        return this._tasks.remove(task);
    }

    public boolean canReceiveStatusUpdate(Creature creature, StatusUpdatePacket.UpdateType updateType, int field) {
        boolean isRegenOrDamage;
        if (creature == this) {
            return true;
        }
        boolean bl = isRegenOrDamage = updateType == StatusUpdatePacket.UpdateType.REGEN || updateType == StatusUpdatePacket.UpdateType.DAMAGED;
        if (creature.isNpc() || creature.isDoor()) {
            if (isRegenOrDamage || this.getTarget() == creature || this.getDistance(creature) < 700) {
                if (field == 9) {
                    return true;
                }
                if (field == 10) {
                    return true;
                }
            }
            if (isRegenOrDamage) {
                if (field == 11) {
                    return true;
                }
                if (field == 12) {
                    return true;
                }
            }
        } else if (creature.isPlayable()) {
            if (field == 27) {
                return true;
            }
            if (field == 26) {
                return true;
            }
            if (creature.isServitor()) {
                if (isRegenOrDamage || this.getTarget() == creature || this.getDistance(creature) < 700) {
                    if (field == 9) {
                        return true;
                    }
                    if (field == 10) {
                        return true;
                    }
                }
                if (isRegenOrDamage || this.getTarget() == creature) {
                    if (field == 11) {
                        return true;
                    }
                    if (field == 12) {
                        return true;
                    }
                }
            } else {
                boolean canReceiveHpMp;
                Player player = creature.getPlayer();
                if (player == null || player == this) {
                    canReceiveHpMp = true;
                } else {
                    canReceiveHpMp = isRegenOrDamage;
                    if (!canReceiveHpMp && this.isInSameParty(player)) {
                        canReceiveHpMp = true;
                    }
                    if (!canReceiveHpMp && this.isInSameChannel(player)) {
                        canReceiveHpMp = true;
                    }
                    if (!canReceiveHpMp && this.isInSameClan(player)) {
                        canReceiveHpMp = true;
                    }
                }
                if (canReceiveHpMp) {
                    if (field == 9) {
                        return true;
                    }
                    if (field == 10) {
                        return true;
                    }
                    if (field == 11) {
                        return true;
                    }
                    if (field == 12) {
                        return true;
                    }
                    if (creature.isPlayer()) {
                        if (field == 33) {
                            return true;
                        }
                        if (field == 34) {
                            return true;
                        }
                    }
                }
            }
        }
        return false;
    }

    public boolean startBanEndTask(BanBindType bindType, int endTime) {
        ScheduledFuture<?> task;
        Pair<Integer, Future<?>> taskInfo = this.banTasks.get(bindType);
        if (taskInfo != null) {
            if ((Integer)taskInfo.getKey() == endTime) {
                return false;
            }
            task = (ScheduledFuture<?>)taskInfo.getValue();
            if (task != null) {
                task.cancel(false);
            }
        }
        task = null;
        if (endTime != -1) {
            long delay = (long)endTime * 1000L - System.currentTimeMillis();
            if (delay <= 0L) {
                return false;
            }
            if (bindType == BanBindType.CHAT) {
                task = ThreadPoolManager.getInstance().schedule(() -> GameBanManager.onUnban(bindType, this.getObjectId(), false), delay);
            }
            if (task == null) {
                return false;
            }
        }
        this.banTasks.put(bindType, Pair.of(endTime, task));
        return true;
    }

    public boolean stopBanEndTask(BanBindType bindType) {
        Pair<Integer, Future<?>> taskInfo = this.banTasks.remove(bindType);
        if (taskInfo == null) {
            return false;
        }
        Future task = (Future)taskInfo.getValue();
        if (task == null) {
            return false;
        }
        task.cancel(false);
        return true;
    }

    public void stopBanEndTasks() {
        for (Pair<Integer, Future<?>> taskInfo : this.banTasks.values()) {
            Future task = (Future)taskInfo.getValue();
            if (task == null) continue;
            task.cancel(false);
        }
        this.banTasks.clear();
    }

    private class SnoopListener
    implements OnPlayerChatMessageReceive {
        private SnoopListener() {
        }

        @Override
        public void onChatMessageReceive(Player player, ChatType type, String charName, String text) {
            if (Player.this._snoopListenerPlayers.size() > 0) {
                SnoopPacket sn = new SnoopPacket(Player.this.getObjectId(), Player.this.getName(), type.ordinal(), charName, text);
                for (Player pci : Player.this._snoopListenerPlayers) {
                    if (pci == null) continue;
                    pci.sendPacket((IBroadcastPacket)sn);
                }
            }
        }
    }

    private class UserInfoTask
    implements Runnable {
        private UserInfoTask() {
        }

        @Override
        public void run() {
            Player.this.sendUserInfoImpl();
            Player.this._userInfoTask = null;
        }
    }

    public class BroadcastCharInfoTask
    implements Runnable {
        @Override
        public void run() {
            Player.this.broadcastCharInfoImpl(new IUpdateTypeComponent[0]);
            Player.this._broadcastCharInfoTask = null;
        }
    }
}

