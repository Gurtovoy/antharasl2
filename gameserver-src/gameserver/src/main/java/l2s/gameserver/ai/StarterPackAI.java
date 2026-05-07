package l2s.gameserver.ai;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

import l2s.commons.util.Rnd;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.Config;
import l2s.gameserver.model.autobot.StarterBotState;
import l2s.gameserver.model.autobot.StarterBotState.State;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.autobot.StarterPackFarmProgression;
import l2s.gameserver.model.autobot.StarterPackTownPaths;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.data.xml.holder.StarterPackLoadoutHolder;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Starter pack bot AI: village farm → town → optional outskirts farm (race lvl 3–8 zones) → town.
 */
public class StarterPackAI extends PlayerAI implements Runnable
{
	private static final Logger _log = LoggerFactory.getLogger(StarterPackAI.class);

	private static final int THINK_INTERVAL = 1000;
	private static final int THINK_INTERVAL_WALKING = 250;
	private static final int THINK_INTERVAL_QUEST = 250;
	private static final int FARM_RADIUS = 800;
	private static final int FARM_HEIGHT = 200;
	private static final int SOULSHOT_NOVICE = 5789;
	private static final long MIN_SOULSHOT_STOCK = 500L;
	private static final int BASE_MAX_MOB_LEVEL = 5;
	private static final int WAYPOINT_JITTER_XY = 42;
	private static final int RANDOM_WALK_RADIUS = 300;
	private static final int TOWN_ARRIVAL_DIST = 100;
	private static final int WAYPOINT_ARRIVAL_DIST = 150;
	private static final int ROUTE_LATERAL_JITTER = 70;
	private static final int TOWN_IDLE_WALK_RADIUS = 200;
	private static final long REVIVE_DELAY = 5000L;
	private static final long STUCK_TIMEOUT = 30000L;
	private static final long TOWN_IDLE_MIN = 30000L;
	private static final long TOWN_IDLE_MAX = 60000L;
	private static final int MIN_BOTS_PER_TARGET_SOFT = 2;
	private static final int MAX_BOTS_PER_TARGET_SOFT = 5;
	private static final int MAX_BOTS_PER_TARGET_HARD = 6;
	private static final int QUEST_FARM_RADIUS = 4000;
	private static final int QUEST_FARM_HEIGHT = 500;

	private static final ConcurrentHashMap<Integer, AtomicInteger> _targetCounts = new ConcurrentHashMap<>();
	private static final int[][] ROUTE_TO_NEWBIE_GUIDE = {
		{-71508, 258180, -3135}, {-71663, 258003, -3128}, {-72176, 257387, -3141}, {-72459, 257065, -3141},
		{-72830, 256611, -3141}, {-73389, 256123, -3152}, {-73840, 255604, -3179}, {-74197, 255080, -3249},
		{-75076, 254068, -3355}, {-75236, 253905, -3357}, {-75748, 253180, -3357}, {-76539, 252287, -3352},
		{-76900, 251791, -3353}, {-77362, 251347, -3383}, {-77699, 250882, -3445}, {-78443, 250062, -3599},
		{-78892, 249412, -3599}, {-79422, 248925, -3599}, {-80193, 247847, -3671}, {-81034, 247160, -3680},
		{-81600, 246167, -3722}, {-82346, 245139, -3745}, {-82824, 244462, -3755}, {-83663, 243685, -3755},
		{-84025, 243292, -3755}
	};
	private static final int[][] ROUTE_TO_ALTRAN = {
		{-84364, 243282, -3755}, {-84621, 242952, -3755}, {-84856, 242667, -3755}, {-85016, 242668, -3755}
	};
	private static final int[][] ROUTE_TO_WOLVES = {
		{-85375, 242031, -3755}, {-85878, 241436, -3755}, {-86410, 240930, -3750}, {-87266, 241152, -3653},
		{-88003, 241588, -3632}, {-88662, 241639, -3602}, {-89089, 241795, -3608}
	};
	private static final int[][] ROUTE_TO_ORCS = {
		{-90518, 241355, -3557}, {-91684, 241203, -3504}, {-92600, 240824, -3449}, {-92963, 240154, -3442},
		{-93470, 239777, -3441}
	};
	private static final int[][] ROUTE_TO_WEREWOLVES_ORCS = {
		{-94754, 241265, -3370}, {-94577, 242169, -3571}, {-94772, 243316, -3571}, {-94574, 244809, -3643},
		{-94810, 245463, -3599}, {-95004, 246176, -3656}, {-94979, 246879, -3684}, {-95151, 247258, -3655},
		{-95535, 247888, -3686}, {-95708, 248401, -3644}, {-96092, 248537, -3612}
	};

	private final StarterBotState _botState;
	private final int _targetLevel;
	private Location _farmCenter;
	private final Location _townLoc;
	private final int[][] _townPath;
	private int[][] _routeWaypoints;
	private int _pathWaypointIndex = 0;
	private int _farmRadius = FARM_RADIUS;
	private int _farmHeight = FARM_HEIGHT;
	private int _maxMobLevel = BASE_MAX_MOB_LEVEL;
	private int _thinkIntervalMs = -1;
	private long _outskirtsDepartAt = 0L;
	private int _currentRaceStageMaxLevel = -1;

	private ScheduledFuture<?> _thinkTask;
	private final AtomicBoolean _active = new AtomicBoolean(false);

	// Death handling
	private long _deathTime = 0L;

	// Stuck detection for WALKING_TO_TOWN
	private Location _lastWalkPos = null;
	private long _lastWalkPosTime = 0L;
	private int _moveRetryCount = 0;
	private static final int MAX_MOVE_RETRIES = 5;

	// Town idle timer
	private long _nextTownWalkTime = 0L;

