/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.admincommands.impl;

import java.util.Collection;
import java.util.HashSet;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SkillCoolTimePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Calculator;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.utils.HtmlUtils;
import l2s.gameserver.utils.Log;

public class AdminSkill
implements IAdminCommandHandler {
    private static SkillEntry[] adminSkills;

    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().CanEditChar) {
            return false;
        }
        switch (command) {
            case admin_show_skills: {
                this.showSkillsPage(activeChar);
                break;
            }
            case admin_show_effects: {
                this.showEffects(activeChar);
                break;
            }
            case admin_remove_skills: {
                this.removeSkillsPage(activeChar);
                break;
            }
            case admin_remove_all_skills: {
                this.removeAllSkills(activeChar);
                break;
            }
            case admin_skill_list: {
                activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/skills.htm"));
                break;
            }
            case admin_skill_index: {
                if (wordList.length <= 1) break;
                activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/skills/" + wordList[1] + ".htm"));
                break;
            }
            case admin_add_skill: {
                this.adminAddSkill(activeChar, wordList);
                break;
            }
            case admin_remove_skill: {
                this.adminRemoveSkill(activeChar, wordList);
                break;
            }
            case admin_get_skills: {
                this.adminGetSkills(activeChar);
                break;
            }
            case admin_reset_skills: {
                this.adminResetSkills(activeChar);
                break;
            }
            case admin_give_all_skills: {
                this.adminGiveAllSkills(activeChar);
                break;
            }
            case admin_debug_stats: {
                this.debug_stats(activeChar);
                break;
            }
            case admin_remove_cooldown: {
                GameObject target = activeChar.getTarget();
                Player player = null;
                if (target == null || !target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
                    return false;
                }
                player = (Player)target;
                player.resetReuse();
                player.sendPacket((IBroadcastPacket)new SkillCoolTimePacket(activeChar));
                player.sendMessage("The reuse delay of all skills has been reseted.");
                this.showSkillsPage(activeChar);
                break;
            }
            case admin_buff: {
                for (int i = 7041; i <= 7064; ++i) {
                    activeChar.addSkill(SkillEntry.makeSkillEntry(SkillEntryType.NONE, i, 1));
                }
                activeChar.sendSkillList();
                break;
            }
            case admin_use_skill: 
            case admin_callskill: {
                this.adminCallSkill(activeChar, wordList);
            }
        }
        return true;
    }

    private void debug_stats(Player activeChar) {
        GameObject target_obj = activeChar.getTarget();
        if (!target_obj.isCreature()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        Creature target = (Creature)target_obj;
        Calculator[] calculators = target.getStat().getCalculators();
        String log_str = "--- Debug for " + target.getName() + " ---\r\n";
        for (Calculator calculator : calculators) {
            if (calculator == null) continue;
            Env env = new Env(target, activeChar, null);
            env.value = calculator.getBase();
            log_str = log_str + "Stat: " + calculator._stat.getValue() + ", prevValue: " + calculator.getLast() + "\r\n";
            Func[] funcs = calculator.getFunctions();
            for (int i = 0; i < funcs.length; ++i) {
                String order = Integer.toHexString(funcs[i].order).toUpperCase();
                if (order.length() == 1) {
                    order = "0" + order;
                }
                log_str = log_str + "\tFunc #" + i + "@ [0x" + order + "]" + funcs[i].getClass().getSimpleName() + "\t" + env.value;
                if (funcs[i].getCondition() == null || funcs[i].getCondition().test(env)) {
                    funcs[i].calc(env, null);
                }
                log_str = log_str + " -> " + env.value + (funcs[i].owner != null ? "; owner: " + funcs[i].owner.toString() : "; no owner") + "\r\n";
            }
        }
        Log.add(log_str, "debug_stats");
    }

    private void adminGiveAllSkills(Player activeChar) {
        GameObject target = activeChar.getTarget();
        Player player = null;
        if (target == null || !target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        player = (Player)target;
        int skillCounter = player.rewardSkills(true, true, true, false);
        player.sendMessage("Admin gave you " + skillCounter + " skills.");
        activeChar.sendMessage("You gave " + skillCounter + " skills to " + player.getName());
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private void removeSkillsPage(Player activeChar) {
        GameObject target = activeChar.getTarget();
        if (!target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        Player player = (Player)target;
        Collection<SkillEntry> skills = player.getAllSkills();
        HtmlMessage adminReply = new HtmlMessage(5);
        StringBuilder replyMSG = new StringBuilder("<html><body>");
        replyMSG.append("<table width=260><tr>");
        replyMSG.append("<td width=40><button value=\"Main\" action=\"bypass -h admin_admin\" width=40 height=15 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=180><center>Character Selection Menu</center></td>");
        replyMSG.append("<td width=40><button value=\"Back\" action=\"bypass -h admin_show_skills\" width=40 height=15 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("</tr></table>");
        replyMSG.append("<br><br>");
        replyMSG.append("<center>Editing character: " + player.getName());
        replyMSG.append("<br>Level: " + player.getLevel() + " " + HtmlUtils.htmlClassName(player.getClassId().getId()) + "</center>");
        replyMSG.append("<br><center>Click on the skill you wish to remove:</center>");
        replyMSG.append("<br><table width=270>");
        replyMSG.append("<tr><td width=80>Name:</td><td width=60>Level:</td><td width=40>Id:</td></tr>");
        for (SkillEntry element : skills) {
            replyMSG.append("<tr><td width=80><a action=\"bypass -h admin_remove_skill " + element.getId() + "\">" + element.getName(activeChar) + "</a></td><td width=60>" + element.getLevel() + "</td><td width=40>" + element.getId() + "</td></tr>");
        }
        replyMSG.append("</table>");
        replyMSG.append("<br><center><table>");
        replyMSG.append("Remove custom skill:");
        replyMSG.append("<tr><td>Id: </td>");
        replyMSG.append("<td><edit var=\"id_to_remove\" width=110></td></tr>");
        replyMSG.append("</table></center>");
        replyMSG.append("<center><button value=\"Remove skill\" action=\"bypass -h admin_remove_skill $id_to_remove\" width=110 height=15 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></center>");
        replyMSG.append("<br><center><button value=\"Back\" action=\"bypass -h admin_current_player\" width=40 height=15></center>");
        replyMSG.append("</body></html>");
        adminReply.setHtml(replyMSG.toString());
        activeChar.sendPacket((IBroadcastPacket)adminReply);
    }

    private void removeAllSkills(Player activeChar) {
        GameObject target = activeChar.getTarget();
        if (!target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        Player player = (Player)target;
        Collection<SkillEntry> skills = player.getAllSkills();
        for (SkillEntry skillEntry : skills) {
            if (skillEntry == null) continue;
            player.removeSkill(skillEntry, true);
        }
        player.sendUserInfo();
        player.updateStats();
        player.sendSkillList();
        activeChar.sendMessage("You removed all skills from target: " + player.getName() + ".");
        this.showSkillsPage(activeChar);
    }

    private void showSkillsPage(Player activeChar) {
        GameObject target = activeChar.getTarget();
        if (target == null || !target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        Player player = (Player)target;
        HtmlMessage adminReply = new HtmlMessage(5);
        StringBuilder replyMSG = new StringBuilder("<html><body>");
        replyMSG.append("<table width=260><tr>");
        replyMSG.append("<td width=40><button value=\"Main\" action=\"bypass -h admin_admin\" width=40 height=15 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=180><center>Character Selection Menu</center></td>");
        replyMSG.append("<td width=40><button value=\"Back\" action=\"bypass -h admin_current_player\" width=40 height=15 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("</tr></table>");
        replyMSG.append("<br><br>");
        replyMSG.append("<center>Editing character: " + player.getName());
        replyMSG.append("<br>Level: " + player.getLevel() + " " + HtmlUtils.htmlClassName(player.getClassId().getId()) + "</center>");
        replyMSG.append("<br><center><table>");
        replyMSG.append("<tr><td><button value=\"Add skills\" action=\"bypass -h admin_skill_list\" width=100 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td><button value=\"Get skills\" action=\"bypass -h admin_get_skills\" width=100 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td></tr>");
        replyMSG.append("<tr><td><button value=\"Delete skills\" action=\"bypass -h admin_remove_skills\" width=100 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td><button value=\"Delete all skills\" action=\"bypass -h admin_remove_all_skills\" width=100 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td></tr>");
        replyMSG.append("<tr><td><button value=\"Reset skills\" action=\"bypass -h admin_reset_skills\" width=100 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td><button value=\"Reset reuse\" action=\"bypass -h admin_remove_cooldown\" width=100 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td></tr>");
        replyMSG.append("<tr><td><button value=\"Give All Skills\" action=\"bypass -h admin_give_all_skills\" width=100 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td></tr>");
        replyMSG.append("</table></center>");
        replyMSG.append("</body></html>");
        adminReply.setHtml(replyMSG.toString());
        activeChar.sendPacket((IBroadcastPacket)adminReply);
    }

    private void showEffects(Player activeChar) {
        GameObject target = activeChar.getTarget();
        if (target == null || !target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        Player player = (Player)target;
        HtmlMessage adminReply = new HtmlMessage(5);
        StringBuilder replyMSG = new StringBuilder("<html><body>");
        replyMSG.append("<table width=260><tr>");
        replyMSG.append("<td width=40><button value=\"Main\" action=\"bypass -h admin_admin\" width=40 height=15 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("<td width=180><center>Character Selection Menu</center></td>");
        replyMSG.append("<td width=40><button value=\"Back\" action=\"bypass -h admin_current_player\" width=40 height=15 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\"></td>");
        replyMSG.append("</tr></table>");
        replyMSG.append("<br><br>");
        replyMSG.append("<center>Editing character: " + player.getName() + "</center>");
        replyMSG.append("<br><center><button value=\"");
        replyMSG.append(player.isLangRus() ? "\u041e\u0431\u043d\u043e\u0432\u0438\u0442\u044c" : "Refresh");
        replyMSG.append("\" action=\"bypass -h admin_show_effects\" width=100 height=15 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\" /></center>");
        replyMSG.append("<br>");
        for (Abnormal e : player.getAbnormalList()) {
            replyMSG.append(e.getSkill().getName(activeChar)).append(" ").append(e.getSkill().getLevel()).append(" - ").append(e.getSkill().isToggle() ? "Infinity" : e.getTimeLeft() + " seconds").append("<br1>");
        }
        replyMSG.append("<br></body></html>");
        adminReply.setHtml(replyMSG.toString());
        activeChar.sendPacket((IBroadcastPacket)adminReply);
    }

    private void adminGetSkills(Player activeChar) {
        GameObject target = activeChar.getTarget();
        if (!target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        Player player = (Player)target;
        if (player.getName().equals(activeChar.getName())) {
            player.sendMessage("There is no point in doing it on your character.");
        } else {
            Collection<SkillEntry> skills = player.getAllSkills();
            adminSkills = activeChar.getAllSkillsArray();
            for (SkillEntry element : adminSkills) {
                activeChar.removeSkill(element, true);
            }
            for (SkillEntry element : skills) {
                activeChar.addSkill(element, true);
            }
            activeChar.sendUserInfo();
            activeChar.updateStats();
            activeChar.sendSkillList();
            activeChar.sendMessage("You now have all the skills of  " + player.getName() + ".");
        }
        this.showSkillsPage(activeChar);
    }

    private void adminResetSkills(Player activeChar) {
        GameObject target = activeChar.getTarget();
        Player player = null;
        if (!target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        player = (Player)target;
        int counter = 0;
        player.checkSkills();
        player.sendUserInfo();
        player.updateStats();
        player.sendSkillList();
        player.sendMessage("[GM]" + activeChar.getName() + " has updated your skills.");
        activeChar.sendMessage(counter + " skills removed.");
        this.showSkillsPage(activeChar);
    }

    private void adminAddSkill(Player activeChar, String[] wordList) {
        GameObject target = activeChar.getTarget();
        if (target == null || !target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        Player player = (Player)target;
        if (wordList.length >= 2) {
            SkillEntry skillEntry;
            int id = Integer.parseInt(wordList[1]);
            int level = 1;
            if (wordList.length >= 3) {
                level = Integer.parseInt(wordList[2]);
            }
            if ((skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, id, level)) != null) {
                player.addSkill(skillEntry, true);
                player.sendUserInfo();
                player.updateStats();
                player.sendSkillList();
                player.getPlayer().sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_EARNED_S1_SKILL).addSkillName(skillEntry.getId(), skillEntry.getLevel()));
                activeChar.sendMessage("You gave the skill " + skillEntry.getName(activeChar) + " to " + player.getName() + ".");
            } else {
                activeChar.sendMessage("Error: there is no such skill.");
            }
        }
        this.showSkillsPage(activeChar);
    }

    private void adminRemoveSkill(Player activeChar, String[] wordList) {
        GameObject target = activeChar.getTarget();
        Player player = null;
        if (!target.isPlayer() || activeChar != target && !activeChar.getPlayerAccess().CanEditCharAll) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
            return;
        }
        player = (Player)target;
        if (wordList.length == 2) {
            int level;
            int id = Integer.parseInt(wordList[1]);
            SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, id, level = player.getSkillLevel(id));
            if (skillEntry != null) {
                player.sendMessage("Admin removed the skill " + skillEntry.getName(player) + ".");
                player.removeSkill(skillEntry, true);
                player.sendUserInfo();
                player.updateStats();
                player.sendSkillList();
                activeChar.sendMessage("You removed the skill " + skillEntry.getName(activeChar) + " from " + player.getName() + ".");
            } else {
                activeChar.sendMessage("Error: there is no such skill.");
            }
        }
        this.removeSkillsPage(activeChar);
    }

    private void adminCallSkill(Player player, String[] wordList) {
        GameObject target = player.getTarget();
        if (target == null) {
            target = player;
        }
        if (!target.isPlayer()) {
            return;
        }
        Skill skill = SkillHolder.getInstance().getSkill(Integer.parseInt(wordList[1]), Integer.parseInt(wordList[2]));
        if (skill == null) {
            return;
        }
        HashSet<Creature> targets = new HashSet<Creature>();
        targets.add(target.getPlayer());
        player.callSkill(target.getPlayer(), SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill), targets, false, false);
    }

    private static enum Commands {
        admin_show_skills,
        admin_remove_skills,
        admin_remove_all_skills,
        admin_skill_list,
        admin_skill_index,
        admin_add_skill,
        admin_remove_skill,
        admin_get_skills,
        admin_reset_skills,
        admin_give_all_skills,
        admin_show_effects,
        admin_debug_stats,
        admin_remove_cooldown,
        admin_buff,
        admin_callskill,
        admin_use_skill;

    }
}

