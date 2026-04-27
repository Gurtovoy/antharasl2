/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.skillclasses;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.events.objects.ZoneObject;
import l2s.gameserver.model.instances.residences.SiegeFlagInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.funcs.FuncMul;
import l2s.gameserver.templates.StatsSet;

public class SummonSiegeFlag
extends Skill {
    private final FlagType _flagType;
    private final double _advancedMult;

    public SummonSiegeFlag(StatsSet set) {
        super(set);
        this._flagType = (FlagType)set.getEnum("flagType", FlagType.class);
        this._advancedMult = set.getDouble("advancedMultiplier", 1.0);
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (!activeChar.isPlayer()) {
            return false;
        }
        Player player = (Player)activeChar;
        if (player.getClan() == null || !player.isClanLeader()) {
            return false;
        }
        switch (this._flagType) {
            case DESTROY: {
                break;
            }
            case OUTPOST: 
            case NORMAL: 
            case ADVANCED: {
                if (player.isInZone(Zone.ZoneType.RESIDENCE)) {
                    player.sendPacket(new IBroadcastPacket[]{SystemMsg.YOU_CANNOT_SET_UP_A_BASE_HERE, new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this)});
                    return false;
                }
                ArrayList<SiegeEvent> siegeEvents = new ArrayList<SiegeEvent>();
                block4: for (SiegeEvent siegeEvent : activeChar.getEvents(SiegeEvent.class)) {
                    List<ZoneObject> zones = siegeEvent.getObjects("flag_zones");
                    for (ZoneObject zone : zones) {
                        if (!player.isInZone(zone.getZone())) continue;
                        siegeEvents.add(siegeEvent);
                        continue block4;
                    }
                }
                if (siegeEvents.isEmpty()) {
                    player.sendPacket(new IBroadcastPacket[]{SystemMsg.YOU_CANNOT_SET_UP_A_BASE_HERE, new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this)});
                    return false;
                }
                boolean isAttacker = false;
                boolean haveFlag = false;
                for (SiegeEvent siegeEvent : siegeEvents) {
                    Object siegeClan = siegeEvent.getSiegeClan("attackers", player.getClan());
                    if (siegeClan == null) continue;
                    isAttacker = true;
                    if (((SiegeClanObject)siegeClan).getFlag() == null) continue;
                    haveFlag = true;
                }
                if (!isAttacker) {
                    player.sendPacket(new IBroadcastPacket[]{SystemMsg.YOU_CANNOT_SUMMON_THE_ENCAMPMENT_BECAUSE_YOU_ARE_NOT_A_MEMBER_OF_THE_SIEGE_CLAN_INVOLVED_IN_THE_CASTLE__FORTRESS__HIDEOUT_SIEGE, new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this)});
                    return false;
                }
                if (!haveFlag) break;
                player.sendPacket(new IBroadcastPacket[]{SystemMsg.AN_OUTPOST_OR_HEADQUARTERS_CANNOT_BE_BUILT_BECAUSE_ONE_ALREADY_EXISTS, new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this)});
                return false;
            }
        }
        return true;
    }

    @Override
    public void onEndCast(Creature activeChar, Set<Creature> targets) {
        super.onEndCast(activeChar, targets);
        if (!activeChar.isPlayer()) {
            return;
        }
        Player player = activeChar.getPlayer();
        Clan clan = player.getClan();
        if (clan == null || !player.isClanLeader()) {
            return;
        }
        switch (this._flagType) {
            case DESTROY: {
                block3: for (SiegeEvent siegeEvent : activeChar.getEvents(SiegeEvent.class)) {
                    SiegeClanObject siegeClan = (SiegeClanObject)siegeEvent.getSiegeClan("attackers", clan);
                    if (siegeClan == null) continue;
                    List<ZoneObject> zones = siegeEvent.getObjects("flag_zones");
                    for (ZoneObject zone : zones) {
                        if (!player.isInZone(zone.getZone())) continue;
                    siegeClan.deleteFlag();
                        continue block3;
                    }
                }
                break;
            }
            default: {
                ArrayList<SiegeEvent> siegeEvents = new ArrayList<SiegeEvent>();
                ArrayList<SiegeClanObject> siegeClans = new ArrayList<SiegeClanObject>();
                block5: for (SiegeEvent siegeEvent : activeChar.getEvents(SiegeEvent.class)) {
                    SiegeClanObject s = (SiegeClanObject)siegeEvent.getSiegeClan("attackers", clan);
                    if (s == null || s.getFlag() != null) continue;
                    List<ZoneObject> zones = siegeEvent.getObjects("flag_zones");
                    for (ZoneObject zone : zones) {
                        if (!player.isInZone(zone.getZone())) continue;
                        siegeEvents.add(siegeEvent);
                        siegeClans.add(s);
                        continue block5;
                    }
                }
                if (siegeClans.isEmpty()) {
                    return;
                }
                SiegeFlagInstance flag = (SiegeFlagInstance)NpcHolder.getInstance().getTemplate(this._flagType == FlagType.OUTPOST ? 36590 : 35062).getNewInstance();
                flag.setClan(clan);
                for (SiegeEvent siegeEvent : siegeEvents) {
                    flag.addEvent(siegeEvent);
                }
                if (this._flagType == FlagType.ADVANCED) {
                    flag.getStat().addFuncs(new FuncMul(Stats.MAX_HP, 80, flag, this._advancedMult, StatsSet.EMPTY));
                }
                flag.setCurrentHpMp(flag.getMaxHp(), flag.getMaxMp(), true);
                flag.setHeading(player.getHeading());
                int x = (int)((double)player.getX() + 100.0 * Math.cos(player.headingToRadians(player.getHeading() - 32768)));
                int n = (int)((double)player.getY() + 100.0 * Math.sin(player.headingToRadians(player.getHeading() - 32768)));
                Location loc = GeoEngine.moveCheck(player.getX(), player.getY(), player.getZ(), x, n, player.getGeoIndex());
                if (loc == null) {
                    loc = Location.findAroundPosition(player.getLoc(), 100, player.getGeoIndex());
                }
                flag.spawnMe(loc);
                for (SiegeClanObject siegeClan : siegeClans) {
                    siegeClan.setFlag(flag);
                }
            }
        }
    }

    public static enum FlagType {
        DESTROY,
        NORMAL,
        ADVANCED,
        OUTPOST;

    }
}