	// Current tracked target for target-count bookkeeping
	private int _currentTargetId = 0;
	private boolean _level10LoadoutApplied = false;
	private long _lastRebuffUse = 0L;
	private QuestHumanFighterStage _questStage = QuestHumanFighterStage.START_TUTORIAL;
	private long _questNextActionTime = 0L;
	private int _questRecoveryRouteStep = 0;
	private int[][] _questRouteRef = null;
	private int _questRouteIndex = 0;
	private int _targetCrowdTolerance = Rnd.get(MIN_BOTS_PER_TARGET_SOFT, MAX_BOTS_PER_TARGET_SOFT);
	private long _nextTargetCrowdRetuneAt = 0L;
	private int _lastAutoLearnLevel = 0;

	private enum QuestHumanFighterStage
	{
		START_TUTORIAL,
		FARM_GEMSTONE,
		TUTORIAL_MASTER_AND_LEVEL3,
		TO_NEWBIE_GUIDE,
		START_TOMBS,
		TO_ALTRAN,
		FARM_WOLVES,
		TO_ORCS,
		FARM_ORCS,
		TO_WEREWOLVES_ORCS,
		FARM_WEREWOLVES_ORCS,
		GRIND_TO_10,
		USE_SOE_AND_REST,
		TO_ALTRAN_FINAL,
		FINISH_QUEST
	}

	public StarterPackAI(Player player, StarterBotState botState, int targetLevel, Location spawnLoc, Location townLoc)
	{
		super(player);
		_botState = botState;
		_targetLevel = targetLevel;
		_farmCenter = spawnLoc.clone();
		_townLoc = townLoc;
		_townPath = StarterPackTownPaths.getPathForClass(_botState.getClassId());
		if(isQuestHumanFighterMode())
			updateQuestStage(QuestHumanFighterStage.START_TUTORIAL);
	}

	// =============================================
	// Lifecycle
	// =============================================

	@Override
	protected void onEvtSpawn()
	{
		super.onEvtSpawn();
		startThinking();
	}

	@Override
	public void onEvtDeSpawn()
	{
		stopThinking();
		super.onEvtDeSpawn();
	}

	@Override
	public boolean isFake()
	{
		return false;
	}

	public synchronized void startThinking()
	{
		if(_thinkTask == null)
		{
			_active.set(true);
			_thinkIntervalMs = -1;
			ensureThinkInterval(THINK_INTERVAL);
		}
	}

	private synchronized void ensureThinkInterval(int desiredMs)
	{
		if(_thinkIntervalMs == desiredMs && _thinkTask != null)
			return;
		_thinkIntervalMs = desiredMs;
		if(_thinkTask != null)
		{
			_thinkTask.cancel(false);
			_thinkTask = null;
		}
		if(_active.get())
			_thinkTask = ThreadPoolManager.getInstance().scheduleAtFixedDelay(this, desiredMs, desiredMs);
	}

	public synchronized void stopThinking()
	{
		_active.set(false);
		if(_currentTargetId != 0)
		{
			releaseTarget(_currentTargetId);
			_currentTargetId = 0;
		}
		if(_thinkTask != null)
		{
			_thinkTask.cancel(false);
			_thinkTask = null;
		}
	}

	public StarterBotState getBotState()
	{
		return _botState;
	}

	// =============================================
	// Main think loop
	// =============================================

	@Override
	public void run()
	{
		try
		{
			Player actor = getActor();
			if(actor == null || !_active.get())
			{
				stopThinking();
				return;
			}
			think();
		}
		catch(Exception e)
		{
			_log.error("StarterPackAI: Error in think loop: " + e.getMessage(), e);
		}
	}

	private synchronized void think()
	{
		Player player = getActor();
		if(player == null)
			return;
		ensureAutoLearnSkills(player);
		ensureWarriorSoulshots(player);

		if(isQuestHumanFighterMode())
		{
			ensureThinkInterval(THINK_INTERVAL_QUEST);
			thinkQuestHumanFighter(player);
			return;
		}

		ensureLevel10Loadout(player);

		// Check level transition: FARMING → WALKING_TO_TOWN
		if(_botState.getCurrentState() == State.FARMING)
		{
			if(_botState.getFarmStage() > 0 && _currentRaceStageMaxLevel > 0 && player.getLevel() > _currentRaceStageMaxLevel)
				beginWalkToTown(player);
			else if(_botState.getFarmStage() == 0 && player.getLevel() >= _targetLevel)
				beginWalkToTown(player);
		}

		switch(_botState.getCurrentState())
		{
			case FARMING:
				thinkFarming(player);
				break;
			case WALKING_TO_TOWN:
				thinkWalkingToTown(player);
				break;
			case IN_TOWN:
				thinkInTown(player);
				break;
		}

		updateThinkCadence(_botState.getCurrentState());
	}

	private void beginWalkToTown(Player player)
	{
		_botState.setCurrentState(State.WALKING_TO_TOWN);
		_lastWalkPos = null;
		_lastWalkPosTime = System.currentTimeMillis();
		_routeWaypoints = StarterPackTownPaths.buildJitteredPath(_townPath, WAYPOINT_JITTER_XY);
		int[][] idxPath = _routeWaypoints != null ? _routeWaypoints : _townPath;
		_pathWaypointIndex = StarterPackTownPaths.findStartWaypointIndex(player, idxPath);
		_moveRetryCount = 0;
	}

	private void updateThinkCadence(State state)
	{
		int want = state == State.WALKING_TO_TOWN ? THINK_INTERVAL_WALKING : THINK_INTERVAL;
		ensureThinkInterval(want);
	}

	// =============================================
	// FARMING state
	// =============================================

