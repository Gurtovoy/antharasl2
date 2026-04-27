/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.math.NumberUtils
 */
package l2s.gameserver.handler.admincommands.impl;

import java.util.ArrayList;
import l2s.gameserver.Config;
import l2s.gameserver.handler.admincommands.IAdminCommandHandler;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.network.l2.components.HtmlMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.NpcString;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.EventTriggerPacket;
import l2s.gameserver.network.l2.s2c.ExChangeClientEffectInfo;
import l2s.gameserver.network.l2.s2c.ExSendUIEventPacket;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.utils.Functions;
import org.apache.commons.lang3.math.NumberUtils;

public class AdminAdmin
implements IAdminCommandHandler {
    @Override
    public boolean useAdminCommand(Enum<?> comm, String[] wordList, String fullString, Player activeChar) {
        Commands command = (Commands)comm;
        if (activeChar.getPlayerAccess().Menu) {
            GameObject target = activeChar.getTarget();
            switch (command) {
                case admin_admin: {
                    activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/admin.htm"));
                    break;
                }
                case admin_play_sounds: {
                    if (wordList.length == 1) {
                        activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/songs/songs.htm"));
                        break;
                    }
                    try {
                        activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/songs/songs" + wordList[1] + ".htm"));
                    }
                    catch (StringIndexOutOfBoundsException e) {}
                    break;
                }
                case admin_play_sound: {
                    try {
                        this.playAdminSound(activeChar, wordList[1]);
                    }
                    catch (StringIndexOutOfBoundsException e) {}
                    break;
                }
                case admin_silence: {
                    if (activeChar.getMessageRefusal()) {
                        activeChar.unsetVar("gm_silence");
                        activeChar.setMessageRefusal(false);
                        activeChar.sendPacket((IBroadcastPacket)SystemMsg.MESSAGE_ACCEPTANCE_MODE);
                        activeChar.sendEtcStatusUpdate();
                        break;
                    }
                    if (Config.SAVE_GM_EFFECTS) {
                        activeChar.setVar("gm_silence", "true", -1L);
                    }
                    activeChar.setMessageRefusal(true);
                    activeChar.sendPacket((IBroadcastPacket)SystemMsg.MESSAGE_REFUSAL_MODE);
                    activeChar.sendEtcStatusUpdate();
                    break;
                }
                case admin_tradeoff: {
                    try {
                        if (wordList[1].equalsIgnoreCase("on")) {
                            activeChar.setTradeRefusal(true);
                            Functions.sendDebugMessage(activeChar, "tradeoff enabled");
                            break;
                        }
                        if (!wordList[1].equalsIgnoreCase("off")) break;
                        activeChar.setTradeRefusal(false);
                        Functions.sendDebugMessage(activeChar, "tradeoff disabled");
                    }
                    catch (Exception ex) {
                        if (activeChar.getTradeRefusal()) {
                            Functions.sendDebugMessage(activeChar, "tradeoff currently enabled");
                            break;
                        }
                        Functions.sendDebugMessage(activeChar, "tradeoff currently disabled");
                    }
                    break;
                }
                case admin_show_html: {
                    String html = wordList[1];
                    try {
                        if (html != null) {
                            activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/" + html));
                            break;
                        }
                        Functions.sendDebugMessage(activeChar, "Html page not found");
                    }
                    catch (Exception npe) {
                        Functions.sendDebugMessage(activeChar, "Html page not found");
                    }
                    break;
                }
                case admin_setnpcstate: {
                    int state;
                    if (wordList.length < 2) {
                        Functions.sendDebugMessage(activeChar, "USAGE: //setnpcstate state");
                        return false;
                    }
                    try {
                        state = Integer.parseInt(wordList[1]);
                    }
                    catch (NumberFormatException e) {
                        Functions.sendDebugMessage(activeChar, "You must specify state");
                        return false;
                    }
                    if (!target.isNpc()) {
                        Functions.sendDebugMessage(activeChar, "You must target an NPC");
                        return false;
                    }
                    NpcInstance npc = (NpcInstance)target;
                    npc.setNpcState(state);
                    break;
                }
                case admin_setareanpcstate: {
                    try {
                        String val = fullString.substring(15).trim();
                        String[] vals = val.split(" ");
                        int range = NumberUtils.toInt((String)vals[0], (int)0);
                        int astate = vals.length > 1 ? NumberUtils.toInt((String)vals[1], (int)0) : 0;
                        for (NpcInstance n : activeChar.getAroundNpc(range, 200)) {
                            n.setNpcState(astate);
                        }
                        break;
                    }
                    catch (Exception e) {
                        Functions.sendDebugMessage(activeChar, "Usage: //setareanpcstate [range] [state]");
                        break;
                    }
                }
                case admin_showmovie: {
                    int id;
                    if (wordList.length < 2) {
                        Functions.sendDebugMessage(activeChar, "USAGE: //showmovie id");
                        return false;
                    }
                    try {
                        id = Integer.parseInt(wordList[1]);
                    }
                    catch (NumberFormatException e) {
                        Functions.sendDebugMessage(activeChar, "You must specify id");
                        return false;
                    }
                    activeChar.startScenePlayer(id);
                    break;
                }
                case admin_setzoneinfo: {
                    int stateid;
                    if (wordList.length < 2) {
                        Functions.sendDebugMessage(activeChar, "USAGE: //setzoneinfo id");
                        return false;
                    }
                    try {
                        stateid = Integer.parseInt(wordList[1]);
                    }
                    catch (NumberFormatException e) {
                        Functions.sendDebugMessage(activeChar, "You must specify id");
                        return false;
                    }
                    activeChar.broadcastPacket(new ExChangeClientEffectInfo(stateid));
                    break;
                }
                case admin_et: 
                case admin_eventtrigger: {
                    int triggerid;
                    if (wordList.length < 2) {
                        Functions.sendDebugMessage(activeChar, "USAGE: //eventtrigger id");
                        return false;
                    }
                    try {
                        triggerid = Integer.parseInt(wordList[1]);
                    }
                    catch (NumberFormatException e) {
                        Functions.sendDebugMessage(activeChar, "You must specify id");
                        return false;
                    }
                    activeChar.broadcastPacket(new EventTriggerPacket(triggerid, true));
                    Functions.sendDebugMessage(activeChar, "Event Trigger ID[" + triggerid + "] activated!");
                    break;
                }
                case admin_debug: {
                    if (!target.isPlayer()) {
                        Functions.sendDebugMessage(activeChar, "Only player target is allowed");
                        return false;
                    }
                    Player pl = target.getPlayer();
                    ArrayList<String> _s = new ArrayList<String>();
                    _s.add("==========TARGET STATS:");
                    _s.add("==Magic Resist: " + pl.getStat().calc(Stats.MAGIC_RESIST, null, null));
                    _s.add("==Magic Power: " + pl.getStat().calc(Stats.MAGIC_POWER, 1.0, null, null));
                    _s.add("==P. Skill Power: " + pl.getStat().calc(Stats.P_SKILL_POWER, 1.0, null, null));
                    _s.add("==Cast Break Rate: " + pl.getStat().calc(Stats.CAST_INTERRUPT, 1.0, null, null));
                    _s.add("==========Powers:");
                    _s.add("==Bleed: " + pl.getStat().calc(Stats.ATTACK_TRAIT_BLEED));
                    _s.add("==Poison: " + pl.getStat().calc(Stats.ATTACK_TRAIT_POISON));
                    _s.add("==Stun: " + pl.getStat().calc(Stats.ATTACK_TRAIT_SHOCK));
                    _s.add("==Root: " + pl.getStat().calc(Stats.ATTACK_TRAIT_HOLD));
                    _s.add("==Mental: " + pl.getStat().calc(Stats.ATTACK_TRAIT_DERANGEMENT));
                    _s.add("==Sleep: " + pl.getStat().calc(Stats.ATTACK_TRAIT_SLEEP));
                    _s.add("==Paralyze: " + pl.getStat().calc(Stats.ATTACK_TRAIT_PARALYZE));
                    _s.add("==Cancel: " + pl.getStat().calc(Stats.CANCEL_POWER, 1.0, null, null));
                    _s.add("==Buff: " + pl.getStat().calc(Stats.RESIST_ABNORMAL_BUFF, 1.0, null, null));
                    _s.add("==Debuff: " + pl.getStat().calc(Stats.RESIST_ABNORMAL_DEBUFF, 1.0, null, null));
                    _s.add("==========PvP Stats:");
                    _s.add("==Phys Attack Dmg: " + pl.getStat().calc(Stats.PVP_PHYS_DMG_BONUS, 1.0, null, null));
                    _s.add("==Phys Skill Dmg: " + pl.getStat().calc(Stats.PVP_PHYS_SKILL_DMG_BONUS, 1.0, null, null));
                    _s.add("==Magic Skill Dmg: " + pl.getStat().calc(Stats.PVP_MAGIC_SKILL_DMG_BONUS, 1.0, null, null));
                    _s.add("==Phys Attack Def: " + pl.getStat().calc(Stats.PVP_PHYS_DEFENCE_BONUS, 1.0, null, null));
                    _s.add("==Phys Skill Def: " + pl.getStat().calc(Stats.PVP_PHYS_SKILL_DEFENCE_BONUS, 1.0, null, null));
                    _s.add("==Magic Skill Def: " + pl.getStat().calc(Stats.PVP_MAGIC_SKILL_DEFENCE_BONUS, 1.0, null, null));
                    _s.add("==========Reflects:");
                    _s.add("==Phys Dmg Chance: " + pl.getStat().calc(Stats.REFLECT_AND_BLOCK_DAMAGE_CHANCE, null, null));
                    _s.add("==Phys Skill Dmg Chance: " + pl.getStat().calc(Stats.REFLECT_AND_BLOCK_PSKILL_DAMAGE_CHANCE, null, null));
                    _s.add("==Magic Skill Dmg Chance: " + pl.getStat().calc(Stats.REFLECT_AND_BLOCK_MSKILL_DAMAGE_CHANCE, null, null));
                    _s.add("==Counterattack: Phys Dmg Chance: " + pl.getStat().calc(Stats.REFLECT_DAMAGE_PERCENT, null, null));
                    _s.add("==Counterattack: Phys Skill Dmg Chance: " + pl.getStat().calc(Stats.REFLECT_PSKILL_DAMAGE_PERCENT, null, null));
                    _s.add("==Counterattack: Magic Skill Dmg Chance: " + pl.getStat().calc(Stats.REFLECT_MSKILL_DAMAGE_PERCENT, null, null));
                    _s.add("==========MP Consume Rate:");
                    _s.add("==Magic Skills: " + pl.getStat().calc(Stats.MP_MAGIC_SKILL_CONSUME, 1.0, null, null));
                    _s.add("==Phys Skills: " + pl.getStat().calc(Stats.MP_PHYSICAL_SKILL_CONSUME, 1.0, null, null));
                    _s.add("==Music: " + pl.getStat().calc(Stats.MP_DANCE_SKILL_CONSUME, 1.0, null, null));
                    _s.add("==========Shield:");
                    _s.add("==Shield Defence: " + pl.getStat().calc(Stats.SHIELD_DEFENCE, null, null));
                    _s.add("==Shield Defence Rate: " + pl.getStat().calc(Stats.SHIELD_RATE, null, null));
                    _s.add("==Shield Defence Angle: " + pl.getStat().calc(Stats.SHIELD_ANGLE, null, null));
                    _s.add("==========Etc:");
                    _s.add("==Fatal Blow Rate: " + pl.getStat().calc(Stats.FATALBLOW_RATE, null, null));
                    _s.add("==Phys Skill Evasion Rate: " + (pl.getStat().calc(Stats.P_SKILL_EVASION, 100.0, null, null) - 100.0));
                    _s.add("==Counterattack Rate: " + pl.getStat().calc(Stats.COUNTER_ATTACK, null, null));
                    _s.add("==Pole Attack Angle: " + pl.getStat().calc(Stats.POLE_ATTACK_ANGLE, null, null));
                    _s.add("==Pole Target Count: " + pl.getStat().calc(Stats.POLE_TARGET_COUNT, 1.0, null, null));
                    _s.add("==========DONE.");
                    for (String s : _s) {
                        Functions.sendDebugMessage(activeChar, s);
                    }
                    break;
                }
                case admin_uievent: {
                    String text;
                    int endTime;
                    int startTime;
                    int increase;
                    int hide;
                    if (wordList.length < 5) {
                        Functions.sendDebugMessage(activeChar, "USAGE: //uievent isHide doIncrease startTime endTime Text");
                        return false;
                    }
                    try {
                        hide = Integer.parseInt(wordList[1]);
                        increase = Integer.parseInt(wordList[2]);
                        startTime = Integer.parseInt(wordList[3]);
                        endTime = Integer.parseInt(wordList[4]);
                        int unk1 = Integer.parseInt(wordList[5]);
                        int unk2 = Integer.parseInt(wordList[6]);
                        int unk3 = Integer.parseInt(wordList[7]);
                        int unk4 = Integer.parseInt(wordList[8]);
                        text = wordList[9];
                    }
                    catch (NumberFormatException e) {
                        Functions.sendDebugMessage(activeChar, "Invalid format");
                        return false;
                    }
                    activeChar.broadcastPacket(new ExSendUIEventPacket(activeChar, hide, increase, startTime, endTime, NpcString.NONE, text));
                    break;
                }
                case admin_forcenpcinfo: {
                    if (!target.isNpc()) {
                        Functions.sendDebugMessage(activeChar, "Only NPC target is allowed");
                        return false;
                    }
                    ((NpcInstance)target).broadcastCharInfo();
                    break;
                }
                case admin_undying: {
                    if (activeChar.isGMUndying()) {
                        activeChar.setGMUndying(false);
                        Functions.sendDebugMessage(activeChar, "Undying state has been disabled.");
                        break;
                    }
                    activeChar.setGMUndying(true);
                    Functions.sendDebugMessage(activeChar, "Undying state has been enabled.");
                    break;
                }
                case admin_heading: {
                    if (target == null) {
                        target = activeChar;
                    }
                    activeChar.sendMessage("Target heading: " + target.getHeading());
                    break;
                }
                case admin_distance: {
                    if (target == null || activeChar == target) {
                        activeChar.sendMessage("Target not selected!");
                        break;
                    }
                    activeChar.sendMessage("Target distance: " + activeChar.getDistance(target));
                }
            }
            return true;
        }
        if (activeChar.getPlayerAccess().CanTeleport) {
            switch (command) {
                case admin_show_html: {
                    String html = wordList[1];
                    try {
                        if (html != null) {
                            if (html.startsWith("tele")) {
                                activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/" + html));
                                break;
                            }
                            activeChar.sendMessage("Access denied");
                            break;
                        }
                        activeChar.sendMessage("Html page not found");
                        break;
                    }
                    catch (Exception npe) {
                        activeChar.sendMessage("Html page not found");
                    }
                }
            }
            return true;
        }
        if (activeChar.getPlayerAccess().UseGMShop) {
            GameObject target = activeChar.getTarget();
            if (target == null) {
                target = activeChar;
            }
            if (!target.isPlayer()) {
                Functions.sendDebugMessage(activeChar, "Only player target is allowed");
                return false;
            }
            Player player = target.getPlayer();
            switch (command) {
                case admin_add_premium_points: {
                    try {
                        player.addPremiumPoints(Integer.parseInt(wordList[1]));
                    }
                    catch (Exception npe) {
                        Functions.sendDebugMessage(activeChar, "USAGE: //add_premium_points [COUNT]");
                    }
                    break;
                }
                case admin_reduce_premium_points: {
                    try {
                        player.reducePremiumPoints(Integer.parseInt(wordList[1]));
                        break;
                    }
                    catch (Exception npe) {
                        Functions.sendDebugMessage(activeChar, "USAGE: //reduce_premium_points [COUNT]");
                    }
                }
            }
        }
        return false;
    }

    @Override
    public Enum<?>[] getAdminCommandEnum() {
        return Commands.values();
    }

    public void playAdminSound(Player activeChar, String sound) {
        activeChar.broadcastPacket(new PlaySoundPacket(sound));
        activeChar.sendPacket((IBroadcastPacket)new HtmlMessage(5).setFile("admin/admin.htm"));
        activeChar.sendMessage("Playing " + sound + ".");
    }

    private static enum Commands {
        admin_admin,
        admin_play_sounds,
        admin_play_sound,
        admin_silence,
        admin_tradeoff,
        admin_cfg,
        admin_config,
        admin_show_html,
        admin_setnpcstate,
        admin_setareanpcstate,
        admin_showmovie,
        admin_setzoneinfo,
        admin_et,
        admin_eventtrigger,
        admin_debug,
        admin_uievent,
        admin_forcenpcinfo,
        admin_undying,
        admin_heading,
        admin_distance,
        admin_add_premium_points,
        admin_reduce_premium_points;

    }
}

