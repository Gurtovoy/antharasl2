package l2s.gameserver.model.autobot.behaviors;

import java.util.ArrayList;
import java.util.List;

import l2s.commons.util.Rnd;
import l2s.gameserver.data.xml.holder.AutobotDataHolder;
import l2s.gameserver.data.xml.holder.AutobotDataHolder.BuffInfo;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.World;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.autobot.AttackPlayerType;
import l2s.gameserver.model.autobot.CombatPreferences;
import l2s.gameserver.model.autobot.SkillPreferences;
import l2s.gameserver.model.autobot.SkillPreferences.SkillCondition;
import l2s.gameserver.model.autobot.TargetingPreference;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Static utility methods for autobot combat behavior:
 * target finding, skill condition checking, potion usage, and buff application.
 */
public final class AutobotCombatHelper
{
	private static final Logger _log = LoggerFactory.getLogger(AutobotCombatHelper.class);

	// Common potion item IDs
	private static final int HEALING_POTION_ID = 1539;  // Greater Healing Potion
	private static final int MANA_POTION_ID = 728;       // Mana Potion
	private static final int CP_POTION_ID = 5592;        // Greater CP Potion

	private AutobotCombatHelper()
	{
	}

	// =============================================
	// Target finding
	// =============================================

	/**
	 * Find the best target based on CombatPreferences.
	 * First tries monsters, then players if attackPlayerType allows.
	 */
	public static Creature findTarget(Player bot, CombatPreferences prefs)
	{
		if(bot == null || prefs == null)
			return null;

		int range = prefs.getTargetingRange();
		if(range <= 0)
			range = 2000;

		List<Creature> candidates = new ArrayList<>();

		// Collect monsters in range
		for(NpcInstance npc : bot.getAroundNpc(range, 500))
		{
			if(!isValidMonsterTarget(bot, npc))
				continue;
			candidates.add(npc);
		}

		// Collect players if configured
		AttackPlayerType attackType = prefs.getAttackPlayerType();
		if(attackType != AttackPlayerType.NONE)
		{
			for(Player player : World.getAroundPlayers(bot, range, 500))
			{
				if(!isValidPlayerTarget(bot, player, attackType))
					continue;
				candidates.add(player);
			}
		}

		if(candidates.isEmpty())
			return null;

		return selectByPreference(bot, candidates, prefs.getTargetingPreference());
	}

	private static boolean isValidMonsterTarget(Player bot, NpcInstance npc)
	{
		if(npc == null || npc.isDead() || npc.isAlikeDead())
			return false;
		if(!npc.isMonster() || npc.isRaid())
			return false;
		if(!npc.isVisible() || npc.isInvisible(bot))
			return false;
		if(npc.isInvulnerable())
			return false;
		if(!GeoEngine.canMoveToCoord(bot.getX(), bot.getY(), bot.getZ(),
			npc.getX(), npc.getY(), npc.getZ(), bot.getGeoIndex()))
			return false;
		// Skip if level difference > 10
		if(Math.abs(bot.getLevel() - npc.getLevel()) > 10)
			return false;
		return true;
	}

	private static boolean isValidPlayerTarget(Player bot, Player target, AttackPlayerType attackType)
	{
		if(target == null || target == bot || target.isDead() || target.isAlikeDead())
			return false;
		if(!target.isVisible() || target.isInvisible(bot))
			return false;
		if(target.isInPeaceZone())
			return false;
		if(!GeoEngine.canMoveToCoord(bot.getX(), bot.getY(), bot.getZ(),
			target.getX(), target.getY(), target.getZ(), bot.getGeoIndex()))
			return false;

		switch(attackType)
		{
			case ALL:
				return target.isAutoAttackable(bot);
			case FLAGGED:
				return target.getPvpFlag() > 0;
			case KARMA:
				return target.getKarma() > 0;
			default:
				return false;
		}
	}

	private static Creature selectByPreference(Player bot, List<Creature> candidates, TargetingPreference pref)
	{
		if(candidates.isEmpty())
			return null;

		if(pref == null)
			pref = TargetingPreference.CLOSEST;

		switch(pref)
		{
			case CLOSEST:
				Creature closest = null;
				int minDist = Integer.MAX_VALUE;
				for(Creature c : candidates)
				{
					int dist = bot.getDistance(c);
					if(dist < minDist)
					{
						minDist = dist;
						closest = c;
					}
				}
				return closest;

			case WEAKEST:
				Creature weakest = null;
				double minHp = Double.MAX_VALUE;
				for(Creature c : candidates)
				{
					double hp = c.getCurrentHp();
					if(hp < minHp)
					{
						minHp = hp;
						weakest = c;
					}
				}
				return weakest;

			case RANDOM:
			default:
				return candidates.get(Rnd.get(candidates.size()));
		}
	}