	private void thinkFarming(Player player)
	{
		// 1. Handle death — revive after delay
		if(player.isDead())
		{
			handleDeath(player);
			return;
		}

		// 2. If moving, let it finish
		if(player.getMovement().isMoving() || player.isMovementDisabled())
			return;

		// 3. If already attacking a live target, let combat continue
		Creature attackTarget = getAttackTarget();
		if(attackTarget != null && !attackTarget.isDead() && !attackTarget.isAlikeDead())
			return;

		// 3a. Previous target died or gone — release it
		if(_currentTargetId != 0)
		{
			releaseTarget(_currentTargetId);
			_currentTargetId = 0;
		}

		// 4. Find nearest monster
		NpcInstance target = findNearestMonster(player);

		if(target != null)
		{
			_currentTargetId = target.getObjectId();

			player.setTarget(target);

			if(player.isMageClass() && !player.getClassId().isOfRace(Race.ORC))
			{
				// Mage: try to cast a spell
				Skill spell = getRandomSkill(player, target);
				if(spell != null)
				{
					useCombatConsumable(player, true);
					int castRange = spell.getCastRange() > 0 ? spell.getCastRange() : 400;
					if(player.getDistance(target) > castRange - 50)
					{
						player.getMovement().moveToLocation(Location.findAroundPosition(target, 30, 60), 0, true);
					}
					else
					{
						Cast(SkillEntry.makeSkillEntry(SkillEntryType.NONE, spell), target, false, false);
					}
				}
				else
				{
					// No spell available — auto-attack as fallback
					if(player.getDistance(target) > player.getPhysicalAttackRange() + 50)
					{
						player.getMovement().moveToLocation(Location.findAroundPosition(target, 30, 60), 0, true);
					}
					else
					{
						Attack(target, true, false);
					}
				}
			}
			else
			{
				// Melee / ORC mage: auto-attack
				useCombatConsumable(player, false);
				if(player.getDistance(target) > player.getPhysicalAttackRange() + 50)
				{
					player.getMovement().moveToLocation(Location.findAroundPosition(target, 30, 60), 0, true);
				}
				else
				{
					useItemNow(player, SOULSHOT_NOVICE);
					Attack(target, true, false);
				}
			}
		}
		else
		{
			// No monsters found — random walk near spawn
			randomWalkNear(player, _farmCenter, RANDOM_WALK_RADIUS);
		}
	}

	private NpcInstance findNearestMonster(Player player)
	{
		retuneTargetCrowdTolerance();
		List<NpcInstance> npcs = player.getAroundNpc(_farmRadius, _farmHeight);
		Set<Integer> triedTargetIds = new HashSet<Integer>();

		while(true)
		{
			NpcInstance closest = null;
			int closestDist = Integer.MAX_VALUE;

			for(NpcInstance npc : npcs)
			{
				if(!npc.isMonster())
					continue;
				if(npc.isDead() || npc.isAlikeDead())
					continue;
				if(npc.getLevel() > _maxMobLevel)
					continue;
				if(npc.isInvisible(player))
					continue;
				if(triedTargetIds.contains(npc.getObjectId()))
					continue;
				AtomicInteger cnt = _targetCounts.get(npc.getObjectId());
				if(cnt != null && cnt.get() >= _targetCrowdTolerance)
					continue;
				if(!GeoEngine.canMoveToCoord(player.getX(), player.getY(), player.getZ(),
					npc.getX(), npc.getY(), npc.getZ(), player.getGeoIndex()))
					continue;

				int dist = player.getDistance(npc);
				if(dist < closestDist)
				{
					closestDist = dist;
					closest = npc;
				}
			}

			if(closest == null)
				return null;

			if(tryClaimTarget(closest.getObjectId(), _targetCrowdTolerance))
				return closest;

			triedTargetIds.add(closest.getObjectId());
		}
	}

	private void retuneTargetCrowdTolerance()
	{
		long now = System.currentTimeMillis();
		if(now < _nextTargetCrowdRetuneAt)
			return;
		_targetCrowdTolerance = Rnd.get(MIN_BOTS_PER_TARGET_SOFT, MAX_BOTS_PER_TARGET_SOFT);
		_nextTargetCrowdRetuneAt = now + Rnd.get(15000, 45000);
	}

	// =============================================
	// Death / Respawn
	// =============================================

	private void handleDeath(Player player)
	{
		// Release target when dying
		if(_currentTargetId != 0)
		{
			releaseTarget(_currentTargetId);
			_currentTargetId = 0;
		}

		if(_deathTime == 0L)
		{
			_deathTime = System.currentTimeMillis();
			return;
		}

		if(System.currentTimeMillis() - _deathTime >= REVIVE_DELAY)
		{
			try
			{
				player.doRevive();
				player.setCurrentHp(player.getMaxHp() * 0.7, true, true);
				player.setCurrentMp(player.getMaxMp() * 0.7);
				player.setCurrentCp(player.getMaxCp() * 0.7);

				// Village respawn, then IN_TOWN logic sends the bot back to the correct farm XML stage.
				_botState.setCurrentState(State.IN_TOWN);
				_outskirtsDepartAt = 0L;
				_routeWaypoints = null;
				_lastWalkPos = null;
				_moveRetryCount = 0;
				_nextTownWalkTime = System.currentTimeMillis() + Rnd.get((int) TOWN_IDLE_MIN, (int) TOWN_IDLE_MAX);
				teleBot(player, getTownDestination());
				if(isQuestHumanFighterMode())
				{
					_questRecoveryRouteStep = resolveQuestRecoveryStep(_questStage);
					questDelay(3000);
				}
			}
			catch(Exception e)
			{
				_log.error("StarterPackAI: Error reviving bot: " + e.getMessage(), e);
			}
			finally
			{
				_deathTime = 0L;
			}
		}
	}

	private int resolveQuestRecoveryStep(QuestHumanFighterStage stage)
	{
		switch(stage)
		{
			case FARM_WOLVES:
			case TO_ORCS:
				return 1;
			case FARM_ORCS:
			case TO_WEREWOLVES_ORCS:
				return 2;
			case FARM_WEREWOLVES_ORCS:
			case GRIND_TO_10:
			case USE_SOE_AND_REST:
			case TO_ALTRAN_FINAL:
			case FINISH_QUEST:
				return 3;
			default:
				return 0;
		}
	}

