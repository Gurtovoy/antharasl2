package l2s.gameserver.handler.admincommands;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.handler.admincommands.impl.AdminAdmin;
import l2s.gameserver.handler.admincommands.impl.AdminAnnouncements;
import l2s.gameserver.handler.admincommands.impl.AdminAttributes;
import l2s.gameserver.handler.admincommands.impl.AdminCamera;
import l2s.gameserver.handler.admincommands.impl.AdminCancel;
import l2s.gameserver.handler.admincommands.impl.AdminChangeAccessLevel;
import l2s.gameserver.handler.admincommands.impl.AdminClanHall;
import l2s.gameserver.handler.admincommands.impl.AdminCreateItem;
import l2s.gameserver.handler.admincommands.impl.AdminDebug;
import l2s.gameserver.handler.admincommands.impl.AdminDelete;
import l2s.gameserver.handler.admincommands.impl.AdminDisconnect;
import l2s.gameserver.handler.admincommands.impl.AdminDoorControl;
import l2s.gameserver.handler.admincommands.impl.AdminEditChar;
import l2s.gameserver.handler.admincommands.impl.AdminEffects;
import l2s.gameserver.handler.admincommands.impl.AdminEnchant;
import l2s.gameserver.handler.admincommands.impl.AdminGeodata;
import l2s.gameserver.handler.admincommands.impl.AdminGiveAll;
import l2s.gameserver.handler.admincommands.impl.AdminGm;
import l2s.gameserver.handler.admincommands.impl.AdminGmChat;
import l2s.gameserver.handler.admincommands.impl.AdminHeal;
import l2s.gameserver.handler.admincommands.impl.AdminHelpPage;
import l2s.gameserver.handler.admincommands.impl.AdminIP;
import l2s.gameserver.handler.admincommands.impl.AdminInstance;
import l2s.gameserver.handler.admincommands.impl.AdminKill;
import l2s.gameserver.handler.admincommands.impl.AdminLevel;
import l2s.gameserver.handler.admincommands.impl.AdminMammon;
import l2s.gameserver.handler.admincommands.impl.AdminMenu;
import l2s.gameserver.handler.admincommands.impl.AdminMonsterRace;
import l2s.gameserver.handler.admincommands.impl.AdminNochannel;
import l2s.gameserver.handler.admincommands.impl.AdminOldBan;
import l2s.gameserver.handler.admincommands.impl.AdminOlympiad;
import l2s.gameserver.handler.admincommands.impl.AdminPForge;
import l2s.gameserver.handler.admincommands.impl.AdminPetition;
import l2s.gameserver.handler.admincommands.impl.AdminPledge;
import l2s.gameserver.handler.admincommands.impl.AdminPolymorph;
import l2s.gameserver.handler.admincommands.impl.AdminQuests;
import l2s.gameserver.handler.admincommands.impl.AdminReload;
import l2s.gameserver.handler.admincommands.impl.AdminRepairChar;
import l2s.gameserver.handler.admincommands.impl.AdminRes;
import l2s.gameserver.handler.admincommands.impl.AdminRide;
import l2s.gameserver.handler.admincommands.impl.AdminScripts;
import l2s.gameserver.handler.admincommands.impl.AdminServer;
import l2s.gameserver.handler.admincommands.impl.AdminShop;
import l2s.gameserver.handler.admincommands.impl.AdminShutdown;
import l2s.gameserver.handler.admincommands.impl.AdminSkill;
import l2s.gameserver.handler.admincommands.impl.AdminSpawn;
import l2s.gameserver.handler.admincommands.impl.AdminTarget;
import l2s.gameserver.handler.admincommands.impl.AdminTeleport;
import l2s.gameserver.handler.admincommands.impl.AdminZone;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.utils.Log;

