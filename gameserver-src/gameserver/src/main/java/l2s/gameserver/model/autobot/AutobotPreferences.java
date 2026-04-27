package l2s.gameserver.model.autobot;

import com.google.gson.Gson;

public class AutobotPreferences
{
	private static final Gson GSON = new Gson();

	private CombatPreferences combatPrefs;
	private SocialPreferences socialPrefs;
	private ActivityPreferences activityPrefs;
	private SkillPreferences skillPrefs;

	public AutobotPreferences()
	{
		this.combatPrefs = new CombatPreferences();
		this.socialPrefs = new SocialPreferences();
		this.activityPrefs = new ActivityPreferences();
		this.skillPrefs = new SkillPreferences();
	}

	public AutobotPreferences(CombatPreferences combatPrefs, SocialPreferences socialPrefs, ActivityPreferences activityPrefs, SkillPreferences skillPrefs)
	{
		this.combatPrefs = combatPrefs;
		this.socialPrefs = socialPrefs;
		this.activityPrefs = activityPrefs;
		this.skillPrefs = skillPrefs;
	}

	public CombatPreferences getCombatPrefs()
	{
		return combatPrefs;
	}

	public void setCombatPrefs(CombatPreferences combatPrefs)
	{
		this.combatPrefs = combatPrefs;
	}

	public SocialPreferences getSocialPrefs()
	{
		return socialPrefs;
	}

	public void setSocialPrefs(SocialPreferences socialPrefs)
	{
		this.socialPrefs = socialPrefs;
	}

	public ActivityPreferences getActivityPrefs()
	{
		return activityPrefs;
	}

	public void setActivityPrefs(ActivityPreferences activityPrefs)
	{
		this.activityPrefs = activityPrefs;
	}

	public SkillPreferences getSkillPrefs()
	{
		return skillPrefs;
	}

	public void setSkillPrefs(SkillPreferences skillPrefs)
	{
		this.skillPrefs = skillPrefs;
	}

	public static String toJson(Object prefs)
	{
		if(prefs == null)
			return null;
		return GSON.toJson(prefs);
	}

	public static <T> T fromJson(String json, Class<T> clazz)
	{
		if(json == null || json.isEmpty())
			return null;
		return GSON.fromJson(json, clazz);
	}
}
