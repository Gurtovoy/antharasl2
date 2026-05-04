/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.handler.admincommands.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CharacterVariablesDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.database.mysql;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.CharacterVariable;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.utils.Files;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AdminChangeAccessLevel
implements IAdminCommandHandler {
    private static final Logger _log = LoggerFactory.getLogger(AdminChangeAccessLevel.class);

    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (!activeChar.getPlayerAccess().CanGmEdit) {
            return false;
        }
        switch (command) {
            case admin_changelvl: {
                if (wordList.length == 2) {
                    int lvl = Integer.parseInt(wordList[1]);
                    if (!activeChar.getTarget().isPlayer()) break;
                    ((Player)activeChar.getTarget()).setAccessLevel(lvl);
                    break;
                }
                if (wordList.length != 3) break;
                int lvl = Integer.parseInt(wordList[2]);
                Player player = GameObjectsStorage.getPlayer(wordList[1]);
                if (player == null) break;
                player.setAccessLevel(lvl);
                break;
            }
            case admin_moders: {
                AdminChangeAccessLevel.showModersPannel(activeChar);
                break;
            }
            case admin_moders_add: {
                if (activeChar.getTarget() == null || !activeChar.getTarget().isPlayer()) {
                    activeChar.sendMessage("Incorrect target. Please select a player.");
                    AdminChangeAccessLevel.showModersPannel(activeChar);
                    return false;
                }
                Player modAdd = activeChar.getTarget().getPlayer();
                if (Config.gmlist.containsKey(modAdd.getObjectId())) {
                    activeChar.sendMessage("Error: Moderator " + modAdd.getName() + " already in server access list.");
                    AdminChangeAccessLevel.showModersPannel(activeChar);
                    return false;
                }
                String newFName = "m" + modAdd.getObjectId() + ".xml";
                if (!Files.copyFile("config/GMAccess.d/template/moderator.xml", "config/GMAccess.d/" + newFName)) {
                    activeChar.sendMessage("Error: Failed to copy access-file.");
                    AdminChangeAccessLevel.showModersPannel(activeChar);
                    return false;
                }
                String res = "";
                try {
                    String str;
                    BufferedReader in = new BufferedReader(new FileReader("config/GMAccess.d/" + newFName));
                    while ((str = in.readLine()) != null) {
                        res = res + str + "\n";
                    }
                    in.close();
                    res = res.replaceFirst("ObjIdPlayer", "" + modAdd.getObjectId());
                    Files.writeFile("config/GMAccess.d/" + newFName, res);
                }
                catch (Exception e) {
                    activeChar.sendMessage("Error: Failed to modify object ID in access-file.");
                    File fDel = new File("config/GMAccess.d/" + newFName);
                    if (fDel.exists()) {
                        fDel.delete();
                    }
                    AdminChangeAccessLevel.showModersPannel(activeChar);
                    return false;
                }
                File af = new File("config/GMAccess.d/" + newFName);
                if (!af.exists()) {
                    activeChar.sendMessage("Error: Failed to read access-file for " + modAdd.getName());
                    AdminChangeAccessLevel.showModersPannel(activeChar);
                    return false;
                }
                Config.loadGMAccess(af);
                modAdd.setPlayerAccess(Config.gmlist.get(modAdd.getObjectId()));
                activeChar.sendMessage("Moderator " + modAdd.getName() + " added.");
                AdminChangeAccessLevel.showModersPannel(activeChar);
                break;
            }
            case admin_moders_del: {
                if (wordList.length < 2) {
                    activeChar.sendMessage("Please specify moderator object ID to delete moderator.");
                    AdminChangeAccessLevel.showModersPannel(activeChar);
                    return false;
                }
                int oid = Integer.parseInt(wordList[1]);
                if (!Config.gmlist.containsKey(oid)) {
                    activeChar.sendMessage("Error: Moderator with object ID " + oid + " not found in server access lits.");
                    AdminChangeAccessLevel.showModersPannel(activeChar);
                    return false;
                }
                Config.gmlist.remove(oid);
                Player modDel = GameObjectsStorage.getPlayer(oid);
                if (modDel != null) {
                    modDel.setPlayerAccess(null);
                }
                String fname = "m" + oid + ".xml";
                File f = new File("config/GMAccess.d/" + fname);
                if (!(f.exists() && f.isFile() && f.delete())) {
                    activeChar.sendMessage("Error: Can't delete access-file: " + fname);
                    AdminChangeAccessLevel.showModersPannel(activeChar);
                    return false;
                }
                if (modDel != null) {
                    activeChar.sendMessage("Moderator " + modDel.getName() + " deleted.");
                } else {
                    activeChar.sendMessage("Moderator with object ID " + oid + " deleted.");
                }
                AdminChangeAccessLevel.showModersPannel(activeChar);
                break;
            }
            case admin_penalty: {
                if (wordList.length < 2) {
                    activeChar.sendMessage("USAGE: //penalty charName [count] [reason]");
                    return false;
                }
                int count = 1;
                if (wordList.length > 2) {
                    count = Integer.parseInt(wordList[2]);
                }
                String reason = "\u043d\u0435 \u0443\u043a\u0430\u0437\u0430\u043d\u0430";
                if (wordList.length > 3) {
                    reason = wordList[3];
                }
                int oId = 0;
                Player player = GameObjectsStorage.getPlayer(wordList[1]);
                if (player != null && player.getPlayerAccess().CanBanChat) {
                    oId = player.getObjectId();
                    int oldPenaltyCount = 0;
                    String oldPenalty = player.getVar("penaltyChatCount");
                    if (oldPenalty != null) {
                        oldPenaltyCount = Integer.parseInt(oldPenalty);
                    }
                    player.setVar("penaltyChatCount", "" + (oldPenaltyCount + count), -1L);
                } else {
                    oId = mysql.simple_get_int("obj_Id", "characters", "`char_name`='" + wordList[1] + "'");
                    if (oId > 0) {
                        String val = CharacterVariablesDAO.getInstance().getVarFromPlayer(oId, "penaltyChatCount");
                        int oldCount = 0;
                        if (val != null && !val.isEmpty()) {
                            oldCount = Integer.parseInt(val);
                        }
                        CharacterVariablesDAO.getInstance().insert(oId, new CharacterVariable("penaltyChatCount", String.valueOf(oldCount + count), -1L));
                    }
                }
                if (oId <= 0) break;
                if (Config.BANCHAT_ANNOUNCE_FOR_ALL_WORLD) {
                    Announcements.announceToAll(activeChar + " \u043e\u0448\u0442\u0440\u0430\u0444\u043e\u0432\u0430\u043b \u043c\u043e\u0434\u0435\u0440\u0430\u0442\u043e\u0440\u0430 " + wordList[1] + " \u043d\u0430 " + count + ", \u043f\u0440\u0438\u0447\u0438\u043d\u0430: " + reason + ".");
                    break;
                }
                Announcements.shout(activeChar, activeChar + " \u043e\u0448\u0442\u0440\u0430\u0444\u043e\u0432\u0430\u043b \u043c\u043e\u0434\u0435\u0440\u0430\u0442\u043e\u0440\u0430 " + wordList[1] + " \u043d\u0430 " + count + ", \u043f\u0440\u0438\u0447\u0438\u043d\u0430: " + reason + ".", ChatType.CRITICAL_ANNOUNCE);
            }
        }
        return true;
    }

    private static void showModersPannel(Player activeChar) {
        HtmlMessage reply = new HtmlMessage(5);
        String html = "Moderators managment panel.<br>";
        File dir = new File("config/GMAccess.d/");
        if (!dir.exists() || !dir.isDirectory()) {
            html = html + "Error: Can't open permissions folder.";
            reply.setHtml(html);
            activeChar.sendPacket((IBroadcastPacket)reply);
            return;
        }
        html = html + "<p align=right>";
        html = html + "<button width=120 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\" action=\"bypass -h admin_moders_add\" value=\"Add modrator\">";
        html = html + "</p><br>";
        html = html + "<center><font color=LEVEL>Moderators:</font></center>";
        html = html + "<table width=285>";
        for (File f : dir.listFiles()) {
            if (f.isDirectory() || !f.getName().startsWith("m") || !f.getName().endsWith(".xml")) continue;
            int oid = Integer.parseInt(f.getName().substring(1, 10));
            String pName = AdminChangeAccessLevel.getPlayerNameByObjId(oid);
            boolean on = false;
            if (pName == null || pName.isEmpty()) {
                pName = "" + oid;
            } else {
                on = GameObjectsStorage.getPlayer(pName) != null;
            }
            html = html + "<tr>";
            html = html + "<td width=140>" + pName;
            html = html + (on ? " <font color=\"33CC66\">(on)</font>" : "");
            html = html + "</td>";
            html = html + "<td width=45><button width=50 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\" action=\"bypass -h admin_moders_log " + oid + "\" value=\"Logs\"></td>";
            html = html + "<td width=45><button width=20 height=20 back=\"L2UI_CT1.Button_DF_Down\" fore=\"L2UI_CT1.Button_DF\" action=\"bypass -h admin_moders_del " + oid + "\" value=\"X\"></td>";
            html = html + "</tr>";
        }
        html = html + "</table>";
        reply.setHtml(html);
        activeChar.sendPacket((IBroadcastPacket)reply);
    }

    
    private static String getPlayerNameByObjId(int oid) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        String pName;
        block4: {
            pName = null;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT `char_name` FROM `characters` WHERE `obj_Id`=\"" + oid + "\" LIMIT 1");
                rset = statement.executeQuery();
                if (!rset.next()) break block4;
                pName = rset.getString(1);
            }
            catch (Exception e) {
                try {
                    _log.warn("SQL Error: " + e);
                    _log.error("", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        return pName;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private static enum Commands {
        admin_changelvl,
        admin_moders,
        admin_moders_add,
        admin_moders_del,
        admin_penalty;

    }
}