public class AdminCommandHandler
extends AbstractHolder {
    private static final AdminCommandHandler _instance = new AdminCommandHandler();
    private Map<String, IAdminCommandHandler> _datatable = new HashMap<String, IAdminCommandHandler>();

    public static AdminCommandHandler getInstance() {
        return _instance;
    }

    private AdminCommandHandler() {
        this.registerAdminCommandHandler(new AdminAdmin());
        this.registerAdminCommandHandler(new AdminAnnouncements());
        this.registerAdminCommandHandler(new AdminAttributes());
        this.registerAdminCommandHandler(new AdminOldBan());
        this.registerAdminCommandHandler(new AdminCamera());
        this.registerAdminCommandHandler(new AdminCancel());
        this.registerAdminCommandHandler(new AdminChangeAccessLevel());
        this.registerAdminCommandHandler(new AdminClanHall());
        this.registerAdminCommandHandler(new AdminCreateItem());
        this.registerAdminCommandHandler(new AdminDebug());
        this.registerAdminCommandHandler(new AdminDelete());
        this.registerAdminCommandHandler(new AdminDisconnect());
        this.registerAdminCommandHandler(new AdminDoorControl());
        this.registerAdminCommandHandler(new AdminEditChar());
        this.registerAdminCommandHandler(new AdminEffects());
        this.registerAdminCommandHandler(new AdminEnchant());
        this.registerAdminCommandHandler(new AdminGeodata());
        this.registerAdminCommandHandler(new AdminGiveAll());
        this.registerAdminCommandHandler(new AdminGm());
        this.registerAdminCommandHandler(new AdminGmChat());
        this.registerAdminCommandHandler(new AdminHeal());
        this.registerAdminCommandHandler(new AdminHelpPage());
        this.registerAdminCommandHandler(new AdminInstance());
        this.registerAdminCommandHandler(new AdminIP());
        this.registerAdminCommandHandler(new AdminLevel());
        this.registerAdminCommandHandler(new AdminMammon());
        this.registerAdminCommandHandler(new AdminMenu());
        this.registerAdminCommandHandler(new AdminMonsterRace());
        this.registerAdminCommandHandler(new AdminNochannel());
        this.registerAdminCommandHandler(new AdminOlympiad());
        this.registerAdminCommandHandler(new AdminPetition());
        this.registerAdminCommandHandler(new AdminPForge());
        this.registerAdminCommandHandler(new AdminPledge());
        this.registerAdminCommandHandler(new AdminPolymorph());
        this.registerAdminCommandHandler(new AdminQuests());
        this.registerAdminCommandHandler(new AdminReload());
        this.registerAdminCommandHandler(new AdminRepairChar());
        this.registerAdminCommandHandler(new AdminRes());
        this.registerAdminCommandHandler(new AdminRide());
        this.registerAdminCommandHandler(new AdminServer());
        this.registerAdminCommandHandler(new AdminShop());
        this.registerAdminCommandHandler(new AdminShutdown());
        this.registerAdminCommandHandler(new AdminSkill());
        this.registerAdminCommandHandler(new AdminScripts());
        this.registerAdminCommandHandler(new AdminSpawn());
        this.registerAdminCommandHandler(new AdminTarget());
        this.registerAdminCommandHandler(new AdminTeleport());
        this.registerAdminCommandHandler(new AdminZone());
        this.registerAdminCommandHandler(new AdminKill());
    }

    public void registerAdminCommandHandler(IAdminCommandHandler handler) {
        for (Enum<?> e : handler.getAdminCommandEnum()) {
            this._datatable.put(e.toString().toLowerCase(), handler);
        }
    }

    public IAdminCommandHandler getAdminCommandHandler(String adminCommand) {
        String command = adminCommand;
        if (adminCommand.indexOf(" ") != -1) {
            command = adminCommand.substring(0, adminCommand.indexOf(" "));
        }
        return this._datatable.get(command);
    }

    public void useAdminCommandHandler(Player activeChar, String adminCommand) {
        if (!activeChar.isGM() && !activeChar.getPlayerAccess().CanUseGMCommand) {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.SendBypassBuildCmd.NoCommandOrAccess").addString(adminCommand));
            return;
        }
        String[] wordList = adminCommand.split(" ");
        IAdminCommandHandler handler = this._datatable.get(wordList[0]);
        if (handler != null) {
            try {
                for (Enum<?> e : handler.getAdminCommandEnum()) {
                    if (!e.toString().equalsIgnoreCase(wordList[0])) continue;
                    boolean success = handler.useAdminCommand(e, wordList, adminCommand, activeChar);
                    Log.LogCommand(activeChar, activeChar.getTarget(), adminCommand, success);
                    return;
                }
            }
            catch (Exception e) {
                this.error("", e);
            }
            activeChar.sendMessage("Cannot find handler for command: " + adminCommand);
        }
    }

    public void process() {
    }

    public int size() {
        return this._datatable.size();
    }

    public void clear() {
        this._datatable.clear();
    }

    public Set<String> getAllCommands() {
        return this._datatable.keySet();
    }
}

