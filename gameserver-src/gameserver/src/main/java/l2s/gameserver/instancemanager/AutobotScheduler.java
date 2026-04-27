package l2s.gameserver.instancemanager;

import java.time.ZoneOffset;
import java.time.ZonedDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import l2s.gameserver.dao.AutobotsDAO;
import l2s.gameserver.model.autobot.AutobotScheduleInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AutobotScheduler
{
	private static final Logger _log = LoggerFactory.getLogger(AutobotScheduler.class);
	private static final AutobotScheduler _instance = new AutobotScheduler();

	private final List<AutobotScheduleInfo> _schedules = new ArrayList<>();
	private ScheduledExecutorService _executor;
	private final Set<Integer> _spawnedByScheduler = ConcurrentHashMap.newKeySet();
	/** Tracks bots that were manually despawned during their window, so we don't re-spawn them every tick. */
	private final Set<Integer> _manuallyDespawned = ConcurrentHashMap.newKeySet();

	public static AutobotScheduler getInstance()
	{
		return _instance;
	}

	private AutobotScheduler()
	{
	}

	public void init()
	{
		synchronized(_schedules)
		{
			_schedules.clear();
			try
			{
				_schedules.addAll(AutobotsDAO.getInstance().loadSchedules());
			}
			catch(Exception e)
			{
				_log.error("AutobotScheduler: Failed to load schedules from DB: " + e.getMessage(), e);
			}
		}

		_executor = Executors.newSingleThreadScheduledExecutor(r -> {
			Thread t = new Thread(r, "AutobotScheduler");
			t.setDaemon(true);
			return t;
		});

		_executor.scheduleAtFixedRate(() -> {
			try
			{
				checkSchedules();
			}
			catch(Exception e)
			{
				_log.error("AutobotScheduler: Error in checkSchedules: " + e.getMessage(), e);
			}
		}, 60, 60, TimeUnit.SECONDS);

		_log.info("AutobotScheduler: Loaded " + _schedules.size() + " schedule(s). Checker started (60s interval).");
	}

	public void shutdown()
	{
		_log.info("AutobotScheduler: Shutting down...");
		if(_executor != null && !_executor.isShutdown())
		{
			_executor.shutdownNow();
		}

		// Despawn all bots that were spawned by the scheduler
		for(int botId : new ArrayList<>(_spawnedByScheduler))
		{
			try
			{
				AutobotsManager.getInstance().despawnBot(botId);
			}
			catch(Exception e)
			{
				_log.error("AutobotScheduler: Error despawning bot " + botId + " during shutdown: " + e.getMessage(), e);
			}
		}
		_spawnedByScheduler.clear();
		_manuallyDespawned.clear();
		_log.info("AutobotScheduler: Shutdown complete.");
	}

	public void reload()
	{
		synchronized(_schedules)
		{
			_schedules.clear();
			try
			{
				_schedules.addAll(AutobotsDAO.getInstance().loadSchedules());
			}
			catch(Exception e)
			{
				_log.error("AutobotScheduler: Failed to reload schedules from DB: " + e.getMessage(), e);
			}
		}
		_manuallyDespawned.clear();
		_log.info("AutobotScheduler: Reloaded " + _schedules.size() + " schedule(s).");
	}

	private void checkSchedules()
	{
		ZonedDateTime now = ZonedDateTime.now(ZoneOffset.UTC);
		int currentHour = now.getHour();
		int currentMinute = now.getMinute();
		int currentDow = now.getDayOfWeek().getValue(); // 1=Monday .. 7=Sunday

		List<AutobotScheduleInfo> snapshot;
		synchronized(_schedules)
		{
			snapshot = new ArrayList<>(_schedules);
		}

		for(AutobotScheduleInfo schedule : snapshot)
		{
			if(!schedule.isEnabled())
			{
				continue;
			}

			int botId = schedule.getBotId();

			if(!isDayMatch(schedule.getDaysOfWeek(), currentDow))
			{
				// Not the right day — if bot was spawned by scheduler, despawn it
				if(_spawnedByScheduler.contains(botId))
				{
					despawnScheduledBot(botId);
				}
				continue;
			}

			boolean inWindow = isInWindow(schedule, currentHour, currentMinute);
			boolean botActive = AutobotsManager.getInstance().isActive(botId);

			if(inWindow)
			{
				if(!botActive && !_manuallyDespawned.contains(botId))
				{
					// Should be spawned and isn't active — spawn it
					try
					{
						AutobotsManager.getInstance().spawnBot(botId);
						_spawnedByScheduler.add(botId);
						_log.info("AutobotScheduler: Spawned bot " + botId + " (schedule #" + schedule.getId() + ").");
					}
					catch(Exception e)
					{
						_log.error("AutobotScheduler: Failed to spawn bot " + botId + ": " + e.getMessage(), e);
					}
				}
				else if(!botActive && _spawnedByScheduler.contains(botId))
				{
					// Bot was spawned by scheduler but is no longer active — manually despawned
					_spawnedByScheduler.remove(botId);
					_manuallyDespawned.add(botId);
				}
			}
			else
			{
				// Outside window — clear manual-despawn tracking for next window
				_manuallyDespawned.remove(botId);

				if(botActive && _spawnedByScheduler.contains(botId))
				{
					// Only despawn if we spawned it
					despawnScheduledBot(botId);
				}
			}
		}
	}

	private void despawnScheduledBot(int botId)
	{
		try
		{
			AutobotsManager.getInstance().despawnBot(botId);
			_log.info("AutobotScheduler: Despawned bot " + botId + " (outside schedule window).");
		}
		catch(Exception e)
		{
			_log.error("AutobotScheduler: Failed to despawn bot " + botId + ": " + e.getMessage(), e);
		}
		_spawnedByScheduler.remove(botId);
	}

	/**
	 * Check if the current time falls within the spawn window.
	 * Handles midnight-crossing windows (e.g. 22:00 - 06:00).
	 */
	private boolean isInWindow(AutobotScheduleInfo schedule, int currentHour, int currentMinute)
	{
		int spawnMinutes = schedule.getSpawnHour() * 60 + schedule.getSpawnMinute();
		int despawnMinutes = schedule.getDespawnHour() * 60 + schedule.getDespawnMinute();
		int currentMinutes = currentHour * 60 + currentMinute;

		if(spawnMinutes <= despawnMinutes)
		{
			// Normal window: e.g. 08:00 - 22:00
			return currentMinutes >= spawnMinutes && currentMinutes < despawnMinutes;
		}
		else
		{
			// Crosses midnight: e.g. 22:00 - 06:00
			return currentMinutes >= spawnMinutes || currentMinutes < despawnMinutes;
		}
	}

	/**
	 * Check if current day of week matches the schedule's daysOfWeek string.
	 * daysOfWeek is comma-separated: "1,2,3,4,5,6,7" where 1=Monday, 7=Sunday.
	 */
	private boolean isDayMatch(String daysOfWeek, int currentDow)
	{
		if(daysOfWeek == null || daysOfWeek.isEmpty())
		{
			return false;
		}

		String dowStr = String.valueOf(currentDow);
		for(String day : daysOfWeek.split(","))
		{
			if(day.trim().equals(dowStr))
			{
				return true;
			}
		}
		return false;
	}

	// --- Schedule management methods ---

	public List<AutobotScheduleInfo> getSchedules()
	{
		synchronized(_schedules)
		{
			return new ArrayList<>(_schedules);
		}
	}

	public AutobotScheduleInfo getScheduleById(int id)
	{
		synchronized(_schedules)
		{
			for(AutobotScheduleInfo s : _schedules)
			{
				if(s.getId() == id)
				{
					return s;
				}
			}
		}
		return null;
	}

	public void addSchedule(AutobotScheduleInfo schedule)
	{
		try
		{
			AutobotsDAO.getInstance().saveSchedule(schedule);
		}
		catch(Exception e)
		{
			_log.error("AutobotScheduler: Failed to save schedule: " + e.getMessage(), e);
		}
		synchronized(_schedules)
		{
			_schedules.add(schedule);
		}
	}

	public void removeSchedule(int scheduleId)
	{
		try
		{
			AutobotsDAO.getInstance().deleteSchedule(scheduleId);
		}
		catch(Exception e)
		{
			_log.error("AutobotScheduler: Failed to delete schedule " + scheduleId + ": " + e.getMessage(), e);
		}
		synchronized(_schedules)
		{
			_schedules.removeIf(s -> s.getId() == scheduleId);
		}
	}
}
