package l2s.gameserver.ai;

import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.atomic.AtomicBoolean;

import l2s.commons.util.Rnd;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.data.xml.holder.AutobotDataHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.autobot.ActivityPreferences;
import l2s.gameserver.model.autobot.AutobotPreferences;
import l2s.gameserver.model.autobot.CombatPreferences;
import l2s.gameserver.model.autobot.SkillPreferences;
import l2s.gameserver.model.autobot.SocialPreferences;
import l2s.gameserver.model.autobot.TownAction;
import l2s.gameserver.model.autobot.behaviors.AutobotCombatHelper;
import l2s.gameserver.model.autobot.behaviors.AutobotSocialHelper;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * AI for autobots managed by the AutobotsManager system.
 * Extends PlayerAI and adds configurable behavior based on AutobotPreferences:
 * combat targeting, skill usage, potion usage, social behavior, and respawn handling.
 */
public class AutobotAI extends PlayerAI implements Runnable
{
	private static final Logger _log = LoggerFactory.getLogger(AutobotAI.class);

	/** Default think interval in ms, overridden by config. */
	private static final int DEFAULT_THINK_INTERVAL = 350;

	/** Minimum delay between buff checks (ms). */
	private static final long BUFF_CHECK_INTERVAL = 60_000L;

	/** Minimum delay between potion uses (ms) to avoid spam. */
	private static final long POTION_COOLDOWN = 3_000L;

	/** Minimum delay between social action ticks (ms). */
	private static final long SOCIAL_ACTION_INTERVAL = 10_000L;

	private final AutobotPreferences _preferences;
	private ScheduledFuture<?> _thinkTask;
	private final AtomicBoolean _active = new AtomicBoolean(false);

	// Timestamps for throttling
	private long _lastBuffCheckTime = 0L;
	private long _lastPotionTime = 0L;
	private long _lastSocialActionTime = 0L;

	// Death location for RETURN_TO_DEATH_LOC respawn
	private Location _deathLocation = null;

	// Walking state tracking
	private boolean _isSocialWalking = false;

	public AutobotAI(Player player, AutobotPreferences preferences)
	{
		super(player);
		this._preferences = preferences != null ? preferences : new AutobotPreferences();
	}

	public AutobotPreferences getPreferences()
	{
		return _preferences;
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
		return true;
	}

	public synchronized void startThinking()
	{
		if(_thinkTask == null)
		{
			_active.set(true);
			int interval = AutobotDataHolder.getInstance().getConfig().getThinkIterationMs();
			if(interval <= 0)
				interval = DEFAULT_THINK_INTERVAL;
			_thinkTask = ThreadPoolManager.getInstance().scheduleAtFixedDelay(this, interval, interval);
		}
	}

	public synchronized void stopThinking()
	{
		_active.set(false);
		if(_thinkTask != null)
		{
			_thinkTask.cancel(false);
			_thinkTask = null;
		}
	}

