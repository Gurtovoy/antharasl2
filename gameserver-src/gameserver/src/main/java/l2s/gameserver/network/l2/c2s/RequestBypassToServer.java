package l2s.gameserver.network.l2.c2s;

import java.lang.reflect.Method;
import java.util.StringTokenizer;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.data.xml.holder.MultiSellHolder;
import l2s.gameserver.handler.admincommands.AdminCommandHandler;
import l2s.gameserver.handler.bbs.BbsHandlerHolder;
import l2s.gameserver.handler.bbs.IBbsHandler;
import l2s.gameserver.handler.bypass.BypassHolder;
import l2s.gameserver.handler.voicecommands.IVoicedCommandHandler;
import l2s.gameserver.handler.voicecommands.VoicedCommandHandler;
import l2s.gameserver.instancemanager.OfflineBufferManager;
import l2s.gameserver.instancemanager.OlympiadHistoryManager;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.impl.PvPEvent;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PackageToListPacket;
import l2s.gameserver.utils.BypassStorage;
import l2s.gameserver.utils.MulticlassUtils;
import l2s.gameserver.utils.NpcUtils;
import l2s.gameserver.utils.WarehouseFunctions;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.Pair;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class RequestBypassToServer
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestBypassToServer.class);
    private String _bypass = null;

    @Override
    protected boolean readImpl() {
        this._bypass = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null || this._bypass.isEmpty()) {
            return;
        }
        BypassStorage.ValidBypass bp = activeChar.getBypassStorage().validate(this._bypass);
        if (bp == null) {
            _log.debug("RequestBypassToServer: Unexpected bypass : " + this._bypass + " client : " + this.getClient() + "!");
            return;
        }
        NpcInstance npc = activeChar.getLastNpc();
        try {
            if (bp.bypass.startsWith("admin_")) {
                AdminCommandHandler.getInstance().useAdminCommandHandler(activeChar, bp.bypass);
            } else if (bp.bypass.startsWith("pcbang?")) {
                String command = bp.bypass.substring(7).trim();
                StringTokenizer st = new StringTokenizer(command, "_");
                String cmd = st.nextToken();
                if (cmd.equalsIgnoreCase("multisell")) {
                    int multisellId = Integer.parseInt(st.nextToken());
                    if (!Config.ALT_ALLOWED_MULTISELLS_IN_PCBANG.contains(multisellId)) {
                        _log.warn("Unknown multisell list use in PC-Bang shop! List ID: " + multisellId + ", player ID: " + activeChar.getObjectId() + ", player name: " + activeChar.getName());
                        return;
                    }
                    MultiSellHolder.getInstance().SeparateAndSend(multisellId, activeChar, 0.0);
                }
            } else if (bp.bypass.startsWith("scripts_")) {
                _log.error("Trying to call script bypass: " + bp.bypass + " " + activeChar);
            } else if (bp.bypass.startsWith("htmbypass_")) {
                String command = bp.bypass.substring(10).trim();
                String word = command.split("\\s+")[0];
                String args = command.substring(word.length()).trim();
                Pair<Object, Method> b = BypassHolder.getInstance().getBypass(word);
                if (b != null) {
                    try {
                        ((Method)b.getValue()).invoke(b.getKey(), activeChar, npc, StringUtils.isEmpty((CharSequence)args) ? new String[]{} : args.split("\\s+"));
                    }
                    catch (Exception e) {
                        _log.error("Exception: " + e, (Throwable)e);
                    }
                } else {
                    _log.warn("Cannot find html bypass: " + command);
                }
            } else if (bp.bypass.startsWith("user_")) {
                String command = bp.bypass.substring(5).trim();
                String word = command.split("\\s+")[0];
                String args = command.substring(word.length()).trim();
                IVoicedCommandHandler vch = VoicedCommandHandler.getInstance().getVoicedCommandHandler(word);
                if (vch != null) {
                    vch.useVoicedCommand(word, activeChar, args);
                } else {
                    _log.warn("Unknow voiced command '" + word + "'");
                }
            } else if (bp.bypass.startsWith("npc_")) {
                int endOfId = bp.bypass.indexOf(95, 5);
                if (endOfId > 0) {
                    String id = bp.bypass.substring(4, endOfId);
                } else {
                    String id = bp.bypass.substring(4);
                }
                if (npc != null && npc.canBypassCheck(activeChar)) {
                    String command = bp.bypass.substring(endOfId + 1);
                    npc.onBypassFeedback(activeChar, command);
                }
            } else if (bp.bypass.startsWith("npc?")) {
                if (npc != null && npc.canBypassCheck(activeChar)) {
                    String command = bp.bypass.substring(4).trim();
                    npc.onBypassFeedback(activeChar, command);
                }
            } else if (!bp.bypass.startsWith("item?")) {
                if (bp.bypass.startsWith("class_change?")) {
                    String command = bp.bypass.substring(13).trim();
                    if (command.startsWith("class_name=") && npc != null && npc.canBypassCheck(activeChar)) {
                        int classId = Integer.parseInt(command.substring(11).trim());
                        npc.onChangeClassBypass(activeChar, classId);
                    }
                } else if (bp.bypass.startsWith("quest_accept?")) {
                    String command = bp.bypass.substring(13).trim();
                    if (command.startsWith("quest_id=") && npc != null && npc.canBypassCheck(activeChar)) {
                        int questId = Integer.parseInt(command.substring(9).trim());
                        activeChar.processQuestEvent(questId, "quest_accept", npc);
                    }
                } else if (bp.bypass.startsWith("_olympiad?")) {
                    NpcInstance manager = NpcUtils.canPassPacket(activeChar, this, bp.bypass.split("&")[0]);
                    if (manager != null) {
                        manager.onBypassFeedback(activeChar, bp.bypass);
                    }
                } else if (bp.bypass.equalsIgnoreCase("_heroes")) {
                    NpcInstance manager = NpcUtils.canPassPacket(activeChar, this, bp.bypass);
                    if (manager != null) {
                        manager.onBypassFeedback(activeChar, bp.bypass);
                    }
                } else if (bp.bypass.startsWith("_diary")) {
                    String params = bp.bypass.substring(bp.bypass.indexOf("?") + 1);
                    StringTokenizer st = new StringTokenizer(params, "&");
                    int heroclass = Integer.parseInt(st.nextToken().split("=")[1]);
                    int heropage = Integer.parseInt(st.nextToken().split("=")[1]);
                    int heroid = Hero.getInstance().getHeroByClass(heroclass);
                    if (heroid > 0) {
                        Hero.getInstance().showHeroDiary(activeChar, heroclass, heroid, heropage);
                    }
                } else if (bp.bypass.startsWith("_match")) {
                    String params = bp.bypass.substring(bp.bypass.indexOf("?") + 1);
                    StringTokenizer st = new StringTokenizer(params, "&");
                    int heroclass = Integer.parseInt(st.nextToken().split("=")[1]);
                    int heropage = Integer.parseInt(st.nextToken().split("=")[1]);
                    OlympiadHistoryManager.getInstance().showHistory(activeChar, heroclass, heropage);
                } else if (bp.bypass.startsWith("manor_menu_select?")) {
                    GameObject object = activeChar.getTarget();
                    if (object != null && object.isNpc()) {
                        ((NpcInstance)object).onBypassFeedback(activeChar, bp.bypass);
                    }
                } else if (bp.bypass.startsWith("menu_select?")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        String params = bp.bypass.substring(bp.bypass.indexOf("?") + 1);
                        StringTokenizer st = new StringTokenizer(params, "&");
                        int ask = Integer.parseInt(st.nextToken().split("=")[1].trim());
                        long reply = st.hasMoreTokens() ? Long.parseLong(st.nextToken().split("=")[1].trim()) : 0L;
                        int state = st.hasMoreTokens() ? Integer.parseInt(st.nextToken().split("=")[1].trim()) : 0;
                        npc.onMenuSelect(activeChar, ask, reply, state);
                    }
                } else if (bp.bypass.equals("talk_select")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        npc.showQuestWindow(activeChar);
                    }
                } else if (bp.bypass.equals("teleport_request")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        npc.onTeleportRequest(activeChar);
                    }
                } else if (bp.bypass.equals("learn_skill")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        npc.onSkillLearnBypass(activeChar);
                    }
                } else if (bp.bypass.equals("deposit")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        WarehouseFunctions.showDepositWindow(activeChar);
                    }
                } else if (bp.bypass.equals("withdraw")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        WarehouseFunctions.showRetrieveWindow(activeChar);
                    }
                } else if (bp.bypass.equals("deposit_pledge")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        WarehouseFunctions.showDepositWindowClan(activeChar);
                    }
                } else if (bp.bypass.equals("withdraw_pledge")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        WarehouseFunctions.showWithdrawWindowClan(activeChar);
                    }
                } else if (bp.bypass.equals("package_deposit")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        activeChar.sendPacket((IBroadcastPacket)new PackageToListPacket(activeChar));
                    }
                } else if (bp.bypass.equals("package_withdraw")) {
                    if (npc != null && npc.canBypassCheck(activeChar)) {
                        WarehouseFunctions.showFreightWindow(activeChar);
                    }
                } else if (bp.bypass.startsWith("Quest ")) {
                    _log.warn("Trying to call Quest bypass: " + bp.bypass + ", player: " + activeChar);
                } else if (bp.bypass.startsWith("buffstore?")) {
                    OfflineBufferManager.getInstance().processBypass(activeChar, bp.bypass.substring(10).trim());
                } else if (bp.bypass.startsWith("pvpevent_")) {
                    String[] temp;
                    for (String bypass : temp = bp.bypass.split(";")) {
                        if (bypass.startsWith("pvpevent")) {
                            PvPEvent event;
                            StringTokenizer st = new StringTokenizer(bypass, "_");
                            st.nextToken();
                            String cmd = st.nextToken();
                            int val = Integer.parseInt(st.nextToken());
                            if (cmd.equalsIgnoreCase("showReg")) {
                                event = (PvPEvent)((Object)EventHolder.getInstance().getEvent(EventType.CUSTOM_PVP_EVENT, val));
                                if (event == null || !event.isRegActive()) continue;
                                event.showReg();
                                continue;
                            }
                            if (!cmd.startsWith("reg") || (event = (PvPEvent)((Object)EventHolder.getInstance().getEvent(EventType.CUSTOM_PVP_EVENT, val))) == null || !event.isRegActive()) continue;
                            if (cmd.contains(":")) {
                                event.regCustom(activeChar, cmd);
                                continue;
                            }
                            event.reg(activeChar);
                            continue;
                        }
                        IBbsHandler handler = BbsHandlerHolder.getInstance().getCommunityHandler(bypass);
                        if (handler == null) continue;
                        handler.onBypassCommand(activeChar, bypass);
                    }
                } else if (bp.bypass.startsWith("multiclass?")) {
                    MulticlassUtils.onBypass(activeChar, bp.bypass.substring(11).trim());
                } else if (bp.type == BypassStorage.BypassType.BBS) {
                    if (!Config.BBS_ENABLED) {
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_COMMUNITY_SERVER_IS_CURRENTLY_OFFLINE);
                    } else {
                        IBbsHandler handler = BbsHandlerHolder.getInstance().getCommunityHandler(bp.bypass);
                        if (handler != null) {
                            handler.onBypassCommand(activeChar, bp.bypass);
                        }
                    }
                }
            }
        }
        catch (Exception e) {
            String st = "Error while handling bypass: " + bp.bypass;
            if (npc != null) {
                st = st + " via NPC " + npc;
            }
            _log.error(st, (Throwable)e);
        }
    }
}

