package l2s.gameserver.model.autobot;

public class ActivityPreferences
{
	private RespawnAction respawnAction = RespawnAction.TELEPORT_TO_TOWN;
	private boolean isScheduled = false;

	public ActivityPreferences()
	{
	}

	public RespawnAction getRespawnAction()
	{
		return respawnAction;
	}

	public void setRespawnAction(RespawnAction respawnAction)
	{
		this.respawnAction = respawnAction;
	}

	public boolean isScheduled()
	{
		return isScheduled;
	}

	public void setScheduled(boolean scheduled)
	{
		this.isScheduled = scheduled;
	}
}