	/**
	 * Headless bots use {@code isFake() == false}, so {@link Creature#teleToLocation} does not call
	 * {@link Player#onTeleported()} (that normally comes from the client Appearing packet). Without
	 * {@code onTeleported}, {@code decayMe} is never balanced by {@code spawnMe} and the bot stays
	 * invisible / untargetable.
	 */
	private static void teleBot(Player player, Location loc)
	{
		player.teleToLocation(loc);
		if(!player.isFakePlayer())
			player.onTeleported();
	}

	private StarterPackFarmProgression.RaceFarmStage selectTownDepartureStage(Player player)
	{
		if(!Config.STARTER_PACK_PROGRESSION_ENABLED)
			return null;

		Race race = getBotRace();
		int fs = _botState.getFarmStage();
		if(fs > 0)
		{
			StarterPackFarmProgression.RaceFarmStage cur = StarterPackFarmProgression.getCurrentStage(race, fs);
			if(cur != null && player.getLevel() >= cur.minLevel && player.getLevel() <= cur.maxLevel)
				return cur;
		}
		return StarterPackFarmProgression.getNextStage(race, fs, player.getLevel());
	}

	// =============================================
	// WALKING_TO_TOWN state
	// =============================================

	private void thinkWalkingToTown(Player player)
	{
		if(player.isDead())
		{
			handleDeath(player);
			return;
		}

		// Pass through all waypoints we are already inside (no extra tick between nodes)
		while(true)
		{
			Location dest = getCurrentWalkDestination();
			int arrivalDist = isWalkingFinalTownSegment() ? TOWN_ARRIVAL_DIST : WAYPOINT_ARRIVAL_DIST;
			if(player.getDistance(dest) > arrivalDist)
				break;

			if(!isWalkingFinalTownSegment())
			{
				_pathWaypointIndex++;
				_lastWalkPos = null;
				_moveRetryCount = 0;
				continue;
			}
			_botState.setCurrentState(State.IN_TOWN);
			_nextTownWalkTime = System.currentTimeMillis() + Rnd.get((int) TOWN_IDLE_MIN, (int) TOWN_IDLE_MAX);
			player.getMovement().stopMove();
			_moveRetryCount = 0;
			_routeWaypoints = null;
			return;
		}

		Location destination = getCurrentWalkDestination();

		// Stuck detection
		long now = System.currentTimeMillis();
		if(_lastWalkPos != null)
		{
			int movedDist = (int) Math.sqrt(
				Math.pow(player.getX() - _lastWalkPos.x, 2) +
				Math.pow(player.getY() - _lastWalkPos.y, 2));

			if(movedDist < 30 && now - _lastWalkPosTime >= STUCK_TIMEOUT)
			{
				// Stuck for 30+ seconds — teleport as last resort
				_log.info("StarterPackAI: Bot " + player.getName() + " stuck for " + STUCK_TIMEOUT + "ms, teleporting to town.");
				teleBot(player, getTownDestination());
				_botState.setCurrentState(State.IN_TOWN);
				_nextTownWalkTime = now + Rnd.get((int) TOWN_IDLE_MIN, (int) TOWN_IDLE_MAX);
				_moveRetryCount = 0;
				return;
			}

			if(movedDist >= 30)
			{
				_lastWalkPos = player.getLoc();
				_lastWalkPosTime = now;
				_moveRetryCount = 0;
			}
		}
		else
		{
			_lastWalkPos = player.getLoc();
			_lastWalkPosTime = now;
		}

		// Move toward town if not already moving
		if(!player.getMovement().isMoving() && !player.isMovementDisabled())
		{
			Location moveTarget = withLateralJitter(player, destination, ROUTE_LATERAL_JITTER);
			if(!player.getMovement().moveToLocation(moveTarget, 0, true))
			{
				_moveRetryCount++;
				if(_moveRetryCount < MAX_MOVE_RETRIES)
				{
					int dx = destination.x - player.getX();
					int dy = destination.y - player.getY();
					double dist = Math.sqrt(dx * dx + dy * dy);
					if(dist > 0)
					{
						int stepDist = Rnd.get(300, 500);
						int midX = player.getX() + (int)(dx / dist * stepDist) + Rnd.get(-100, 100);
						int midY = player.getY() + (int)(dy / dist * stepDist) + Rnd.get(-100, 100);
						int midZ = GeoEngine.getLowerHeight(midX, midY, player.getZ(), player.getGeoIndex());
						Location midLoc = new Location(midX, midY, midZ);
						player.getMovement().moveToLocation(midLoc, 0, true);
					}
				}
			}
		}
	}

	private boolean isWalkingFinalTownSegment()
	{
		return _townPath == null || _townPath.length == 0 || _pathWaypointIndex >= _townPath.length;
	}

	private Location getCurrentWalkDestination()
	{
		if(isWalkingFinalTownSegment())
			return getTownDestination();
		int[][] seg = _routeWaypoints != null ? _routeWaypoints : _townPath;
		int[] wp = seg[_pathWaypointIndex];
		return new Location(wp[0], wp[1], wp[2]);
	}

	private Location getTownDestination()
	{
		int[] townLoc = _botState.getTownLocation();
		if(townLoc != null && townLoc.length >= 3)
		{
			return new Location(townLoc[0], townLoc[1], townLoc[2]);
		}
		// Fallback: use the configured town location with a random offset
		return new Location(
			_townLoc.x + Rnd.get(-150, 150),
			_townLoc.y + Rnd.get(-150, 150),
			_townLoc.z
		);
	}

	// =============================================
	// IN_TOWN state
	// =============================================

