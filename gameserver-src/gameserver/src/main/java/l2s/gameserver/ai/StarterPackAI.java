package l2s.gameserver.ai;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
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
import l2s.gameserver.model.World;
import l2s.gameserver.model.autobot.StarterBotState;
import l2s.gameserver.model.autobot.StarterBotState.State;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Simple combat/farming AI for starter pack bots.
 * State machine: FARMING → WALKING_TO_TOWN → IN_TOWN
 */
public class StarterPackAI extends PlayerAI implements Runnable
{
	private static final Logger _log = LoggerFactory.getLogger(StarterPackAI.class);

	private static final int THINK_INTERVAL = 1000;
	private static final int FARM_RADIUS = 800;
	private static final int FARM_HEIGHT = 200;
	private static final int MAX_MONSTER_LEVEL = 5;
	private static final int RANDOM_WALK_RADIUS = 300;
	private static final int TOWN_ARRIVAL_DIST = 100;
	private static final int TOWN_IDLE_WALK_RADIUS = 200;
	private static final long REVIVE_DELAY = 5000L;
	private static final long STUCK_TIMEOUT = 30000L;
	private static final long TOWN_IDLE_MIN = 30000L;
	private static final long TOWN_IDLE_MAX = 60000L;
	private static final int MAX_BOTS_PER_TARGET = 4;

	private static final ConcurrentHashMap<Integer, AtomicInteger> _targetCounts = new ConcurrentHashMap<>();

	private final StarterBotState _botState;
	private final int _targetLevel;
	private final Location _spawnLoc;
	private final Location _townLoc;

	private ScheduledFuture<?> _thinkTask;
	private final AtomicBoolean _active = new AtomicBoolean(false);

	// Death handling
	private long _deathTime = 0L;
	private Location _deathLocation = null;

	// Stuck detection for WALKING_TO_TOWN
	private Location _lastWalkPos = null;
	private long _lastWalkPosTime = 0L;
	private int _moveRetryCount = 0;
	private static final int MAX_MOVE_RETRIES = 5;

	// Town idle timer
	private long _nextTownWalkTime = 0L;

	// Current tracked target for target-count bookkeeping
	private int _currentTargetId = 0;

	public StarterPackAI(Player player, StarterBotState botState, int targetLevel, Location spawnLoc, Location townLoc)
	{
		super(player);
		_botState = botState;
		_targetLevel = targetLevel;
		_spawnLoc = spawnLoc;
		_townLoc = townLoc;
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
			_thinkTask = ThreadPoolManager.getInstance().scheduleAtFixedDelay(this, THINK_INTERVAL, THINK_INTERVAL);
		}
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

		// Check level transition: FARMING → WALKING_TO_TOWN
		if(_botState.getCurrentState() == State.FARMING && player.getLevel() >= _targetLevel)
		{
			_botState.setCurrentState(State.WALKING_TO_TOWN);
			_lastWalkPos = null;
			_lastWalkPosTime = System.currentTimeMillis();
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
			randomWalkNear(player, _spawnLoc, RANDOM_WALK_RADIUS);
		}
	}

	private NpcInstance findNearestMonster(Player player)
	{
		List<NpcInstance> npcs = player.getAroundNpc(FARM_RADIUS, FARM_HEIGHT);
		NpcInstance closest = null;
		int closestDist = Integer.MAX_VALUE;

		for(NpcInstance npc : npcs)
		{
			if(!npc.isMonster())
				continue;
			if(npc.isDead() || npc.isAlikeDead())
				continue;
			if(npc.getLevel() > MAX_MONSTER_LEVEL)
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
			_deathLocation = player.getLoc();
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

				if(_deathLocation != null)
				{
					player.teleToLocation(_deathLocation);
				}
			}
			catch(Exception e)
			{
				_log.error("StarterPackAI: Error reviving bot: " + e.getMessage(), e);
			}
			finally
			{
				_deathTime = 0L;
				_deathLocation = null;
			}
		}
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

		// Calculate destination from botState townLocation (pre-randomized) or fallback
		Location destination = getTownDestination();

		// Check if arrived
		if(player.getDistance(destination) <= TOWN_ARRIVAL_DIST)
		{
			_botState.setCurrentState(State.IN_TOWN);
			_nextTownWalkTime = System.currentTimeMillis() + Rnd.get((int) TOWN_IDLE_MIN, (int) TOWN_IDLE_MAX);
			player.getMovement().stopMove();
			_moveRetryCount = 0;
			return;
		}

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
				player.teleToLocation(destination);
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
				// Try walking to a random intermediate point to get unstuck
				if(_moveRetryCount < MAX_MOVE_RETRIES)
				{
					// Move toward destination but with a random offset to find a walkable path
					int dx = destination.x - player.getX();
					int dy = destination.y - player.getY();
					double dist = Math.sqrt(dx * dx + dy * dy);
					if(dist > 0)
					{
						// Move 300-500 units in the general direction with some random deviation
						int stepDist = Rnd.get(300, 500);
						int midX = player.getX() + (int)(dx / dist * stepDist) + Rnd.get(-100, 100);
						int midY = player.getY() + (int)(dy / dist * stepDist) + Rnd.get(-100, 100);
						int midZ = GeoEngine.getLowerHeight(midX, midY, player.getZ(), player.getGeoIndex());
						Location midLoc = new Location(midX, midY, midZ);
						player.getMovement().moveToLocation(midLoc, 0, true);
					}
				}
				// After MAX_MOVE_RETRIES failed attempts, let stuck detection handle teleport
			}
		}
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

		if(player.getMovement().isMoving() || player.isMovementDisabled())
			return;

		long now = System.currentTimeMillis();
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

		Location loc = Location.coordsRandomize(center, 50, radius);
		int z = GeoEngine.getLowerHeight(loc.x, loc.y, loc.z, player.getGeoIndex());
		if(GeoEngine.canMoveToCoord(player.getX(), player.getY(), player.getZ(),
			loc.x, loc.y, z, player.getGeoIndex()))
		{
			loc.z = z;
			player.getMovement().moveToLocation(loc, 0, true);
		}
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
