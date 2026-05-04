package l2s.gameserver.model.entity.olympiad;

import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.actor.instances.player.Cubic;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.impl.DuelEvent;
import l2s.gameserver.model.entity.olympiad.CompType;
import l2s.gameserver.model.entity.olympiad.Olympiad;
import l2s.gameserver.model.entity.olympiad.OlympiadDatabase;
import l2s.gameserver.model.entity.olympiad.OlympiadGame;
import l2s.gameserver.model.entity.olympiad.OlympiadParticipiantData;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExOlympiadMatchEndPacket;
import l2s.gameserver.network.l2.s2c.ExOlympiadModePacket;
import l2s.gameserver.network.l2.s2c.RevivePacket;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.templates.InstantZone;
import l2s.gameserver.utils.Log;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class OlympiadMember {
    private static final Logger _log = LoggerFactory.getLogger(OlympiadMember.class);
    private String _name = "";
    private String _clanName = "";
    private int _classId;
    private double _damage;
    private final int _objId;
    private final OlympiadGame _game;
    private final CompType _type;
    private final int _side;
    private Player _player;
    private Location _returnLoc = null;

    public OlympiadMember(int obj_id, OlympiadGame game, int side) {
        String player_name = "";
        Player player = GameObjectsStorage.getPlayer(obj_id);
        if (player != null) {
            player_name = player.getName();
        } else {
            String name = Olympiad.getParticipantName(obj_id);
            if (name != null) {
                player_name = name;
            }
        }
        this._objId = obj_id;
        this._name = player_name;
        this._game = game;
        this._type = game.getType();
        this._side = side;
        this._player = player;
        if (this._player == null) {
            return;
        }
        this._clanName = player.getClan() == null ? "" : player.getClan().getName();
        this._classId = player.getActiveClassId();
        player.setOlympiadSide(side);
        player.setOlympiadGame(game);
    }

    public OlympiadParticipiantData getStat() {
        return Olympiad.getParticipantInfo(this._objId);
    }

    public void incGameCount() {
        OlympiadParticipiantData data = this.getStat();
        switch (this._type) {
            case CLASSED: {
                data.setClassedGamesCount(data.getClassedGamesCount() + 1);
                break;
            }
            case NON_CLASSED: {
                data.setNonClassedGamesCount(data.getNonClassedGamesCount() + 1);
            }
        }
    }

    public void takePointsForCrash() {
        if (!this.checkPlayer()) {
            OlympiadParticipiantData data = this.getStat();
            int points = data.getPoints();
            int diff = Math.min(10, points / this._type.getLooseMult());
            data.setPoints(points - diff);
            Log.add("Olympiad Result: " + this._name + " lost " + diff + " points for crash", "olympiad");
            Player player = this._player;
            if (player == null) {
                Log.add("Olympiad info: " + this._name + " crashed coz player == null", "olympiad");
            } else {
                if (player.isLogoutStarted()) {
                    Log.add("Olympiad info: " + this._name + " crashed coz player.isLogoutStarted()", "olympiad");
                }
                if (!player.isConnected()) {
                    Log.add("Olympiad info: " + this._name + " crashed coz !player.isOnline()", "olympiad");
                }
                if (player.getOlympiadGame() == null) {
                    Log.add("Olympiad info: " + this._name + " crashed coz player.getOlympiadGame() == null", "olympiad");
                }
                if (player.isInArenaObserverMode()) {
                    Log.add("Olympiad info: " + this._name + " crashed coz player.isInArenaObserverMode()", "olympiad");
                }
            }
        }
    }

    public boolean checkPlayer() {
        Player player = this._player;
        return player != null && !player.isLogoutStarted() && player.getOlympiadGame() != null && !player.isInObserverMode();
    }

    public void portPlayerToArena() {
        Player player = this._player;
        if (!this.checkPlayer() || player.isTeleporting()) {
            this._player = null;
            return;
        }
        DuelEvent duel = player.getEvent(DuelEvent.class);
        if (duel != null) {
            duel.abortDuel(player);
        }
        Location location = player.getStablePoint() == null ? (player.getReflection().getReturnLoc() == null ? player.getLoc() : player.getReflection().getReturnLoc()) : (this._returnLoc = player.getStablePoint());
        if (player.isDead()) {
            player.setPendingRevive(true);
        }
        if (player.isSitting()) {
            player.standUp();
        }
        player.setTarget(null);
        player.setIsInOlympiadMode(true);
        player.getInventory().validateItems();
        player.leaveParty(false);
        Reflection ref = this._game.getReflection();
        InstantZone instantZone = ref.getInstancedZone();
        Location tele = Location.findPointToStay(instantZone.getTeleportCoords().get(this._side - 1), 50, 50, ref.getGeoIndex());
        player.setStablePoint(this._returnLoc);
        player.teleToLocation((ILocation)tele, ref);
        player.sendPacket((IBroadcastPacket)new ExOlympiadModePacket(this._side));
    }

    public void portPlayerBack() {
        Player player = this._player;
        if (player == null) {
            return;
        }
        if (this._returnLoc == null) {
            return;
        }
        player.setIsInOlympiadMode(false);
        player.setOlympiadSide(-1);
        player.setOlympiadGame(null);
        for (Abnormal abnormal : player.getAbnormalList()) {
            if (player.isSpecialAbnormal(abnormal.getSkill())) continue;
            abnormal.exit();
        }
        for (Cubic cubic : player.getCubics()) {
            if (player.getSkillLevel(cubic.getSkill().getId()) > 0) continue;
            cubic.delete();
        }
        for (Servitor servitor : player.getServitors()) {
            servitor.getAbnormalList().stopAll();
        }
        player.setCurrentCp(player.getMaxCp());
        player.setCurrentMp(player.getMaxMp());
        if (player.isDead()) {
            player.setCurrentHp(player.getMaxHp(), true);
            player.broadcastPacket(new RevivePacket(player));
        } else {
            player.setCurrentHp(player.getMaxHp(), false);
        }
        if (player.getClan() != null && player.getClan().getReputationScore() >= 0) {
            player.getClan().enableSkills(player);
        }
        player.activateHeroSkills(true);
        player.sendSkillList();
        player.sendPacket((IBroadcastPacket)new ExOlympiadModePacket(0));
        player.sendPacket((IBroadcastPacket)new ExOlympiadMatchEndPacket());
        player.setStablePoint(null);
        player.teleToLocation((ILocation)this._returnLoc, ReflectionManager.MAIN);
    }

    public void preparePlayer1() {
        Player player = this._player;
        if (player == null) {
            return;
        }
        if (player.isInObserverMode()) {
            player.leaveObserverMode();
        }
        if (player.getClan() != null) {
            player.getClan().disableSkills(player);
        }
        player.activateHeroSkills(false);
        if (player.isCastingNow()) {
            player.abortCast(true, true);
        }
        if (player.isAttackingNow()) {
            player.abortAttack(true, true);
        }
        for (Abnormal abnormal : player.getAbnormalList()) {
            if (player.isSpecialAbnormal(abnormal.getSkill())) continue;
            abnormal.exit();
        }
        for (Cubic cubic : player.getCubics()) {
            if (player.getSkillLevel(cubic.getSkill().getId()) > 0) continue;
            cubic.delete();
        }
        for (Servitor servitor : player.getServitors()) {
            if (servitor.isPet()) {
                servitor.unSummon(false);
                continue;
            }
            servitor.getAbnormalList().stopAll();
            servitor.transferOwnerBuffs();
        }
        if (player.getAgathionId() > 0) {
            player.deleteAgathion();
        }
        for (TimeStamp sts : player.getSkillReuses()) {
            Skill skill;
            if (sts == null || (skill = SkillHolder.getInstance().getSkill(sts.getId(), sts.getLevel())) == null || (long)skill.getReuseDelay() > 900000L) continue;
            player.enableSkill(skill);
        }
        player.sendSkillList();
        player.getInventory().validateItems();
        player.removeAutoShots(true);
        player.setCurrentHpMp(player.getMaxHp(), player.getMaxMp());
        player.setCurrentCp(player.getMaxCp());
        player.broadcastUserInfo(true);
    }

    public void preparePlayer2() {
        Player player = this._player;
        if (player == null) {
            return;
        }
        player.setCurrentHpMp(player.getMaxHp(), player.getMaxMp());
        player.setCurrentCp(player.getMaxCp());
        player.broadcastUserInfo(true);
    }

    public void saveParticipantData() {
        OlympiadDatabase.saveParticipantData(this._objId);
    }

    public void logout() {
        this._player = null;
    }

    public Player getPlayer() {
        return this._player;
    }

    public String getName() {
        return this._name;
    }

    public void addDamage(double d) {
        this._damage += d;
    }

    public double getDamage() {
        return this._damage;
    }

    public String getClanName() {
        return this._clanName;
    }

    public int getClassId() {
        return this._classId;
    }

    public int getObjectId() {
        return this._objId;
    }
}

