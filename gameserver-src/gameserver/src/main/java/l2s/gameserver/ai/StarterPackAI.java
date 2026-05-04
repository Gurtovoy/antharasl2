package l2s.gameserver.ai;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
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
	private static final int FARM_RADIUS = 800;
	private static final int FARM_HEIGHT = 200;
	private static final int BASE_MAX_MOB_LEVEL = 5;
	private static final int WAYPOINT_JITTER_XY = 42;
	private static final int RANDOM_WALK_RADIUS = 300;
	private static final int TOWN_ARRIVAL_DIST = 100;
	private static final int WAYPOINT_ARRIVAL_DIST = 150;
	private static final int TOWN_IDLE_WALK_RADIUS = 200;
	private static final long REVIVE_DELAY = 5000L;
	private static final long STUCK_TIMEOUT = 30000L;
	private static final long TOWN_IDLE_MIN = 30000L;
	private static final long TOWN_IDLE_MAX = 60000L;
	private static final int MAX_BOTS_PER_TARGET = 4;

	private static final ConcurrentHashMap<Integer, AtomicInteger> _targetCounts = new ConcurrentHashMap<>();

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

	public StarterPackAI(Player player, StarterBotState botState, int targetLevel, Location spawnLoc, Location townLoc)
	{
		super(player);
		_botState = botState;
		_targetLevel = targetLevel;
		_farmCenter = spawnLoc.clone();
		_townLoc = townLoc;
		_townPath = StarterPackTownPaths.getPathForClass(_botState.getClassId());
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
			// Claim the new target
			_currentTargetId = target.getObjectId();
			_targetCounts.computeIfAbsent(_currentTargetId, k -> new AtomicInteger(0)).incrementAndGet();

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
		List<NpcInstance> npcs = player.getAroundNpc(_farmRadius, _farmHeight);
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
			// Skip monsters already targeted by too many bots
			AtomicInteger cnt = _targetCounts.get(npc.getObjectId());
			if(cnt != null && cnt.get() >= MAX_BOTS_PER_TARGET)
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
		return closest;
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
			if(!player.getMovement().moveToLocation(destination, 0, true))
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
