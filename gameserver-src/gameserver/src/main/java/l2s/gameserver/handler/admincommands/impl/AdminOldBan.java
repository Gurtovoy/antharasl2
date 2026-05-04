package l2s.gameserver.handler.admincommands.impl;

import java.util.List;
import java.util.Map;
import java.util.StringTokenizer;
import l2s.gameserver.Announcements;
import l2s.gameserver.Config;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.items.ManufactureItem;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.authcomm.AuthServerCommunication;
import l2s.gameserver.network.authcomm.gs2as.ChangeAccessLevel;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.components.ChatType;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.security.HWIDBan;
import l2s.gameserver.utils.AutoBan;
import l2s.gameserver.utils.Functions;
import l2s.gameserver.utils.Log;

public class AdminOldBan
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        StringTokenizer st = new StringTokenizer(fullString);
        if (activeChar.getPlayerAccess().CanTradeBanUnban) {
            switch (command) {
                case admin_trade_ban: {
                    return this.tradeBan(st, activeChar);
                }
                case admin_trade_unban: {
                    return this.tradeUnban(st, activeChar);
                }
            }
        }
        if (activeChar.getPlayerAccess().CanBan) {
            switch (command) {
                case admin_old_ban: {
                    this.ban(st, activeChar);
                    break;
                }
                case admin_accban: {
                    Player player;
                    st.nextToken();
                    int level = 0;
                    int banExpire = 0;
                    String account = st.nextToken();
                    if (st.hasMoreTokens()) {
                        banExpire = (int)(System.currentTimeMillis() / 1000L) + Integer.parseInt(st.nextToken()) * 60;
                    } else {
                        level = -100;
                    }
                    AuthServerCommunication.getInstance().sendPacket(new ChangeAccessLevel(account, level, banExpire));
                    GameClient client = AuthServerCommunication.getInstance().getAuthedClient(account);
                    if (client == null || (player = client.getActiveChar()) == null) break;
                    player.kick();
                    activeChar.sendMessage("Player " + player.getName() + " kicked.");
                    break;
                }
                case admin_accban_hwid: {
                    Player player;
                    st.nextToken();
                    int level = 0;
                    int banExpire = 0;
                    String account = st.nextToken();
                    if (st.hasMoreTokens()) {
                        banExpire = (int)(System.currentTimeMillis() / 1000L) + Integer.parseInt(st.nextToken()) * 60;
                    } else {
                        level = -100;
                    }
                    AuthServerCommunication.getInstance().sendPacket(new ChangeAccessLevel(account, level, banExpire));
                    GameClient client = AuthServerCommunication.getInstance().getAuthedClient(account);
                    if (client == null || (player = client.getActiveChar()) == null) break;
                    HWIDBan.getInstance().addToBlackList(client.getHWID());
                    player.kick();
                    activeChar.sendMessage(new CustomMessage("common.Admin.Ban.Kicked").addString(player.getName()));
                    break;
                }
                case admin_accunban: {
                    st.nextToken();
                    String account = st.nextToken();
                    AuthServerCommunication.getInstance().sendPacket(new ChangeAccessLevel(account, 0, 0));
                    break;
                }
                case admin_trade_ban: {
                    return this.tradeBan(st, activeChar);
                }
                case admin_trade_unban: {
                    return this.tradeUnban(st, activeChar);
                }
                case admin_chatban: {
                    try {
                        st.nextToken();
                        String player = st.nextToken();
                        String period = st.nextToken();
                        String bmsg = "admin_chatban " + player + " " + period + " ";
                        String msg = fullString.substring(bmsg.length(), fullString.length());
                        if (AutoBan.ChatBan(player, Integer.parseInt(period), msg, activeChar.getName())) {
                            activeChar.sendMessage("You ban chat for " + player + ".");
                            break;
                        }
                        activeChar.sendMessage("Can't find char " + player + ".");
                    }
                    catch (Exception e) {
                        activeChar.sendMessage("Command syntax: //chatban char_name period reason");
                    }
                    break;
                }
                case admin_old_unban: {
                    st.nextToken();
                    String name = st.nextToken();
                    this.unbanChar(activeChar, name);
                    break;
                }
                case admin_chatunban: {
                    try {
                        st.nextToken();
                        String player = st.nextToken();
                        if (AutoBan.ChatUnBan(player, activeChar.getName())) {
                            activeChar.sendMessage("You unban chat for " + player + ".");
                            break;
                        }
                        activeChar.sendMessage("Can't find char " + player + ".");
                    }
                    catch (Exception e) {
                        activeChar.sendMessage("Command syntax: //chatunban char_name");
                    }
                    break;
                }
                case admin_jail: {
                    try {
                        st.nextToken();
                        String player = st.nextToken();
                        String period = st.nextToken();
                        String reason = st.nextToken();
                        Player target = World.getPlayer(player);
                        if (target != null) {
                            target.toJail(Integer.parseInt(period));
                            target.sendMessage("You moved to jail, time to escape - " + period + " minutes, reason - " + reason + " .");
                            activeChar.sendMessage("You jailed " + player + ".");
                            break;
                        }
                        activeChar.sendMessage("Can't find char " + player + ".");
                    }
                    catch (Exception e) {
                        activeChar.sendMessage("Command syntax: //jail char_name period reason");
                    }
                    break;
                }
                case admin_unjail: {
                    try {
                        st.nextToken();
                        String player = st.nextToken();
                        Player target = World.getPlayer(player);
                        if (target.isInJail()) {
                            if (activeChar.fromJail()) {
                                activeChar.sendMessage("You unjailed " + player + ".");
                                break;
                            }
                            activeChar.sendMessage("Cannot unjailed " + player + ".");
                            break;
                        }
                        activeChar.sendMessage("Can't find char " + player + ".");
                    }
                    catch (Exception e) {
                        activeChar.sendMessage("Command syntax: //unjail char_name");
                    }
                    break;
                }
                case admin_cban: {
                    activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/cban.htm"));
                    break;
                }
                case admin_permaban: {
                    if (activeChar.getTarget() == null || !activeChar.getTarget().isPlayer()) {
                        Functions.sendDebugMessage(activeChar, "Target should be set and be a player instance");
                        return false;
                    }
                    Player banned = activeChar.getTarget().getPlayer();
                    String banaccount = banned.getAccountName();
                    AuthServerCommunication.getInstance().sendPacket(new ChangeAccessLevel(banaccount, -100, 0));
                    if (banned.isInOfflineMode()) {
                        banned.setOfflineMode(false);
                    }
                    banned.kick();
                    Functions.sendDebugMessage(activeChar, "Player account " + banaccount + " is banned, player " + banned.getName() + " kicked.");
                }
            }
        }
        return true;
    }

    private boolean tradeBan(StringTokenizer st, Player activeChar) {
        if (activeChar.getTarget() == null || !activeChar.getTarget().isPlayer()) {
            return false;
        }
        st.nextToken();
        Player targ = (Player)activeChar.getTarget();
        long days = -1L;
        long time = -1L;
        if (st.hasMoreTokens()) {
            days = Long.parseLong(st.nextToken());
            time = days * 24L * 60L * 60L * 1000L + System.currentTimeMillis();
        }
        targ.setVar("tradeBan", String.valueOf(time), -1L);
        String msg = activeChar.getName() + " \u0437\u0430\u0431\u043b\u043e\u043a\u0438\u0440\u043e\u0432\u0430\u043b \u0442\u043e\u0440\u0433\u043e\u0432\u043b\u044e \u043f\u0435\u0440\u0441\u043e\u043d\u0430\u0436\u0443 " + targ.getName() + (days == -1L ? " \u043d\u0430 \u0431\u0435\u0441\u0441\u0440\u043e\u0447\u043d\u044b\u0439 \u043f\u0435\u0440\u0438\u043e\u0434." : " \u043d\u0430 " + days + " \u0434\u043d\u0435\u0439.");
        Log.add(targ.getName() + ":" + days + AdminOldBan.tradeToString(targ, targ.getPrivateStoreType()), "tradeBan", activeChar);
        if (targ.isInOfflineMode()) {
            targ.setOfflineMode(false);
            targ.kick();
        } else if (targ.isInStoreMode()) {
            targ.setPrivateStoreType(0);
            targ.storePrivateStore();
            targ.standUp();
            targ.broadcastCharInfo();
            targ.getBuyList().clear();
        }
        if (Config.BANCHAT_ANNOUNCE_FOR_ALL_WORLD) {
            Announcements.announceToAll(msg);
        } else {
            Announcements.shout(activeChar, msg, ChatType.CRITICAL_ANNOUNCE);
        }
        return true;
    }

    private static String tradeToString(Player targ, int trade) {
        switch (trade) {
            case 3: {
                List<TradeItem> buyList = targ.getBuyList();
                if (buyList == null || buyList.isEmpty()) {
                    return "";
                }
                String ret = ":buy:";
                for (TradeItem i : buyList) {
                    ret = ret + i.getItemId() + ";" + i.getCount() + ";" + i.getOwnersPrice() + ":";
                }
                return ret;
            }
            case 1: 
            case 8: {
                Map<Integer, TradeItem> sellList = targ.getSellList();
                if (sellList == null || sellList.isEmpty()) {
                    return "";
                }
                String ret = ":sell:";
                for (TradeItem i : sellList.values()) {
                    ret = ret + i.getItemId() + ";" + i.getCount() + ";" + i.getOwnersPrice() + ":";
                }
                return ret;
            }
            case 5: {
                Map<Integer, ManufactureItem> createList = targ.getCreateList();
                if (createList == null || createList.isEmpty()) {
                    return "";
                }
                String ret = ":mf:";
                for (ManufactureItem i : createList.values()) {
                    ret = ret + i.getRecipeId() + ";" + i.getCost() + ":";
                }
                return ret;
            }
        }
        return "";
    }

    private boolean tradeUnban(StringTokenizer st, Player activeChar) {
        if (activeChar.getTarget() == null || !activeChar.getTarget().isPlayer()) {
            return false;
        }
        Player targ = (Player)activeChar.getTarget();
        targ.unsetVar("tradeBan");
        if (Config.BANCHAT_ANNOUNCE_FOR_ALL_WORLD) {
            Announcements.announceToAll(activeChar + " \u0440\u0430\u0437\u0431\u043b\u043e\u043a\u0438\u0440\u043e\u0432\u0430\u043b \u0442\u043e\u0440\u0433\u043e\u0432\u043b\u044e \u043f\u0435\u0440\u0441\u043e\u043d\u0430\u0436\u0443 " + targ + ".");
        } else {
            Announcements.shout(activeChar, activeChar + " \u0440\u0430\u0437\u0431\u043b\u043e\u043a\u0438\u0440\u043e\u0432\u0430\u043b \u0442\u043e\u0440\u0433\u043e\u0432\u043b\u044e \u043f\u0435\u0440\u0441\u043e\u043d\u0430\u0436\u0443 " + targ + ".", ChatType.CRITICAL_ANNOUNCE);
        }
        Log.add(activeChar + " \u0440\u0430\u0437\u0431\u043b\u043e\u043a\u0438\u0440\u043e\u0432\u0430\u043b \u0442\u043e\u0440\u0433\u043e\u0432\u043b\u044e \u043f\u0435\u0440\u0441\u043e\u043d\u0430\u0436\u0443 " + targ + ".", "tradeBan", activeChar);
        return true;
    }

    private boolean ban(StringTokenizer st, Player activeChar) {
        try {
            Player plyr;
            st.nextToken();
            String player = st.nextToken();
            int time = 0;
            String msg = "";
            if (st.hasMoreTokens()) {
                time = Integer.parseInt(st.nextToken());
            }
            if (st.hasMoreTokens()) {
                msg = "admin_old_ban " + player + " " + time + " ";
                while (st.hasMoreTokens()) {
                    msg = msg + st.nextToken() + " ";
                }
                msg.trim();
            }
            if ((plyr = World.getPlayer(player)) != null) {
                plyr.sendMessage(new CustomMessage("admincommandhandlers.YoureBannedByGM"));
                plyr.setAccessLevel(-100);
                AutoBan.Banned(plyr, time, msg, activeChar.getName());
                plyr.kick();
                activeChar.sendMessage("You banned " + plyr.getName());
            } else if (AutoBan.Banned(player, -100, time, msg, activeChar.getName())) {
                activeChar.sendMessage("You banned " + player);
            } else {
                activeChar.sendMessage("Can't find char: " + player);
            }
        }
        catch (Exception e) {
            activeChar.sendMessage("Command syntax: //ban char_name days reason");
        }
        return true;
    }

    public void unbanChar(Player gm, String name) {
        if (AutoBan.Banned(name, 0, 0, "unbaned cha", gm.getName())) {
            gm.sendMessage("Unbanned player " + name);
        } else {
            gm.sendMessage("Player cannot unbaned " + name);
        }
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    private static enum Commands {
        admin_old_ban,
        admin_old_unban,
        admin_cban,
        admin_chatban,
        admin_chatunban,
        admin_accban,
        admin_accunban,
        admin_accban_hwid,
        admin_accunban_hwid,
        admin_trade_ban,
        admin_trade_unban,
        admin_jail,
        admin_unjail,
        admin_permaban;

    }
}

