package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.TeamType;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

public class Recall
extends Skill {
    private final int _townId;
    private final boolean _clanhall;
    private final boolean _castle;
    private final boolean _toflag;
    private final Location _loc;

    public Recall(StatsSet set) {
        super(set);
        this._townId = set.getInteger("townId", 0);
        this._clanhall = set.getBool("clanhall", false);
        this._castle = set.getBool("castle", false);
        this._toflag = set.getBool("to_flag", false);
        String cords = set.getString("loc", null);
        this._loc = cords != null ? Location.parseLoc(cords) : null;
    }

    @Override
    public boolean checkCondition(SkillEntry skillEntry, Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        if (!super.checkCondition(skillEntry, activeChar, target, forceUse, dontMove, first, sendMsg, trigger)) {
            return false;
        }
        if (this.getHitTime() == 200) {
            Player player = activeChar.getPlayer();
            if (this._clanhall) {
                if (player.getClan() == null || player.getClan().getHasHideout() == 0) {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                    return false;
                }
            } else if (this._castle && (player.getClan() == null || player.getClan().getCastle() == 0)) {
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                return false;
            }
        }
        if (activeChar.isPlayer()) {
            Player p = (Player)activeChar;
            if (this._toflag && p.bookmarkLocation == null) {
                return false;
            }
            if (p.getActiveWeaponFlagAttachment() != null) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TELEPORT_WHILE_IN_POSSESSION_OF_A_WARD);
                return false;
            }
            if (!p.isInDuel() && p.getTeam() != TeamType.NONE) {
                activeChar.sendMessage(new CustomMessage("common.RecallInDuel"));
                return false;
            }
            if (p.isInOlympiadMode()) {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_USE_THAT_SKILL_IN_A_GRAND_OLYMPIAD_MATCH);
                return false;
            }
            for (Event e : p.getEvents()) {
                if (e.canUseTeleport(p)) continue;
                if (this.getItemConsumeId() > 0) {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                } else {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                }
                return false;
            }
            if (p.isEscapeBlocked()) {
                if (this.getItemConsumeId() > 0) {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                } else {
                    activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
                }
                return false;
            }
        }
        if (activeChar.isInZone(Zone.ZoneType.no_escape) || this._townId > 0 && activeChar.getReflection() != null && activeChar.getReflection().getCoreLoc() != null) {
            if (activeChar.isPlayer()) {
                activeChar.sendMessage(new CustomMessage("l2s.gameserver.skills.skillclasses.Recall.Here"));
            }
            return false;
        }
        return true;
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        if (!target.isPlayer()) {
            return;
        }
        Player player = target.getPlayer();
        if (player == null) {
            return;
        }
        if (!player.getPlayerAccess().UseTeleport) {
            return;
        }
        if (player.isInRange(new Location(-114598, -249431, -2984), 5000)) {
            return;
        }
        if (player.getActiveWeaponFlagAttachment() != null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TELEPORT_WHILE_IN_POSSESSION_OF_A_WARD);
            return;
        }
        if (player.isInOlympiadMode()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_SUMMON_PLAYERS_WHO_ARE_CURRENTLY_PARTICIPATING_IN_THE_GRAND_OLYMPIAD);
            return;
        }
        if (player.isInObserverMode()) {
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
            return;
        }
        for (Event e : player.getEvents()) {
            if (e.canUseTeleport(player)) continue;
            activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_CANNOT_BE_USED_DUE_TO_UNSUITABLE_TERMS).addSkillName(this));
            return;
        }
        if (!player.isInDuel() && player.getTeam() != TeamType.NONE) {
            activeChar.sendMessage(new CustomMessage("common.RecallInDuel"));
            return;
        }
        if (this.isHandler()) {
            if (this.getItemConsumeId() == 7127) {
                player.teleToLocation(105918, 109759, -3207, ReflectionManager.MAIN);
                return;
            }
            if (this.getItemConsumeId() == 7130) {
                player.teleToLocation(85475, 16087, -3672, ReflectionManager.MAIN);
                return;
            }
            if (this.getItemConsumeId() == 7618) {
                player.teleToLocation(149864, -81062, -5618, ReflectionManager.MAIN);
                return;
            }
            if (this.getItemConsumeId() == 7619) {
                player.teleToLocation(108275, -53785, -2524, ReflectionManager.MAIN);
                return;
            }
        }
        if (this._loc != null) {
            player.teleToLocation((ILocation)this._loc, ReflectionManager.MAIN);
            return;
        }
        switch (this._townId) {
            case 1: {
                player.teleToLocation(-83990, 243336, -3700, ReflectionManager.MAIN);
                return;
            }
            case 2: {
                player.teleToLocation(45576, 49412, -2950, ReflectionManager.MAIN);
                return;
            }
            case 3: {
                player.teleToLocation(12501, 16768, -4500, ReflectionManager.MAIN);
                return;
            }
            case 4: {
                player.teleToLocation(-44884, -115063, -80, ReflectionManager.MAIN);
                return;
            }
            case 5: {
                player.teleToLocation(115790, -179146, -890, ReflectionManager.MAIN);
                return;
            }
            case 6: {
                player.teleToLocation(-14279, 124446, -3000, ReflectionManager.MAIN);
                return;
            }
            case 7: {
                player.teleToLocation(-82909, 150357, -3000, ReflectionManager.MAIN);
                return;
            }
            case 8: {
                player.teleToLocation(19025, 145245, -3107, ReflectionManager.MAIN);
                return;
            }
            case 9: {
                player.teleToLocation(82272, 147801, -3350, ReflectionManager.MAIN);
                return;
            }
            case 10: {
                player.teleToLocation(82323, 55466, -1480, ReflectionManager.MAIN);
                return;
            }
            case 11: {
                player.teleToLocation(144526, 24661, -2100, ReflectionManager.MAIN);
                return;
            }
            case 12: {
                player.teleToLocation(117189, 78952, -2210, ReflectionManager.MAIN);
                return;
            }
            case 19: {
                player.teleToLocation(17144, 170156, -3502, ReflectionManager.MAIN);
                return;
            }
        }
        if (this._castle) {
            player.teleToCastle();
            return;
        }
        if (this._clanhall) {
            player.teleToClanhall();
            return;
        }
        if (this._toflag) {
            player.teleToLocation((ILocation)player.bookmarkLocation, ReflectionManager.MAIN);
            player.bookmarkLocation = null;
            return;
        }
        player.teleToClosestTown();
    }
}

