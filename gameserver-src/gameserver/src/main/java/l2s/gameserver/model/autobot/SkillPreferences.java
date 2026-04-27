package l2s.gameserver.model.autobot;

import java.util.HashMap;
import java.util.Map;

public class SkillPreferences
{
	private Map<Integer, SkillCondition> skillConditions = new HashMap<>();

	public SkillPreferences()
	{
	}

	public Map<Integer, SkillCondition> getSkillConditions()
	{
		return skillConditions;
	}

	public void setSkillConditions(Map<Integer, SkillCondition> skillConditions)
	{
		this.skillConditions = skillConditions;
	}

	public SkillCondition getCondition(int skillId)
	{
		return skillConditions.get(skillId);
	}

	public void setCondition(int skillId, SkillCondition condition)
	{
		skillConditions.put(skillId, condition);
	}

	public static class SkillCondition
	{
		private double targetHpPercent = 100.0;
		private double selfHpPercent = 100.0;
		private double selfMpPercent = 100.0;
		private boolean isEnabled = true;

		public SkillCondition()
		{
		}

		public SkillCondition(double targetHpPercent, double selfHpPercent, double selfMpPercent, boolean isEnabled)
		{
			this.targetHpPercent = targetHpPercent;
			this.selfHpPercent = selfHpPercent;
			this.selfMpPercent = selfMpPercent;
			this.isEnabled = isEnabled;
		}

		public double getTargetHpPercent()
		{
			return targetHpPercent;
		}

		public void setTargetHpPercent(double targetHpPercent)
		{
			this.targetHpPercent = targetHpPercent;
		}

		public double getSelfHpPercent()
		{
			return selfHpPercent;
		}

		public void setSelfHpPercent(double selfHpPercent)
		{
			this.selfHpPercent = selfHpPercent;
		}

		public double getSelfMpPercent()
		{
			return selfMpPercent;
		}

		public void setSelfMpPercent(double selfMpPercent)
		{
			this.selfMpPercent = selfMpPercent;
		}

		public boolean isEnabled()
		{
			return isEnabled;
		}

		public void setEnabled(boolean enabled)
		{
			this.isEnabled = enabled;
		}
	}
}