	// =============================================
	// Main think loop (called by scheduler)
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
			_log.error("AutobotAI: Error in think loop for " + getActorName() + ": " + e.getMessage(), e);
		}
	}

	private synchronized void think()
	{
		Player player = getActor();
		if(player == null)
			return;

		// --- Dead: handle respawn ---
		if(player.isDead() || player.isAlikeDead())
		{
			handleDeath(player);
			return;
		}

		// --- In peace zone (town): social behavior ---
		if(player.isInPeaceZone())
		{
			handleSocialBehavior(player);
			return;
		}

		// --- Outside town: combat behavior ---
		handleCombatBehavior(player);
	}

	// =============================================
	// Death / Respawn
	// =============================================

	@Override
	protected void onEvtDead(Creature killer)
	{
		Player player = getActor();
		if(player != null)
		{
			_deathLocation = player.getLoc();
		}
		super.onEvtDead(killer);
	}

	private void handleDeath(Player player)
	{
		ActivityPreferences actPrefs = _preferences.getActivityPrefs();
		if(actPrefs == null)
			actPrefs = new ActivityPreferences();

		AutobotSocialHelper.handleRespawn(player, actPrefs, _deathLocation);
	}

	// =============================================
	// Combat behavior
	// =============================================

	private void handleCombatBehavior(Player player)
	{
		CombatPreferences combatPrefs = _preferences.getCombatPrefs();
		SkillPreferences skillPrefs = _preferences.getSkillPrefs();
		if(combatPrefs == null)
			combatPrefs = new CombatPreferences();
		if(skillPrefs == null)
			skillPrefs = new SkillPreferences();

		// 1. Check potions
		long now = System.currentTimeMillis();
		if(now - _lastPotionTime > POTION_COOLDOWN)
		{
			if(AutobotCombatHelper.usePotion(player, combatPrefs))
			{
				_lastPotionTime = now;
			}
		}

		// 2. Auto-buff if needed
		if(now - _lastBuffCheckTime > BUFF_CHECK_INTERVAL)
		{
			AutobotCombatHelper.applyBuffs(player, player.getClassId().getId());
			_lastBuffCheckTime = now;
		}

		// 3. Check current target validity
		Creature currentTarget = getValidCurrentTarget(player);

		// 4. If no valid target, find one
		if(currentTarget == null)
		{
			currentTarget = AutobotCombatHelper.findTarget(player, combatPrefs);
			if(currentTarget != null)
			{
				player.setTarget(currentTarget);
			}
			else
			{
				// Nothing to attack — idle wander
				idleWander(player);
				return;
			}
		}

		// 5. Try to use a skill with conditions met
		if(tryUseSkill(player, currentTarget, skillPrefs))
		{
			return;
		}

		// 6. Default: auto-attack
		if(!player.isAttackingNow() && !player.isCastingNow())
		{
			Attack(currentTarget, true, false);
		}
	}

	private Creature getValidCurrentTarget(Player player)
	{
		if(player.getTarget() == null || !(player.getTarget() instanceof Creature))
			return null;

		Creature target = (Creature) player.getTarget();
		if(target.isDead() || target.isAlikeDead() || !target.isVisible() || target.isInvisible(player))
			return null;

		if(player.getDistance(target) > _preferences.getCombatPrefs().getTargetingRange())
			return null;

		return target;
	}

	/**
	 * Try to use a configured skill from SkillPreferences.
	 * Returns true if a skill cast was initiated.
	 */
	private boolean tryUseSkill(Player player, Creature target, SkillPreferences skillPrefs)
	{
		if(player.isCastingNow())
			return false;

		for(SkillEntry se : player.getAllSkills())
		{
			Skill skill = se.getTemplate();
			if(!skill.isActive() || player.isSkillDisabled(skill))
				continue;

			if(AutobotCombatHelper.shouldUseSkill(player, target, skill.getId(), skillPrefs))
			{
				if(se.checkCondition(player, target, false, false, true))
				{
					Cast(SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill), target, false, false);
					return true;
				}
			}
		}
		return false;
	}

	private void idleWander(Player player)
	{
		if(player.getMovement().isMoving() || player.isMovementDisabled())
			return;

		// Random wander within small radius
		if(Rnd.chance(15))
		{
			Location loc = Location.coordsRandomize(player.getLoc(), 100, 400);
			player.getMovement().moveToLocation(loc, 0, true);
		}
	}

	// =============================================
	// Social behavior (in town/peace zone)
	// =============================================

	private void handleSocialBehavior(Player player)
	{
		SocialPreferences socialPrefs = _preferences.getSocialPrefs();
		if(socialPrefs == null)
			socialPrefs = new SocialPreferences();

		// Also check buffs while in town
		long now = System.currentTimeMillis();
		if(now - _lastBuffCheckTime > BUFF_CHECK_INTERVAL)
		{
			AutobotCombatHelper.applyBuffs(player, player.getClassId().getId());
			_lastBuffCheckTime = now;
		}

		// Throttle social actions
		if(now - _lastSocialActionTime < SOCIAL_ACTION_INTERVAL)
			return;

		_lastSocialActionTime = now;
		AutobotSocialHelper.executeTownAction(player, socialPrefs, _isSocialWalking);

		// Track walking state
		TownAction action = socialPrefs.getTownAction();
		_isSocialWalking = (action == TownAction.WALK && player.getMovement().isMoving());
	}

	// =============================================
	// React to being attacked
	// =============================================

	@Override
	protected void onEvtAttacked(Creature attacker, Skill skill, int damage)
	{
		super.onEvtAttacked(attacker, skill, damage);
		Player player = getActor();
		if(player == null || player.isDead() || attacker == null)
			return;

		// If not already targeting something, target the attacker
		if(player.getTarget() == null && !player.isInPeaceZone())
		{
			player.setTarget(attacker);
		}
		// If currently targeting a monster but a player attacks us, consider switching
		else if(attacker.isPlayer() && !player.isInPeaceZone())
		{
			CombatPreferences combatPrefs = _preferences.getCombatPrefs();
			if(combatPrefs != null && combatPrefs.getAttackPlayerType() != l2s.gameserver.model.autobot.AttackPlayerType.NONE)
			{
				if(Rnd.chance(50))
				{
					player.setTarget(attacker);
				}
			}
		}
	}

	// =============================================
	// Utility
	// =============================================

	private String getActorName()
	{
		Player actor = getActor();
		return actor != null ? actor.getName() : "unknown";
	}
}