	private void thinkInTown(Player player)
	{
		if(player.isDead())
		{
			handleDeath(player);
			return;
		}

		long now = System.currentTimeMillis();

		if(Config.STARTER_PACK_PROGRESSION_ENABLED)
		{
			StarterPackFarmProgression.RaceFarmStage stage = selectTownDepartureStage(player);
			if(stage != null)
			{
				if(_outskirtsDepartAt == 0L)
					_outskirtsDepartAt = now + Config.STARTER_PACK_TOWN_MS_BEFORE_OUTSKIRTS;
				if(now >= _outskirtsDepartAt)
				{
					int[] spawn = stage.getRandomSpawn();
					if(spawn == null)
					{
						_outskirtsDepartAt = 0L;
						return;
					}
					int jx = Rnd.get(-70, 70);
					int jy = Rnd.get(-70, 70);
					int nx = spawn[0] + jx;
					int ny = spawn[1] + jy;
					int nz = GeoEngine.getLowerHeight(nx, ny, spawn[2], player.getGeoIndex());
					teleBot(player, new Location(nx, ny, nz));
					_farmCenter = new Location(nx, ny, nz);
					_farmRadius = stage.farmRadius;
					_farmHeight = stage.farmHeight;
					_maxMobLevel = Math.max(BASE_MAX_MOB_LEVEL, stage.maxLevel);
					_currentRaceStageMaxLevel = stage.maxLevel;
					_botState.setFarmStage(stage.stageIndex);
					_outskirtsDepartAt = 0L;
					_botState.setCurrentState(State.FARMING);
					return;
				}
			}
			else
				_outskirtsDepartAt = 0L;
		}
		else
			_outskirtsDepartAt = 0L;

		if(player.getMovement().isMoving() || player.isMovementDisabled())
			return;

		if(now >= _nextTownWalkTime)
		{
			randomWalkNear(player, player.getLoc(), TOWN_IDLE_WALK_RADIUS);
			_nextTownWalkTime = now + Rnd.get((int) TOWN_IDLE_MIN, (int) TOWN_IDLE_MAX);
		}
	}

	// =============================================
	// Utility
	// =============================================

	private static void releaseTarget(int objectId)
	{
		AtomicInteger count = _targetCounts.get(objectId);
		if(count != null && count.decrementAndGet() <= 0)
		{
			_targetCounts.remove(objectId);
		}
	}

	private static boolean tryClaimTarget(int objectId, int softLimit)
	{
		AtomicInteger count = _targetCounts.computeIfAbsent(objectId, k -> new AtomicInteger(0));
		while(true)
		{
			int current = count.get();
			int effectiveSoft = Math.max(1, Math.min(softLimit, MAX_BOTS_PER_TARGET_HARD));
			if(current >= effectiveSoft || current >= MAX_BOTS_PER_TARGET_HARD)
				return false;
			if(count.compareAndSet(current, current + 1))
				return true;
		}
	}

	private void randomWalkNear(Player player, Location center, int radius)
	{
		if(player.getMovement().isMoving() || player.isMovementDisabled())
			return;

		int spreadRadius = Math.max(80, radius + Rnd.get(-40, 90));
		Location loc = Location.coordsRandomize(center, 60, spreadRadius);
		int z = GeoEngine.getLowerHeight(loc.x, loc.y, loc.z, player.getGeoIndex());
		if(GeoEngine.canMoveToCoord(player.getX(), player.getY(), player.getZ(),
			loc.x, loc.y, z, player.getGeoIndex()))
		{
			loc.z = z;
			player.getMovement().moveToLocation(loc, 0, true);
		}
	}

	private void ensureLevel10Loadout(Player player)
	{
		StarterPackLoadoutHolder loadout = StarterPackLoadoutHolder.getInstance();
		if(player.getLevel() < loadout.getLevel())
			return;

		if(!_level10LoadoutApplied)
		{
			player.getInventory().writeLock();
			try
			{
				ensureRandomWeapon(player, player.isMageClass() ? loadout.getMageWeapons() : loadout.getWarriorWeapons());

				List<Integer> armorSet = player.isMageClass() ? loadout.getMagicArmor() : loadout.getLightArmor();
				for(int armorId : armorSet)
					ensureEquippedCopies(player, armorId, 1);

				Map<Integer, Integer> accessoryCounts = new HashMap<Integer, Integer>();
				for(int accessoryId : loadout.getAccessories())
					accessoryCounts.put(accessoryId, accessoryCounts.getOrDefault(accessoryId, 0) + 1);
				for(Map.Entry<Integer, Integer> entry : accessoryCounts.entrySet())
					ensureEquippedCopies(player, entry.getKey(), entry.getValue());

				ensureItemCount(player, loadout.getWarriorConsumableId(), loadout.getWarriorConsumableCount());
				ensureItemCount(player, loadout.getMageConsumableId(), loadout.getMageConsumableCount());
				ensureItemCount(player, loadout.getScrollId(), loadout.getScrollCount());
			}
			finally
			{
				player.getInventory().writeUnlock();
			}
			_level10LoadoutApplied = true;
		}
		else
		{
			// keep consumables stocked even after first equip pass
			player.getInventory().writeLock();
			try
			{
				ensureItemCount(player, loadout.getWarriorConsumableId(), loadout.getWarriorConsumableCount());
				ensureItemCount(player, loadout.getMageConsumableId(), loadout.getMageConsumableCount());
				ensureItemCount(player, loadout.getScrollId(), loadout.getScrollCount());
			}
			finally
			{
				player.getInventory().writeUnlock();
			}
		}
	}

	private void ensureRandomWeapon(Player player, List<Integer> weaponPool)
	{
		ItemInstance active = player.getInventory().getPaperdollItem(7);
		if(active != null || weaponPool == null || weaponPool.isEmpty())
			return;

		int chosen = weaponPool.get(Rnd.get(weaponPool.size()));
		ItemInstance item = player.getInventory().getItemByItemId(chosen);
		if(item == null)
			item = player.getInventory().addItem(chosen, 1L);
		if(item != null)
			player.getInventory().equipItem(item);
	}

	private void ensureEquippedCopies(Player player, int itemId, int copies)
	{
		List<ItemInstance> items = player.getInventory().getItemsByItemId(itemId);
		int have = items.size();
		while(have < copies)
		{
			ItemInstance added = player.getInventory().addItem(itemId, 1L);
			if(added == null)
				break;
			have++;
			items = player.getInventory().getItemsByItemId(itemId);
		}

		int equipped = 0;
		for(ItemInstance item : items)
			if(item.isEquipped())
				equipped++;

		if(equipped >= copies)
			return;

		for(ItemInstance item : items)
		{
			if(item.isEquipped())
				continue;
			player.getInventory().equipItem(item);
			equipped++;
			if(equipped >= copies)
				break;
		}
	}

