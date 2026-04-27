package l2s.gameserver.model.autobot;

public class StarterBotState
{
	public enum State
	{
		FARMING,
		WALKING_TO_TOWN,
		IN_TOWN
	}

	private int objId;
	private String name;
	private int classId;
	private int sex;
	private State currentState = State.FARMING;
	private long spawnTime;
	private int[] townLocation; // pre-calculated with random offset

	public StarterBotState()
	{
	}

	public int getObjId()
	{
		return objId;
	}

	public void setObjId(int objId)
	{
		this.objId = objId;
	}

	public String getName()
	{
		return name;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public int getClassId()
	{
		return classId;
	}

	public void setClassId(int classId)
	{
		this.classId = classId;
	}

	public int getSex()
	{
		return sex;
	}

	public void setSex(int sex)
	{
		this.sex = sex;
	}

	public State getCurrentState()
	{
		return currentState;
	}

	public void setCurrentState(State currentState)
	{
		this.currentState = currentState;
	}

	public long getSpawnTime()
	{
		return spawnTime;
	}

	public void setSpawnTime(long spawnTime)
	{
		this.spawnTime = spawnTime;
	}

	public int[] getTownLocation()
	{
		return townLocation;
	}

	public void setTownLocation(int[] townLocation)
	{
		this.townLocation = townLocation;
	}
}