	// =============================================
	// Skill condition checking
	// =============================================

	/**
	 * Check if a skill should be used based on SkillPreferences conditions.
	 * Returns true if the skill is enabled and all HP/MP conditions are met.
	 */
	public static boolean shouldUseSkill(Player bot, Creature target, int skillId, SkillPreferences prefs)
	{
		if(bot == null || prefs == null)
			return false;

		SkillCondition cond = prefs.getCondition(skillId);

		// If no specific condition configured, allow usage with low probability
		if(cond == null)
			return Rnd.chance(10);

		if(!cond.isEnabled())
			return false;

		// Check target HP % — skill should be used when target HP is at or below this threshold
		if(target != null && target.getMaxHp() > 0)
		{
			double targetHpPct = (target.getCurrentHp() / target.getMaxHp()) * 100.0;
			if(targetHpPct > cond.getTargetHpPercent())
				return false;
		}

		// Check self HP %
		if(bot.getMaxHp() > 0)
		{
			double selfHpPct = (bot.getCurrentHp() / bot.getMaxHp()) * 100.0;
			if(selfHpPct > cond.getSelfHpPercent())
				return false;
		}

		// Check self MP %
		if(bot.getMaxMp() > 0)
		{
			double selfMpPct = (bot.getCurrentMp() / bot.getMaxMp()) * 100.0;
			if(selfMpPct > cond.getSelfMpPercent())
				return false;
		}

		return true;
	}

	// =============================================
	// Potion usage
	// =============================================

	/**
	 * Check and use potions based on CombatPreferences thresholds.
	 * Returns true if a potion was used.
	 */
	public static boolean usePotion(Player bot, CombatPreferences prefs)
	{
		if(bot == null || prefs == null)
			return false;

		// HP potion
		if(prefs.isUseHealingPots() && bot.getMaxHp() > 0)
		{
			double hpPct = bot.getCurrentHp() / bot.getMaxHp();
			if(hpPct < prefs.getHealingPotThreshold())
			{
				if(tryUseItem(bot, HEALING_POTION_ID))
					return true;
			}
		}

		// MP potion
		if(prefs.isUseManaPots() && bot.getMaxMp() > 0)
		{
			double mpPct = bot.getCurrentMp() / bot.getMaxMp();
			if(mpPct < prefs.getManaPotThreshold())
			{
				if(tryUseItem(bot, MANA_POTION_ID))
					return true;
			}
		}

		// CP potion
		if(prefs.isUseCpPots() && bot.getMaxCp() > 0)
		{
			double cpPct = bot.getCurrentCp() / bot.getMaxCp();
			if(cpPct < prefs.getCpPotThreshold())
			{
				if(tryUseItem(bot, CP_POTION_ID))
					return true;
			}
		}

		return false;
	}

	private static boolean tryUseItem(Player bot, int itemId)
	{
		if(bot.getInventory() == null)
			return false;

		ItemInstance item = bot.getInventory().getItemByItemId(itemId);
		if(item == null || item.getCount() <= 0)
			return false;

		return bot.useItem(item, false, false);
	}

	// =============================================
	// Buff application
	// =============================================

	/**
	 * Apply missing buffs from AutobotDataHolder config for the given classId.
	 * Only applies buffs that are not already active on the bot.
	 */
	public static void applyBuffs(Player bot, int classId)
	{
		if(bot == null)
			return;

		List<BuffInfo> buffs = AutobotDataHolder.getInstance().getClassBuffs(classId);
		if(buffs == null || buffs.isEmpty())
			return;

		for(BuffInfo buffInfo : buffs)
		{
			int skillId = buffInfo.getSkillId();
			int skillLevel = buffInfo.getSkillLevel();

			// Check if already has this buff
			if(hasBuffActive(bot, skillId))
				continue;

			// Get the skill and apply
			Skill skill = l2s.gameserver.data.xml.holder.SkillHolder.getInstance().getSkill(skillId, skillLevel);
			if(skill == null)
				continue;

			try
			{
				skill.getEffects(bot, bot);
			}
			catch(Exception e)
			{
				_log.warn("AutobotCombatHelper: Failed to apply buff " + skillId + " to " + bot.getName(), e);
			}
		}
	}

	private static boolean hasBuffActive(Player bot, int skillId)
	{
		for(Abnormal abnormal : bot.getAbnormalList())
		{
			if(abnormal.getSkill() != null && abnormal.getSkill().getId() == skillId)
				return true;
		}
		return false;
	}
}
