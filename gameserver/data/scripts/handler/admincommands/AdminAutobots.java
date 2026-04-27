package handler.admincommands;

import java.util.List;
import l2s.gameserver.dao.AutobotsDAO;
import l2s.gameserver.instancemanager.AutobotsManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.autobot.*;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.Race;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.network.l2.components.HtmlMessage;

public class AdminAutobots extends ScriptAdminCommand
{
	private static final int PAGE_SIZE = 15;

	private enum Commands
	{
		admin_autobots,
		admin_autobots_spawn,
		admin_autobots_spawn_random,
		admin_autobots_despawn,
		admin_autobots_despawn_all,
		admin_autobots_list,
		admin_autobots_info,
		admin_autobots_create,
		admin_autobots_delete,
		admin_autobots_online
	}

	@Override
	public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar)
	{
		Commands command = (Commands) comm;
		try
		{
			switch(command)
			{
				case admin_autobots:
					showDashboard(activeChar, 0);
					break;

				case admin_autobots_spawn:
				{
					if(wordList.length < 2)
					{
						activeChar.sendMessage("Usage: //autobots_spawn <name>");
						return true;
					}
					String name = wordList[1];
					Player bot = AutobotsManager.getInstance().spawnBotByName(name);
					if(bot != null)
						activeChar.sendMessage("Bot '" + name + "' spawned successfully.");
					else
						activeChar.sendMessage("Failed to spawn bot '" + name + "'. Check server log.");
					showDashboard(activeChar, 0);
					break;
				}

				case admin_autobots_spawn_random:
				{
					int count = 10;
					if(wordList.length >= 2)
					{
						try { count = Integer.parseInt(wordList[1]); } catch(NumberFormatException ignore) {}
					}
					AutobotsManager.getInstance().spawnRandom(count);
					activeChar.sendMessage("Scheduled spawn of " + count + " random bots.");
					showDashboard(activeChar, 0);
					break;
				}

				case admin_autobots_despawn:
				{
					if(wordList.length < 2)
					{
						activeChar.sendMessage("Usage: //autobots_despawn <name>");
						return true;
					}
					String name = wordList[1];
					Player bot = AutobotsManager.getInstance().getActiveBotByName(name);
					if(bot != null)
					{
						AutobotsManager.getInstance().despawnBot(bot.getObjectId());
						activeChar.sendMessage("Bot '" + name + "' despawned.");
					}
					else
						activeChar.sendMessage("Bot '" + name + "' is not online.");
					showDashboard(activeChar, 0);
					break;
				}

				case admin_autobots_despawn_all:
				{
					AutobotsManager.getInstance().despawnAll();
					activeChar.sendMessage("All bots despawned.");
					showDashboard(activeChar, 0);
					break;
				}

				case admin_autobots_list:
				{
					int page = 0;
					if(wordList.length >= 2)
					{
						try { page = Integer.parseInt(wordList[1]); } catch(NumberFormatException ignore) {}
					}
					showBotList(activeChar, page);
					break;
				}

				case admin_autobots_info:
				{
					if(wordList.length < 2)
					{
						activeChar.sendMessage("Usage: //autobots_info <name>");
						return true;
					}
					String name = wordList[1];
					showBotInfo(activeChar, name);
					break;
				}

				case admin_autobots_create:
				{
					// //autobots_create <name> <race> <classId> <sex> <level>
					if(wordList.length < 6)
					{
						showCreateForm(activeChar);
						return true;
					}
					String name = wordList[1];
					int raceId = parseIdValue(wordList[2]);
					int classId = parseIdValue(wordList[3]);
					int sexId = parseIdValue(wordList[4]);
					int level = parseIdValue(wordList[5]);

					// Validate
					if(level < 1 || level > 85)
					{
						activeChar.sendMessage("Level must be between 1 and 85.");
						showCreateForm(activeChar);
						return true;
					}

					AutobotInfo existing = AutobotsDAO.getInstance().loadByName(name);
					if(existing != null)
					{
						activeChar.sendMessage("Bot with name '" + name + "' already exists.");
						showCreateForm(activeChar);
						return true;
					}

					AutobotInfo info = new AutobotInfo();
					info.setName(name);
					info.setRace(raceId);
					info.setClassId(classId);
					info.setBaseClass(classId);
					info.setSex(sexId);
					info.setLevel(level);
					// Set default location (Talking Island)
					info.setX(-84318);
					info.setY(244579);
					info.setZ(-3730);

					AutobotsManager.getInstance().saveBotInfo(info);
					activeChar.sendMessage("Bot '" + name + "' created successfully.");
					showDashboard(activeChar, 0);
					break;
				}

				case admin_autobots_delete:
				{
					if(wordList.length < 2)
					{
						activeChar.sendMessage("Usage: //autobots_delete <name>");
						return true;
					}
					String name = wordList[1];
					AutobotInfo info = AutobotsDAO.getInstance().loadByName(name);
					if(info == null)
					{
						activeChar.sendMessage("Bot '" + name + "' not found.");
						return true;
					}
					AutobotsManager.getInstance().deleteBotInfo(info.getObjId());
					activeChar.sendMessage("Bot '" + name + "' deleted.");
					showDashboard(activeChar, 0);
					break;
				}

				case admin_autobots_online:
				{
					showOnlineBots(activeChar);
					break;
				}
			}
		}
		catch(Exception e)
		{
			activeChar.sendMessage("Error: " + e.getMessage());
		}
		return true;
	}

	// ========== HTML Pages ==========

	private void showDashboard(Player player, int page)
	{
		int totalBots = AutobotsDAO.getInstance().countBots(null);
		int onlineBots = AutobotsManager.getInstance().getActiveBotCount();
		int offlineBots = totalBots - onlineBots;

		int totalPages = Math.max(1, (int) Math.ceil((double) totalBots / PAGE_SIZE));
		if(page < 0) page = 0;
		if(page >= totalPages) page = totalPages - 1;

		List<AutobotInfo> bots = AutobotsManager.getInstance().searchBots(null, page, PAGE_SIZE);

		StringBuilder sb = new StringBuilder();
		sb.append("<html><head><title>Autobots Management</title></head><body>");
		sb.append("<center><font color=\"LEVEL\">Autobots Management Panel</font></center><br>");

		// Stats bar
		sb.append("<center>");
		sb.append("<table width=300 bgcolor=\"000000\">");
		sb.append("<tr>");
		sb.append("<td align=center width=100>Total: <font color=\"LEVEL\">").append(totalBots).append("</font></td>");
		sb.append("<td align=center width=100>Online: <font color=\"00FF00\">").append(onlineBots).append("</font></td>");
		sb.append("<td align=center width=100>Offline: <font color=\"FF0000\">").append(offlineBots).append("</font></td>");
		sb.append("</tr></table></center><br>");

		// Quick actions
		sb.append("<center>");
		sb.append("<table width=360>");
		sb.append("<tr>");
		sb.append("<td><button value=\"Spawn 10\" action=\"bypass -h admin_autobots_spawn_random 10\" width=85 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("<td><button value=\"Spawn 50\" action=\"bypass -h admin_autobots_spawn_random 50\" width=85 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("<td><button value=\"Despawn All\" action=\"bypass -h admin_autobots_despawn_all\" width=85 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("<td><button value=\"Create New\" action=\"bypass -h admin_autobots_create\" width=85 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("</tr>");
		sb.append("<tr>");
		sb.append("<td><button value=\"Online List\" action=\"bypass -h admin_autobots_online\" width=85 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("<td><button value=\"Refresh\" action=\"bypass -h admin_autobots\" width=85 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("<td></td><td></td>");
		sb.append("</tr>");
		sb.append("</table></center><br>");

		// Bot table
		sb.append("<center>");
		sb.append("<table width=360 bgcolor=\"000000\">");
		sb.append("<tr>");
		sb.append("<td width=100 align=center><font color=\"LEVEL\">Name</font></td>");
		sb.append("<td width=40 align=center><font color=\"LEVEL\">Lv</font></td>");
		sb.append("<td width=40 align=center><font color=\"LEVEL\">Class</font></td>");
		sb.append("<td width=50 align=center><font color=\"LEVEL\">Status</font></td>");
		sb.append("<td width=130 align=center><font color=\"LEVEL\">Actions</font></td>");
		sb.append("</tr></table>");

		sb.append("<table width=360>");
		for(AutobotInfo bot : bots)
		{
			boolean online = AutobotsManager.getInstance().isActive(bot.getObjId());
			String statusColor = online ? "00FF00" : "808080";
			String statusText = online ? "ON" : "OFF";

			sb.append("<tr>");
			sb.append("<td width=100 align=center>").append(bot.getName()).append("</td>");
			sb.append("<td width=40 align=center>").append(bot.getLevel()).append("</td>");
			sb.append("<td width=40 align=center>").append(bot.getClassId()).append("</td>");
			sb.append("<td width=50 align=center><font color=\"").append(statusColor).append("\">").append(statusText).append("</font></td>");
			sb.append("<td width=130 align=center>");
			if(!online)
				sb.append("<a action=\"bypass -h admin_autobots_spawn ").append(bot.getName()).append("\">Spawn</a>&nbsp;");
			else
				sb.append("<a action=\"bypass -h admin_autobots_despawn ").append(bot.getName()).append("\">Stop</a>&nbsp;");
			sb.append("<a action=\"bypass -h admin_autobots_info ").append(bot.getName()).append("\">Info</a>&nbsp;");
			sb.append("<a action=\"bypass -h admin_autobots_delete ").append(bot.getName()).append("\">Del</a>");
			sb.append("</td>");
			sb.append("</tr>");
		}
		sb.append("</table></center><br>");

		// Pagination
		sb.append("<center><table width=200><tr>");
		if(page > 0)
			sb.append("<td><button value=\"Prev\" action=\"bypass -h admin_autobots_list ").append(page - 1).append("\" width=60 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		else
			sb.append("<td width=60></td>");
		sb.append("<td align=center>Page ").append(page + 1).append("/").append(totalPages).append("</td>");
		if(page < totalPages - 1)
			sb.append("<td><button value=\"Next\" action=\"bypass -h admin_autobots_list ").append(page + 1).append("\" width=60 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		else
			sb.append("<td width=60></td>");
		sb.append("</tr></table></center>");

		sb.append("</body></html>");

		player.sendPacket(new HtmlMessage(5).setHtml(sb.toString()));
	}

	private void showBotList(Player player, int page)
	{
		showDashboard(player, page);
	}

	private void showBotInfo(Player player, String name)
	{
		AutobotInfo info = AutobotsDAO.getInstance().loadByName(name);
		if(info == null)
		{
			player.sendMessage("Bot '" + name + "' not found.");
			return;
		}

		boolean online = AutobotsManager.getInstance().isActive(info.getObjId());
		CombatPreferences combat = info.getCombatPrefs();
		SocialPreferences social = info.getSocialPrefs();
		ActivityPreferences activity = info.getActivityPrefs();

		String raceName = "Unknown";
		try { raceName = Race.VALUES[info.getRace()].name(); } catch(Exception ignore) {}

		String className = String.valueOf(info.getClassId());
		try { className = ClassId.VALUES[info.getClassId()].name(); } catch(Exception ignore) {}

		String sexName = "Unknown";
		try { sexName = Sex.VALUES[info.getSex()].name(); } catch(Exception ignore) {}

		StringBuilder sb = new StringBuilder();
		sb.append("<html><head><title>Bot Info: ").append(name).append("</title></head><body>");
		sb.append("<center><font color=\"LEVEL\">Bot Details: ").append(name).append("</font></center><br>");

		// General info
		sb.append("<center><table width=300 bgcolor=\"000000\">");
		sb.append("<tr><td width=120>Name:</td><td width=180><font color=\"LEVEL\">").append(info.getName()).append("</font></td></tr>");
		sb.append("<tr><td>Level:</td><td>").append(info.getLevel()).append("</td></tr>");
		sb.append("<tr><td>Class:</td><td>").append(className).append(" (").append(info.getClassId()).append(")</td></tr>");
		sb.append("<tr><td>Race:</td><td>").append(raceName).append("</td></tr>");
		sb.append("<tr><td>Sex:</td><td>").append(sexName).append("</td></tr>");
		sb.append("<tr><td>Position:</td><td>").append(info.getX()).append(", ").append(info.getY()).append(", ").append(info.getZ()).append("</td></tr>");
		sb.append("<tr><td>Status:</td><td><font color=\"").append(online ? "00FF00" : "FF0000").append("\">").append(online ? "ONLINE" : "OFFLINE").append("</font></td></tr>");
		sb.append("</table></center><br>");

		// Combat preferences
		sb.append("<center><font color=\"LEVEL\">Combat Preferences</font></center>");
		sb.append("<center><table width=300 bgcolor=\"000000\">");
		sb.append("<tr><td width=150>Targeting:</td><td>").append(combat.getTargetingPreference()).append("</td></tr>");
		sb.append("<tr><td>Target Range:</td><td>").append(combat.getTargetingRange()).append("</td></tr>");
		sb.append("<tr><td>Attack Players:</td><td>").append(combat.getAttackPlayerType()).append("</td></tr>");
		sb.append("<tr><td>Mana Pots:</td><td>").append(combat.isUseManaPots() ? "Yes" : "No").append("</td></tr>");
		sb.append("<tr><td>Healing Pots:</td><td>").append(combat.isUseHealingPots() ? "Yes" : "No").append("</td></tr>");
		sb.append("<tr><td>CP Pots:</td><td>").append(combat.isUseCpPots() ? "Yes" : "No").append("</td></tr>");
		sb.append("</table></center><br>");

		// Social preferences
		sb.append("<center><font color=\"LEVEL\">Social Preferences</font></center>");
		sb.append("<center><table width=300 bgcolor=\"000000\">");
		sb.append("<tr><td width=150>Town Action:</td><td>").append(social.getTownAction()).append("</td></tr>");
		sb.append("<tr><td>Chat Enabled:</td><td>").append(social.isChatEnabled() ? "Yes" : "No").append("</td></tr>");
		sb.append("</table></center><br>");

		// Activity preferences
		sb.append("<center><font color=\"LEVEL\">Activity Preferences</font></center>");
		sb.append("<center><table width=300 bgcolor=\"000000\">");
		sb.append("<tr><td width=150>Respawn Action:</td><td>").append(activity.getRespawnAction()).append("</td></tr>");
		sb.append("<tr><td>Scheduled:</td><td>").append(activity.isScheduled() ? "Yes" : "No").append("</td></tr>");
		sb.append("</table></center><br>");

		// Action buttons
		sb.append("<center><table width=300><tr>");
		if(!online)
			sb.append("<td><button value=\"Spawn\" action=\"bypass -h admin_autobots_spawn ").append(name).append("\" width=70 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		else
			sb.append("<td><button value=\"Despawn\" action=\"bypass -h admin_autobots_despawn ").append(name).append("\" width=70 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("<td><button value=\"Delete\" action=\"bypass -h admin_autobots_delete ").append(name).append("\" width=70 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("<td><button value=\"Back\" action=\"bypass -h admin_autobots\" width=70 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
		sb.append("</tr></table></center>");

		sb.append("</body></html>");

		player.sendPacket(new HtmlMessage(5).setHtml(sb.toString()));
	}

	private void showOnlineBots(Player player)
	{
		java.util.Collection<Player> activeBots = AutobotsManager.getInstance().getActiveBots();

		StringBuilder sb = new StringBuilder();
		sb.append("<html><head><title>Online Autobots</title></head><body>");
		sb.append("<center><font color=\"LEVEL\">Online Autobots (").append(activeBots.size()).append(")</font></center><br>");

		sb.append("<center><table width=360 bgcolor=\"000000\">");
		sb.append("<tr>");
		sb.append("<td width=120 align=center><font color=\"LEVEL\">Name</font></td>");
		sb.append("<td width=50 align=center><font color=\"LEVEL\">Level</font></td>");
		sb.append("<td width=80 align=center><font color=\"LEVEL\">Location</font></td>");
		sb.append("<td width=110 align=center><font color=\"LEVEL\">Actions</font></td>");
		sb.append("</tr></table>");

		sb.append("<table width=360>");
		for(Player bot : activeBots)
		{
			sb.append("<tr>");
			sb.append("<td width=120 align=center>").append(bot.getName()).append("</td>");
			sb.append("<td width=50 align=center>").append(bot.getLevel()).append("</td>");
			sb.append("<td width=80 align=center>").append(bot.getX()).append(",").append(bot.getY()).append("</td>");
			sb.append("<td width=110 align=center>");
			sb.append("<a action=\"bypass -h admin_autobots_despawn ").append(bot.getName()).append("\">Despawn</a>&nbsp;");
			sb.append("<a action=\"bypass -h admin_autobots_info ").append(bot.getName()).append("\">Info</a>");
			sb.append("</td>");
			sb.append("</tr>");
		}
		sb.append("</table></center><br>");

		sb.append("<center><button value=\"Back\" action=\"bypass -h admin_autobots\" width=70 height=22 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></center>");
		sb.append("</body></html>");

		player.sendPacket(new HtmlMessage(5).setHtml(sb.toString()));
	}

	private void showCreateForm(Player player)
	{
		StringBuilder sb = new StringBuilder();
		sb.append("<html><head><title>Create Autobot</title></head><body>");
		sb.append("<center><font color=\"LEVEL\">Create New Autobot</font></center><br>");

		sb.append("<center><table width=280>");

		// Name
		sb.append("<tr><td width=80>Name:</td><td><edit var=\"bname\" width=150 height=14></td></tr>");

		// Race dropdown (as combobox)
		sb.append("<tr><td>Race:</td><td><combobox var=\"brace\" width=150 list=\"0-HUMAN;1-ELF;2-DARKELF;3-ORC;4-DWARF\"></td></tr>");

		// Sex
		sb.append("<tr><td>Sex:</td><td><combobox var=\"bsex\" width=150 list=\"0-MALE;1-FEMALE\"></td></tr>");

		// Class ID (editable field — too many classes for a dropdown)
		sb.append("<tr><td>Class ID:</td><td><edit var=\"bclass\" width=150 height=14></td></tr>");

		// Level
		sb.append("<tr><td>Level:</td><td><edit var=\"blevel\" width=150 height=14></td></tr>");

		sb.append("</table></center><br>");

		// Class reference table (compact)
		sb.append("<center><font color=\"B09878\">Common class IDs (base classes):</font></center>");
		sb.append("<center><table width=280>");
		sb.append("<tr><td>0</td><td>Human Fighter</td><td>10</td><td>Human Mage</td></tr>");
		sb.append("<tr><td>18</td><td>Elf Fighter</td><td>25</td><td>Elf Mage</td></tr>");
		sb.append("<tr><td>31</td><td>DE Fighter</td><td>38</td><td>DE Mage</td></tr>");
		sb.append("<tr><td>44</td><td>Orc Fighter</td><td>49</td><td>Orc Mage</td></tr>");
		sb.append("<tr><td>53</td><td>Dwarf Fighter</td><td></td><td></td></tr>");
		sb.append("</table></center><br>");

		sb.append("<center>");
		sb.append("<button value=\"Create\" action=\"bypass -h admin_autobots_create $bname $brace $bclass $bsex $blevel\" width=100 height=25 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\">");
		sb.append("&nbsp;");
		sb.append("<button value=\"Back\" action=\"bypass -h admin_autobots\" width=100 height=25 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\">");
		sb.append("</center>");

		sb.append("</body></html>");

		player.sendPacket(new HtmlMessage(5).setHtml(sb.toString()));
	}

	/**
	 * Parses a value that may be in format "0-HUMAN" (from combobox) or just "0".
	 */
	private static int parseIdValue(String val)
	{
		if(val.contains("-"))
			return Integer.parseInt(val.substring(0, val.indexOf('-')));
		return Integer.parseInt(val);
	}

	@Override
	public Enum<?>[] getAdminCommandEnum()
	{
		return Commands.values();
	}
}
