package l2s.gameserver.model.autobot;

public class CombatPreferences
{
	private TargetingPreference targetingPreference = TargetingPreference.CLOSEST;
	private int targetingRange = 2000;
	private AttackPlayerType attackPlayerType = AttackPlayerType.NONE;
	private boolean useManaPots = false;
	private boolean useHealingPots = false;
	private boolean useCpPots = false;
	private double manaPotThreshold = 0.3;
	private double healingPotThreshold = 0.3;
	private double cpPotThreshold = 0.3;

	public CombatPreferences()
	{
	}

	public TargetingPreference getTargetingPreference()
	{
		return targetingPreference;
	}

	public void setTargetingPreference(TargetingPreference targetingPreference)
	{
		this.targetingPreference = targetingPreference;
	}

	public int getTargetingRange()
	{
		return targetingRange;
	}

	public void setTargetingRange(int targetingRange)
	{
		this.targetingRange = targetingRange;
	}

	public AttackPlayerType getAttackPlayerType()
	{
		return attackPlayerType;
	}

	public void setAttackPlayerType(AttackPlayerType attackPlayerType)
	{
		this.attackPlayerType = attackPlayerType;
	}

	public boolean isUseManaPots()
	{
		return useManaPots;
	}

	public void setUseManaPots(boolean useManaPots)
	{
		this.useManaPots = useManaPots;
	}

	public boolean isUseHealingPots()
	{
		return useHealingPots;
	}

	public void setUseHealingPots(boolean useHealingPots)
	{
		this.useHealingPots = useHealingPots;
	}

	public boolean isUseCpPots()
	{
		return useCpPots;
	}

	public void setUseCpPots(boolean useCpPots)
	{
		this.useCpPots = useCpPots;
	}

	public double getManaPotThreshold()
	{
		return manaPotThreshold;
	}

	public void setManaPotThreshold(double manaPotThreshold)
	{
		this.manaPotThreshold = manaPotThreshold;
	}

	public double getHealingPotThreshold()
	{
		return healingPotThreshold;
	}

	public void setHealingPotThreshold(double healingPotThreshold)
	{
		this.healingPotThreshold = healingPotThreshold;
	}

	public double getCpPotThreshold()
	{
		return cpPotThreshold;
	}

	public void setCpPotThreshold(double cpPotThreshold)
	{
		this.cpPotThreshold = cpPotThreshold;
	}
}