	private void ensureItemCount(Player player, int itemId, long minCount)
	{
		long count = player.getInventory().getCountOf(itemId);
		if(count < minCount)
			player.getInventory().addItem(itemId, minCount - count);
	}

	private void useCombatConsumable(Player player, boolean mageAttack)
	{
		StarterPackLoadoutHolder loadout = StarterPackLoadoutHolder.getInstance();
		long now = System.currentTimeMillis();
		int hitItemId = mageAttack ? loadout.getMageConsumableId() : loadout.getWarriorConsumableId();
		ItemInstance hitItem = player.getInventory().getItemByItemId(hitItemId);
		if(hitItem != null)
		{
			player.useItem(hitItem, false, false);
		}

		if(now - _lastRebuffUse < loadout.getScrollRebuffCooldownMs())
			return;
		if(hasAnyPositiveBuff(player))
			return;

		ItemInstance scroll = player.getInventory().getItemByItemId(loadout.getScrollId());
		if(scroll != null)
		{
			player.useItem(scroll, false, false);
			_lastRebuffUse = now;
		}
	}

	private Race getBotRace()
	{
		int classId = _botState.getClassId();
		if(classId >= 0 && classId < ClassId.VALUES.length && ClassId.VALUES[classId] != null)
			return ClassId.VALUES[classId].getRace();
		return Race.HUMAN;
	}

	private boolean isQuestHumanFighterMode()
	{
		return _botState.getMode() == StarterBotState.Mode.QUEST_HUMAN_FIGHTER && _botState.getClassId() == 0;
	}

	private void thinkQuestHumanFighter(Player player)
	{
		if(player.isDead())
		{
			handleDeath(player);
			return;
		}
		if(System.currentTimeMillis() < _questNextActionTime)
			return;
		if(ensureQuestRecoveryRoute(player))
			return;

		switch(_questStage)
		{
			case START_TUTORIAL:
				if(talkToNpc(player, 30009, null) && talkToNpc(player, 30009, null))
					updateQuestStage(QuestHumanFighterStage.FARM_GEMSTONE);
				break;
			case FARM_GEMSTONE:
				if(player.getInventory().getCountOf(6353) > 0)
					updateQuestStage(QuestHumanFighterStage.TUTORIAL_MASTER_AND_LEVEL3);
				else
					questFarmInRadius(player, new int[] {18342});
				break;
			case TUTORIAL_MASTER_AND_LEVEL3:
				if(player.getInventory().getCountOf(1067) <= 0)
				{
					if(talkToNpc(player, 30009, null))
						questDelay(800);
				}
				else if(talkToNpc(player, 30008, "QuestEvent 999 30008-3.htm"))
					updateQuestStage(QuestHumanFighterStage.TO_NEWBIE_GUIDE);
				break;
			case TO_NEWBIE_GUIDE:
				if(player.getLevel() < 3)
				{
					questFarmInRadius(player, new int[] {18342});
					break;
				}
				if(walkRoute(player, ROUTE_TO_NEWBIE_GUIDE))
					updateQuestStage(QuestHumanFighterStage.START_TOMBS);
				break;
			case START_TOMBS:
				if(talkToNpc(player, 30598, "QuestEvent 11001 GID2.htm"))
					updateQuestStage(QuestHumanFighterStage.TO_ALTRAN);
				break;
			case TO_ALTRAN:
				if(walkRoute(player, ROUTE_TO_ALTRAN) && talkToNpc(player, 30283, "QuestEvent 11001 alt2.htm"))
					updateQuestStage(QuestHumanFighterStage.FARM_WOLVES);
				break;
			case FARM_WOLVES:
				_questRecoveryRouteStep = 1;
				if(player.getInventory().getCountOf(90200) >= 10)
					updateQuestStage(QuestHumanFighterStage.TO_ORCS);
				else
					questFarmInRadius(player, new int[] {20120});
				break;
			case TO_ORCS:
				_questRecoveryRouteStep = 1;
				if(walkRoute(player, ROUTE_TO_ORCS))
					updateQuestStage(QuestHumanFighterStage.FARM_ORCS);
				break;
			case FARM_ORCS:
				_questRecoveryRouteStep = 2;
				if(player.getInventory().getCountOf(90201) >= 10)
					updateQuestStage(QuestHumanFighterStage.TO_WEREWOLVES_ORCS);
				else
					questFarmInRadius(player, new int[] {20130, 20131});
				break;
			case TO_WEREWOLVES_ORCS:
				_questRecoveryRouteStep = 2;
				if(walkRoute(player, ROUTE_TO_WEREWOLVES_ORCS))
					updateQuestStage(QuestHumanFighterStage.FARM_WEREWOLVES_ORCS);
				break;
			case FARM_WEREWOLVES_ORCS:
				_questRecoveryRouteStep = 3;
				if(player.getInventory().getCountOf(90202) >= 10 && player.getInventory().getCountOf(90203) >= 10)
					updateQuestStage(QuestHumanFighterStage.GRIND_TO_10);
				else
					questFarmInRadius(player, new int[] {20132, 20093});
				break;
			case GRIND_TO_10:
				_questRecoveryRouteStep = 3;
				if(player.getLevel() >= 10)
				{
					useItemNow(player, 10650);
					questDelay(120000);
					updateQuestStage(QuestHumanFighterStage.USE_SOE_AND_REST);
				}
				else
					questFarmInRadius(player, new int[] {20132, 20093});
				break;
			case USE_SOE_AND_REST:
				if(player.getDistance(new Location(-84008, 243272, -3728)) > 3000)
					teleBot(player, new Location(-84008, 243272, -3728));
				updateQuestStage(QuestHumanFighterStage.TO_ALTRAN_FINAL);
				break;
			case TO_ALTRAN_FINAL:
				if(walkRoute(player, ROUTE_TO_ALTRAN))
					updateQuestStage(QuestHumanFighterStage.FINISH_QUEST);
				break;
			case FINISH_QUEST:
				if(talkToNpc(player, 30283, "QuestEvent 11001 alt6.htm"))
				{
					ensureItemCount(player, 49403, 1);
					ItemInstance sw = player.getInventory().getItemByItemId(49403);
					if(sw != null && !sw.isEquipped())
						player.getInventory().equipItem(sw);
					ensureLevel10Loadout(player);
					questDelay(10000);
				}
				break;
		}
	}

