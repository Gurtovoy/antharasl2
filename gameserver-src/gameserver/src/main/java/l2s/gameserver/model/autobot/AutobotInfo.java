package l2s.gameserver.model.autobot;

import java.sql.Timestamp;

public class AutobotInfo
{
	private int objId;
	private String name;
	private int level;
	private int classId;
	private int baseClass;
	private int race;
	private int sex;
	private int face;
	private int hairStyle;
	private int hairColor;
	private int x;
	private int y;
	private int z;
	private int heading;
	private String title;
	private String combatPrefsJson;
	private String socialPrefsJson;
	private String activityPrefsJson;
	private String skillPrefsJson;
	private boolean isOnline;
	private Timestamp creationDate;

	public AutobotInfo()
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

	public int getLevel()
	{
		return level;
	}

	public void setLevel(int level)
	{
		this.level = level;
	}

	public int getClassId()
	{
		return classId;
	}

	public void setClassId(int classId)
	{
		this.classId = classId;
	}

	public int getBaseClass()
	{
		return baseClass;
	}

	public void setBaseClass(int baseClass)
	{
		this.baseClass = baseClass;
	}

	public int getRace()
	{
		return race;
	}

	public void setRace(int race)
	{
		this.race = race;
	}

	public int getSex()
	{
		return sex;
	}

	public void setSex(int sex)
	{
		this.sex = sex;
	}

	public int getFace()
	{
		return face;
	}

	public void setFace(int face)
	{
		this.face = face;
	}

	public int getHairStyle()
	{
		return hairStyle;
	}

	public void setHairStyle(int hairStyle)
	{
		this.hairStyle = hairStyle;
	}

	public int getHairColor()
	{
		return hairColor;
	}

	public void setHairColor(int hairColor)
	{
		this.hairColor = hairColor;
	}

	public int getX()
	{
		return x;
	}

	public void setX(int x)
	{
		this.x = x;
	}

	public int getY()
	{
		return y;
	}

	public void setY(int y)
	{
		this.y = y;
	}

	public int getZ()
	{
		return z;
	}

	public void setZ(int z)
	{
		this.z = z;
	}

	public int getHeading()
	{
		return heading;
	}

	public void setHeading(int heading)
	{
		this.heading = heading;
	}

	public String getTitle()
	{
		return title;
	}

	public void setTitle(String title)
	{
		this.title = title;
	}

	public String getCombatPrefsJson()
	{
		return combatPrefsJson;
	}

	public void setCombatPrefsJson(String combatPrefsJson)
	{
		this.combatPrefsJson = combatPrefsJson;
	}

	public String getSocialPrefsJson()
	{
		return socialPrefsJson;
	}

	public void setSocialPrefsJson(String socialPrefsJson)
	{
		this.socialPrefsJson = socialPrefsJson;
	}

	public String getActivityPrefsJson()
	{
		return activityPrefsJson;
	}

	public void setActivityPrefsJson(String activityPrefsJson)
	{
		this.activityPrefsJson = activityPrefsJson;
	}

	public String getSkillPrefsJson()
	{
		return skillPrefsJson;
	}

	public void setSkillPrefsJson(String skillPrefsJson)
	{
		this.skillPrefsJson = skillPrefsJson;
	}

	public boolean isOnline()
	{
		return isOnline;
	}

	public void setOnline(boolean online)
	{
		this.isOnline = online;
	}

	public Timestamp getCreationDate()
	{
		return creationDate;
	}

	public void setCreationDate(Timestamp creationDate)
	{
		this.creationDate = creationDate;
	}

	// Typed preference accessors via Gson

	public CombatPreferences getCombatPrefs()
	{
		CombatPreferences prefs = AutobotPreferences.fromJson(combatPrefsJson, CombatPreferences.class);
		return prefs != null ? prefs : new CombatPreferences();
	}

	public void setCombatPrefs(CombatPreferences prefs)
	{
		this.combatPrefsJson = AutobotPreferences.toJson(prefs);
	}

	public SocialPreferences getSocialPrefs()
	{
		SocialPreferences prefs = AutobotPreferences.fromJson(socialPrefsJson, SocialPreferences.class);
		return prefs != null ? prefs : new SocialPreferences();
	}

	public void setSocialPrefs(SocialPreferences prefs)
	{
		this.socialPrefsJson = AutobotPreferences.toJson(prefs);
	}

	public ActivityPreferences getActivityPrefs()
	{
		ActivityPreferences prefs = AutobotPreferences.fromJson(activityPrefsJson, ActivityPreferences.class);
		return prefs != null ? prefs : new ActivityPreferences();
	}

	public void setActivityPrefs(ActivityPreferences prefs)
	{
		this.activityPrefsJson = AutobotPreferences.toJson(prefs);
	}

	public SkillPreferences getSkillPrefs()
	{
		SkillPreferences prefs = AutobotPreferences.fromJson(skillPrefsJson, SkillPreferences.class);
		return prefs != null ? prefs : new SkillPreferences();
	}

	public void setSkillPrefs(SkillPreferences prefs)
	{
		this.skillPrefsJson = AutobotPreferences.toJson(prefs);
	}
}
