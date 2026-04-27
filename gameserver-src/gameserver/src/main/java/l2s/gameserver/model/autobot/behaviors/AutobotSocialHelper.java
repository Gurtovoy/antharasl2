package l2s.gameserver.model.autobot.behaviors;

import l2s.commons.util.Rnd;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.autobot.ActivityPreferences;
import l2s.gameserver.model.autobot.RespawnAction;
import l2s.gameserver.model.autobot.SocialPreferences;
import l2s.gameserver.model.autobot.TownAction;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.utils.TeleportUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Static utility methods for autobot social and respawn behavior.
 */
public final class AutobotSocialHelper
{
	private static final Logger _log = LoggerFactory.getLogger(AutobotSocialHelper.class);

	/** Walk radius for town wandering. */
	private static final int WALK_RADIUS_MIN = 100;
	private static final int WALK_RADIUS_MAX = 500;

	private AutobotSocialHelper()
	{
	}

	// =============================================
	// Town actions
	// =============================================

	/**
	 * Execute the configured town action for the bot.
	 *
	 * @param bot the autobot player
	 * @param prefs social preferences
	 * @param isCurrentlyWalking whether the bot is currently walking (to avoid re-triggering)
	 */
	public static void executeTownAction(Player bot, SocialPreferences prefs, boolean isCurrentlyWalking)
	{
		if(bot == null || prefs == null)
			return;

		TownAction action = prefs.getTownAction();
		if(action == null)
			action = TownAction.NONE;

		switch(action)
		{
			case SIT:
				handleSit(bot);
				break;

			case WALK:
				handleWalk(bot, isCurrentlyWalking);
				break;

			case TRADE:
				handleTrade(bot);
				break;

			case NONE:
			default:
				// Idle: stand up if sitting, do nothing else
				if(bot.isSitting())
				{
					bot.standUp();
				}
				break;
		}
	}

	private static void handleSit(Player bot)
	{
		if(!bot.isSitting() && !bot.isMovementDisabled() && !bot.getMovement().isMoving())
		{
			bot.sitDown(null);
		}
	}

	private static void handleWalk(Player bot, boolean isCurrentlyWalking)
	{
		// Stand up first if sitting
		if(bot.isSitting())
		{
			bot.standUp();
			return;
		}

		// Don't start a new walk if already moving
		if(bot.getMovement().isMoving() || bot.isMovementDisabled())
			return;

		// Random chance to walk on each tick
		if(Rnd.chance(30))
		{
			Location loc = Location.coordsRandomize(bot.getLoc(), WALK_RADIUS_MIN, WALK_RADIUS_MAX);
			bot.getMovement().moveToLocation(loc, 0, true);
		}
	}

	private static void handleTrade(Player bot)
	{
		// Private store mode is complex and requires packet support.
		// For now, just idle (stand). Can be extended later.
		if(bot.isSitting())
		{
			bot.standUp();
		}
	}

	// =============================================
	// Respawn handling
	// =============================================

	/**
	 * Handle bot respawn based on ActivityPreferences.
	 *
	 * @param bot the autobot player
	 * @param prefs activity preferences
	 * @param deathLocation the location where the bot died (may be null)
	 */
	public static void handleRespawn(Player bot, ActivityPreferences prefs, Location deathLocation)
	{
		if(bot == null || prefs == null)
			return;

		if(!bot.isDead())
			return;

		RespawnAction action = prefs.getRespawnAction();
		if(action == null)
			action = RespawnAction.TELEPORT_TO_TOWN;

		switch(action)
		{
			case RETURN_TO_DEATH_LOC:
				reviveAndTeleport(bot, deathLocation);
				break;

			case TELEPORT_TO_TOWN:
				reviveToTown(bot);
				break;

			case STAY_DEAD:
				// Do nothing — wait for manual respawn
				break;
		}
	}

	private static void reviveAndTeleport(Player bot, Location deathLoc)
	{
		try
		{
			bot.doRevive();
			bot.setCurrentHp(bot.getMaxHp() * 0.7, true, true);
			bot.setCurrentMp(bot.getMaxMp() * 0.7);
			bot.setCurrentCp(bot.getMaxCp() * 0.7);

			if(deathLoc != null)
			{
				bot.teleToLocation(deathLoc);
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotSocialHelper: Error reviving bot " + bot.getName() + " to death location", e);
		}
	}

	private static void reviveToTown(Player bot)
	{
		try
		{
			bot.doRevive();
			bot.setCurrentHp(bot.getMaxHp() * 0.7, true, true);
			bot.setCurrentMp(bot.getMaxMp() * 0.7);
			bot.setCurrentCp(bot.getMaxCp() * 0.7);

			Location townLoc = TeleportUtils.getRestartPoint(bot, RestartType.TO_VILLAGE).getLoc();
			if(townLoc != null)
			{
				bot.teleToLocation(townLoc);
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotSocialHelper: Error reviving bot " + bot.getName() + " to town", e);
		}
	}
}
