package l2s.gameserver.model.autobot;

public class AutobotScheduleInfo
{
	private int id;
	private int botId;
	private int spawnHour;
	private int spawnMinute;
	private int despawnHour = 23;
	private int despawnMinute = 59;
	private String daysOfWeek = "1,2,3,4,5,6,7";
	private boolean enabled = true;

	public AutobotScheduleInfo()
	{
	}

	public int getId()
	{
		return id;
	}

	public void setId(int id)
	{
		this.id = id;
	}

	public int getBotId()
	{
		return botId;
	}

	public void setBotId(int botId)
	{
		this.botId = botId;
	}

	public int getSpawnHour()
	{
		return spawnHour;
	}

	public void setSpawnHour(int spawnHour)
	{
		this.spawnHour = spawnHour;
	}

	public int getSpawnMinute()
	{
		return spawnMinute;
	}

	public void setSpawnMinute(int spawnMinute)
	{
		this.spawnMinute = spawnMinute;
	}

	public int getDespawnHour()
	{
		return despawnHour;
	}

	public void setDespawnHour(int despawnHour)
	{
		this.despawnHour = despawnHour;
	}

	public int getDespawnMinute()
	{
		return despawnMinute;
	}

	public void setDespawnMinute(int despawnMinute)
	{
		this.despawnMinute = despawnMinute;
	}

	public String getDaysOfWeek()
	{
		return daysOfWeek;
	}

	public void setDaysOfWeek(String daysOfWeek)
	{
		this.daysOfWeek = daysOfWeek;
	}

	public boolean isEnabled()
	{
		return enabled;
	}

	public void setEnabled(boolean enabled)
	{
		this.enabled = enabled;
	}
}