	private void updateQuestStage(QuestHumanFighterStage nextStage)
	{
		_questStage = nextStage;
		String key = nextStage != null ? nextStage.name().toLowerCase() : "";
		_botState.setQuestStageKey(key);
	}

	private boolean ensureQuestRecoveryRoute(Player player)
	{
		if(_questRecoveryRouteStep <= 0)
			return false;
		if(player.getLevel() < 3)
			return false;
		if(player.getDistance(new Location(-84008, 243272, -3728)) > 3500 && _questRecoveryRouteStep == 0)
			return false;
		// Recover only to the current required segment.
		// Using >= (cascading checks) can pull bots backwards to previous route chains.
		if(_questRecoveryRouteStep == 1 && !isNearRouteEnd(player, ROUTE_TO_WOLVES))
		{
			walkRoute(player, ROUTE_TO_WOLVES);
			return true;
		}
		if(_questRecoveryRouteStep == 2 && !isNearRouteEnd(player, ROUTE_TO_ORCS))
		{
			walkRoute(player, ROUTE_TO_ORCS);
			return true;
		}
		if(_questRecoveryRouteStep == 3 && !isNearRouteEnd(player, ROUTE_TO_WEREWOLVES_ORCS))
		{
			walkRoute(player, ROUTE_TO_WEREWOLVES_ORCS);
			return true;
		}
		return false;
	}

	private boolean isNearRouteEnd(Player player, int[][] route)
	{
		if(route == null || route.length == 0)
			return true;
		int[] end = route[route.length - 1];
		return player.getDistance(new Location(end[0], end[1], end[2])) <= 500;
	}

	private boolean talkToNpc(Player player, int npcId, String bypass)
	{
		NpcInstance npc = findClosestNpc(player, npcId, 2500);
		if(npc == null)
			return false;
		if(player.getDistance(npc) > 160)
		{
			player.getMovement().moveToLocation(Location.findAroundPosition(npc, 40, 100), 0, true);
			return false;
		}
		player.setTarget(npc);
		npc.onAction(player, false);
		if(bypass != null)
			npc.onBypassFeedback(player, bypass);
		questDelay(1500);
		return true;
	}

	private NpcInstance findClosestNpc(Player player, int npcId, int radius)
	{
		NpcInstance found = null;
		for(NpcInstance n : player.getAroundNpc(radius, 400))
		{
			if(n.getNpcId() != npcId)
				continue;
			if(found == null || player.getDistance(n) < player.getDistance(found))
				found = n;
		}
		return found;
	}

	private boolean walkRoute(Player player, int[][] route)
	{
		if(route == null || route.length == 0)
			return true;
		Location end = new Location(route[route.length - 1][0], route[route.length - 1][1], route[route.length - 1][2]);
		if(player.getDistance(end) <= 220)
		{
			_questRouteRef = null;
			_questRouteIndex = 0;
			return true;
		}
		if(player.isMovementDisabled())
			return false;

		if(_questRouteRef != route)
		{
			_questRouteRef = route;
			int nearest = 0;
			int nearestDist = Integer.MAX_VALUE;
			for(int i = 0; i < route.length; i++)
			{
				Location p = new Location(route[i][0], route[i][1], route[i][2]);
				int d = player.getDistance(p);
				if(d < nearestDist)
				{
					nearestDist = d;
					nearest = i;
				}
			}
			_questRouteIndex = Math.min(route.length - 1, nearest + 1);
		}

		while(_questRouteIndex < route.length)
		{
			Location p = new Location(route[_questRouteIndex][0], route[_questRouteIndex][1], route[_questRouteIndex][2]);
			if(player.getDistance(p) > WAYPOINT_ARRIVAL_DIST)
				break;
			_questRouteIndex++;
		}

		if(_questRouteIndex >= route.length)
			return player.getDistance(end) <= 220;

		if(player.getMovement().isMoving())
			return false;

		Location nextWp = new Location(route[_questRouteIndex][0], route[_questRouteIndex][1], route[_questRouteIndex][2]);
		player.getMovement().moveToLocation(withLateralJitter(player, nextWp, ROUTE_LATERAL_JITTER), 0, true);
		return false;
	}

	private Location withLateralJitter(Player player, Location destination, int maxJitter)
	{
		if(maxJitter <= 0 || player == null || destination == null)
			return destination;

		long dx = destination.x - player.getX();
		long dy = destination.y - player.getY();
		double len = Math.sqrt(dx * dx + dy * dy);
		if(len < 220.0)
			return destination; // near target: avoid overshoot and zig-zag

		double nx = -dy / len;
		double ny = dx / len;
		int lateral = Rnd.get(-maxJitter, maxJitter);
		int tx = destination.x + (int) Math.round(nx * lateral);
		int ty = destination.y + (int) Math.round(ny * lateral);
		int tz = GeoEngine.getLowerHeight(tx, ty, destination.z, player.getGeoIndex());

		if(GeoEngine.canMoveToCoord(player.getX(), player.getY(), player.getZ(), tx, ty, tz, player.getGeoIndex()))
			return new Location(tx, ty, tz);
		return destination;
	}

	private void questFarmInRadius(Player player, int[] preferredNpcIds)
	{
		if(player.getMovement().isMoving() || player.isMovementDisabled())
			return;
		NpcInstance target = findPreferredMonster(player, preferredNpcIds);
		if(target != null)
		{
			player.setTarget(target);
			if(player.getDistance(target) > player.getPhysicalAttackRange() + 50)
				player.getMovement().moveToLocation(Location.findAroundPosition(target, 30, 80), 0, true);
			else
			{
				useItemNow(player, SOULSHOT_NOVICE);
				Attack(target, true, false);
			}
			return;
		}
		// Keep roaming around the intended farm area when mobs are scarce,
		// instead of drifting away from the route/farm zone over time.
		randomWalkNear(player, getQuestFarmCenter(player), QUEST_FARM_RADIUS / 2);
	}

	private Location getQuestFarmCenter(Player player)
	{
		switch(_questStage)
		{
			case FARM_WOLVES:
				return routeEnd(ROUTE_TO_WOLVES);
			case FARM_ORCS:
				return routeEnd(ROUTE_TO_ORCS);
			case FARM_WEREWOLVES_ORCS:
			case GRIND_TO_10:
				return routeEnd(ROUTE_TO_WEREWOLVES_ORCS);
			default:
				return player.getLoc();
		}
	}

	private static Location routeEnd(int[][] route)
	{
		if(route == null || route.length == 0)
			return new Location(0, 0, 0);
		int[] end = route[route.length - 1];
		return new Location(end[0], end[1], end[2]);
	}

	private NpcInstance findPreferredMonster(Player player, int[] preferredNpcIds)
	{
		List<NpcInstance> npcs = player.getAroundNpc(QUEST_FARM_RADIUS, QUEST_FARM_HEIGHT);
		NpcInstance chosen = null;
		int bestPriority = Integer.MAX_VALUE;
		int bestDist = Integer.MAX_VALUE;
		for(NpcInstance npc : npcs)
		{
			if(!npc.isMonster() || npc.isDead() || npc.isAlikeDead() || npc.isInvisible(player))
				continue;
			int pri = 1000;
			for(int i = 0; i < preferredNpcIds.length; i++)
			{
				if(npc.getNpcId() == preferredNpcIds[i])
				{
					pri = i;
					break;
				}
			}
			boolean aggroMe = npc.getAI().getAttackTarget() == player || npc.getAI().getCastTarget() == player;
			if(aggroMe)
				pri = -1;
			int d = player.getDistance(npc);
			if(pri < bestPriority || (pri == bestPriority && d < bestDist))
			{
				chosen = npc;
				bestPriority = pri;
				bestDist = d;
			}
		}
		return chosen;
	}

	private void useItemNow(Player player, int itemId)
	{
		ItemInstance item = player.getInventory().getItemByItemId(itemId);
		if(item != null)
			player.useItem(item, false, false);
	}

	private void ensureWarriorSoulshots(Player player)
	{
		if(player.isMageClass())
			return;
		long count = player.getInventory().getCountOf(SOULSHOT_NOVICE);
		if(count < MIN_SOULSHOT_STOCK)
			player.getInventory().addItem(SOULSHOT_NOVICE, MIN_SOULSHOT_STOCK - count);
	}

	private void ensureAutoLearnSkills(Player player)
	{
		int level = player.getLevel();
		if(level <= _lastAutoLearnLevel)
			return;

		try
		{
			// Bots should always keep class skills up-to-date by level.
			player.rewardSkills(false, true, true, false);
			_lastAutoLearnLevel = level;
		}
		catch(Exception e)
		{
			_log.warn("StarterPackAI: failed to auto-learn skills for {} at level {}", player.getName(), level, e);
		}
	}

	private void questDelay(long ms)
	{
		_questNextActionTime = System.currentTimeMillis() + ms;
	}

	private boolean hasAnyPositiveBuff(Player player)
	{
		for(Abnormal abnormal : player.getAbnormalList())
		{
			if(!abnormal.isOffensive())
				return true;
		}
		return false;
	}

	// =============================================
	// Skill selection for mage bots
	// =============================================

	private Skill getRandomSkill(Player player, Creature target)
	{
		ArrayList<Skill> weakSkills = new ArrayList<Skill>();
		ArrayList<Skill> skills = new ArrayList<Skill>();
		for(SkillEntry skillEntry : player.getAllSkills())
		{
			Skill skill = skillEntry.getTemplate();
			if(!skill.isActive())
				continue;
			if(player.isSkillDisabled(skill))
				continue;
			if(!skillEntry.checkCondition(player, target, false, false, true))
				continue;

			double chance = 0.0;
			switch(skill.getSkillType())
			{
				case MDAM:
					chance = player.isMageClass() ? 100.0 : 5.0;
					break;
				case DRAIN:
					chance = 15.0;
					break;
				case PDAM:
				case STUN:
				case LETHAL_SHOT:
					chance = 15.0;
					break;
				case DEBUFF:
				case ROOT:
				case DOT:
				case MDOT:
				case POISON:
				case SLEEP:
				case MUTE:
					chance = 5.0;
					break;
				default:
					continue;
			}

			// Reduce chance for AoE skills
			switch(skill.getTargetType())
			{
				case TARGET_AURA:
				case TARGET_AREA:
				case TARGET_FAN:
				case TARGET_FAN_PB:
				case TARGET_SQUARE:
				case TARGET_SQUARE_PB:
				case TARGET_RING_RANGE:
					chance /= 10.0;
					break;
			}

			if(!Rnd.chance((double) chance))
				continue;

			if(skill.getMagicLevel() < player.getLevel() - 10)
				weakSkills.add(skill);
			else
				skills.add(skill);
		}

		if(skills.isEmpty())
			skills = weakSkills;

		return (Skill) Rnd.get(skills);
	}

	@Override
	protected void onEvtAttacked(Creature attacker, Skill skill, int damage)
	{
		super.onEvtAttacked(attacker, skill, damage);
		Player player = getActor();
		if(player == null || player.isDead() || attacker == null)
			return;

		// In farming state, if attacked by a monster, fight back
		if(_botState.getCurrentState() == State.FARMING && attacker.isNpc())
		{
			if(player.getTarget() == null)
			{
				player.setTarget(attacker);
			}
		}
	}
}
