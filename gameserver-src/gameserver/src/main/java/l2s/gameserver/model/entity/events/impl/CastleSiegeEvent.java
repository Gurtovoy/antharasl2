/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 *  l2s.commons.dao.JdbcEntityState
 *  org.napile.primitive.sets.IntSet
 *  org.napile.primitive.sets.impl.HashIntSet
 */
package l2s.gameserver.model.entity.events.impl;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.List;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.dao.JdbcEntityState;
import l2s.gameserver.Config;
import l2s.gameserver.dao.CastleDamageZoneDAO;
import l2s.gameserver.dao.CastleDoorUpgradeDAO;
import l2s.gameserver.dao.CastleHiredGuardDAO;
import l2s.gameserver.dao.SiegeClanDAO;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.actor.OnKillListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.entity.Hero;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;
import l2s.gameserver.model.entity.events.objects.DoorObject;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.events.objects.SiegeToggleNpcObject;
import l2s.gameserver.model.entity.events.objects.SpawnExObject;
import l2s.gameserver.model.entity.events.objects.SpawnSimpleObject;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceSide;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.residences.SiegeToggleNpcInstance;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.PlaySoundPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.templates.item.support.MerchantGuard;
import org.napile.primitive.sets.IntSet;
import org.napile.primitive.sets.impl.HashIntSet;

public class CastleSiegeEvent
extends SiegeEvent<Castle, SiegeClanObject> {
    public static final int MAX_SIEGE_CLANS = Config.MAX_SIEGE_CLANS;
    public static final int BASE_SIEGE_FAME = 72;
    public static final String DEFENDERS_WAITING = "defenders_waiting";
    public static final String DEFENDERS_REFUSED = "defenders_refused";
    public static final String CONTROL_TOWERS = "control_towers";
    public static final String FLAME_TOWERS = "flame_towers";
    public static final String BOUGHT_ZONES = "bought_zones";
    public static final String GUARDS = "guards";
    public static final String HIRED_GUARDS = "hired_guards";
    private static final String LIGHT_SIDE = "light_side";
    private static final String DARK_SIDE = "dark_side";
    private boolean _firstStep = false;
    private final IntSet _visitedParticipants = new HashIntSet();

    public CastleSiegeEvent(MultiValueSet<String> set) {
        super(set);
        this._killListener = new KillListener();
    }

    @Override
    public void initEvent() {
        super.initEvent();
        List<DoorObject> doorObjects = this.getObjects("doors");
        this.addObjects(BOUGHT_ZONES, CastleDamageZoneDAO.getInstance().load((Residence)this.getResidence()));
        for (DoorObject doorObject : doorObjects) {
            doorObject.setUpgradeValue(this, CastleDoorUpgradeDAO.getInstance().load(doorObject.getId()));
            doorObject.getDoor().addListener(this._doorDeathListener);
        }
    }

    public void takeCastle(Clan newOwnerClan, ResidenceSide side) {
        ((Castle)this.getResidence()).setResidenceSide(side, false);
        ((Castle)this.getResidence()).broadcastResidenceState();
        this.processStep(newOwnerClan);
    }

    @Override
    public void processStep(Clan newOwnerClan) {
        Clan oldOwnerClan = ((Castle)this.getResidence()).getOwner();
        ((Castle)this.getResidence()).changeOwner(newOwnerClan);
        if (oldOwnerClan != null) {
            SiegeClanObject ownerSiegeClan = this.getSiegeClan("defenders", oldOwnerClan);
            if (ownerSiegeClan != null) {
                this.removeObject("defenders", ownerSiegeClan);
                ownerSiegeClan.setType("attackers");
                this.addObject("attackers", ownerSiegeClan);
            }
        } else {
            if (this.getObjects("attackers").size() == 1) {
                this.stopEvent(false);
                return;
            }
            int allianceObjectId = newOwnerClan.getAllyId();
            if (allianceObjectId > 0) {
                List<SiegeClanObject> attackers = this.getObjects("attackers");
                boolean sameAlliance = true;
                for (SiegeClanObject sc : attackers) {
                    if (sc == null || sc.getClan().getAllyId() == allianceObjectId) continue;
                    sameAlliance = false;
                }
                if (sameAlliance) {
                    this.stopEvent(false);
                    return;
                }
            }
        }
        SiegeClanObject newOwnerSiegeClan = this.getSiegeClan("attackers", newOwnerClan);
        newOwnerSiegeClan.deleteFlag();
        newOwnerSiegeClan.setType("defenders");
        this.removeObject("attackers", newOwnerSiegeClan);
        List<SiegeClanObject> defenders = this.removeObjects("defenders");
        for (SiegeClanObject siegeClan : defenders) {
            siegeClan.setType("attackers");
        }
        this.addObject("defenders", newOwnerSiegeClan);
        this.addObjects("attackers", defenders);
        for (CastleSiegeEvent castleSiege : EventHolder.getInstance().getEvents(CastleSiegeEvent.class)) {
            if (castleSiege == this) continue;
            SiegeClanObject siegeClan = castleSiege.getSiegeClan("attackers", newOwnerClan);
            if (siegeClan != null) {
                siegeClan.deleteFlag();
                castleSiege.removeObject("attackers", siegeClan);
                for (Player player : newOwnerClan.getOnlineMembers()) {
                    player.removeEvent(castleSiege);
                    player.broadcastCharInfo();
                }
            }
            if ((siegeClan = castleSiege.getSiegeClan("defenders", newOwnerClan)) == null) continue;
            siegeClan.deleteFlag();
            castleSiege.removeObject("defenders", siegeClan);
            for (Player player : newOwnerClan.getOnlineMembers()) {
                player.removeEvent(castleSiege);
                player.broadcastCharInfo();
            }
        }
        this.updateParticles(true, "attackers", "defenders");
        this.teleportPlayers("from_residence_to_town");
        if (!this._firstStep) {
            this._firstStep = true;
            this.broadcastTo(SystemMsg.THE_TEMPORARY_ALLIANCE_OF_THE_CASTLE_ATTACKER_TEAM_HAS_BEEN_DISSOLVED, "attackers", "defenders");
            if (this._oldOwner != null) {
                if (this.containsObjects(HIRED_GUARDS)) {
                    this.spawnAction(HIRED_GUARDS, false);
                    this.removeObjects(HIRED_GUARDS);
                }
                this.damageZoneAction(false);
                this.removeObjects(BOUGHT_ZONES);
                CastleDamageZoneDAO.getInstance().delete((Residence)this.getResidence());
            } else {
                this.spawnAction(GUARDS, false);
            }
            List<DoorObject> doorObjects = this.getObjects("doors");
            for (DoorObject doorObject : doorObjects) {
                doorObject.setWeak(true);
                doorObject.setUpgradeValue(this, 0);
                CastleDoorUpgradeDAO.getInstance().delete(doorObject.getId());
            }
        }
        this.spawnAction("doors", true);
        this.despawnSiegeSummons();
    }

    @Override
    public void startEvent() {
        List<SiegeClanObject> attackers = this.getObjects("attackers");
        if (attackers.isEmpty()) {
            if (((Castle)this.getResidence()).getOwner() == null) {
                this.broadcastToWorld((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_HAS_BEEN_CANCELED_DUE_TO_LACK_OF_INTEREST).addResidenceName((Residence)this.getResidence()));
            } else {
                this.broadcastToWorld((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1S_SIEGE_WAS_CANCELED_BECAUSE_THERE_WERE_NO_CLANS_THAT_PARTICIPATED).addResidenceName((Residence)this.getResidence()));
                ((Castle)this.getResidence()).getOwner().setCastleDefendCount(((Castle)this.getResidence()).getOwner().getCastleDefendCount() + 1);
                ((Castle)this.getResidence()).getOwner().updateClanInDB();
            }
            ((Castle)this.getResidence()).getOwnDate().setTimeInMillis(((Castle)this.getResidence()).getOwner() == null ? 0L : System.currentTimeMillis());
            this.reCalcNextTime(false);
            return;
        }
        this._oldOwner = ((Castle)this.getResidence()).getOwner();
        if (this._oldOwner != null) {
            this.addObject("defenders", new SiegeClanObject("defenders", this._oldOwner, 0L));
            if (((Castle)this.getResidence()).getSpawnMerchantTickets().size() > 0) {
                for (ItemInstance item : ((Castle)this.getResidence()).getSpawnMerchantTickets()) {
                    MerchantGuard guard = ((Castle)this.getResidence()).getMerchantGuard(item.getItemId());
                    this.addObject(HIRED_GUARDS, new SpawnSimpleObject(guard.getNpcId(), item.getLoc()));
                    item.deleteMe();
                }
                CastleHiredGuardDAO.getInstance().delete((Residence)this.getResidence());
                if (this.containsObjects(HIRED_GUARDS)) {
                    this.spawnAction(HIRED_GUARDS, true);
                }
            }
        }
        SiegeClanDAO.getInstance().delete((Residence)this.getResidence());
        this.updateParticles(true, "attackers", "defenders");
        this.broadcastTo(SystemMsg.THE_TEMPORARY_ALLIANCE_OF_THE_CASTLE_ATTACKER_TEAM_IS_IN_EFFECT, "attackers");
        this.broadcastTo((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_ARE_PARTICIPATING_IN_THE_SIEGE_OF_S1_THIS_SIEGE_IS_SCHEDULED_FOR_2_HOURS).addResidenceName((Residence)this.getResidence()), "attackers", "defenders");
        super.startEvent();
        if (this._oldOwner == null) {
            this.initControlTowers();
        } else {
            this.damageZoneAction(true);
        }
    }

    @Override
    public void stopEvent(boolean force) {
        Player player;
        List<DoorObject> doorObjects = this.getObjects("doors");
        for (DoorObject doorObject : doorObjects) {
            doorObject.setWeak(false);
        }
        for (int objectId : this._visitedParticipants.toArray()) {
            player = GameObjectsStorage.getPlayer((int)objectId);
            if (player == null) continue;
            player.getListeners().onParticipateInCastleSiege(this);
        }
        this.damageZoneAction(false);
        this._blockedFameOnKill.clear();
        this.updateParticles(false, "attackers", "defenders");
        List<SiegeClanObject> attackers2 = this.removeObjects("attackers");
        for (SiegeClanObject siegeClan : attackers2) {
            siegeClan.deleteFlag();
        }
        this.broadcastToWorld((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_IS_FINISHED).addResidenceName((Residence)this.getResidence()));
        this.removeObjects("defenders");
        this.removeObjects(DEFENDERS_WAITING);
        this.removeObjects(DEFENDERS_REFUSED);
        Clan ownerClan = ((Castle)this.getResidence()).getOwner();
        if (ownerClan != null) {
            if (this._oldOwner == ownerClan) {
                ((Castle)this.getResidence()).getOwner().setCastleDefendCount(((Castle)this.getResidence()).getOwner().getCastleDefendCount() + 1);
                ((Castle)this.getResidence()).getOwner().updateClanInDB();
            } else {
                this.broadcastToWorld((IBroadcastPacket)((SystemMessagePacket)new SystemMessagePacket(SystemMsg.CLAN_S1_IS_VICTORIOUS_OVER_S2S_CASTLE_SIEGE).addString(ownerClan.getName())).addResidenceName((Residence)this.getResidence()));
                for (UnitMember member : ownerClan) {
                    player = member.getPlayer();
                    if (player == null) continue;
                    player.sendPacket((IBroadcastPacket)PlaySoundPacket.SIEGE_VICTORY);
                    if (!player.isOnline() || !player.isHero()) continue;
                    Hero.getInstance().addHeroDiary(player.getObjectId(), 3, ((Castle)this.getResidence()).getId());
                }
            }
            for (Castle castle : ResidenceHolder.getInstance().getResidenceList(Castle.class)) {
                if (castle == this.getResidence()) continue;
                Object siegeEvent = castle.getSiegeEvent();
                Object siegeClan = ((SiegeEvent)((Object)siegeEvent)).getSiegeClan("attackers", ownerClan);
                if (siegeClan == null) {
                    siegeClan = ((SiegeEvent)((Object)siegeEvent)).getSiegeClan("defenders", ownerClan);
                }
                if (siegeClan == null) {
                    siegeClan = ((SiegeEvent)((Object)siegeEvent)).getSiegeClan(DEFENDERS_WAITING, ownerClan);
                }
                if (siegeClan == null) continue;
                ((Event)((Object)siegeEvent)).getObjects(((SiegeClanObject)siegeClan).getType()).remove(siegeClan);
                SiegeClanDAO.getInstance().delete(castle, (SiegeClanObject)siegeClan);
            }
            ((Castle)this.getResidence()).getOwnDate().setTimeInMillis(System.currentTimeMillis());
            ((Castle)this.getResidence()).getLastSiegeDate().setTimeInMillis(((Castle)this.getResidence()).getSiegeDate().getTimeInMillis());
        } else {
            this.broadcastToWorld((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_SIEGE_OF_S1_HAS_ENDED_IN_A_DRAW).addResidenceName((Residence)this.getResidence()));
            ((Castle)this.getResidence()).getOwnDate().setTimeInMillis(0L);
            ((Castle)this.getResidence()).getLastSiegeDate().setTimeInMillis(((Castle)this.getResidence()).getSiegeDate().getTimeInMillis());
            ((Castle)this.getResidence()).setResidenceSide(ResidenceSide.NEUTRAL, false);
            ((Castle)this.getResidence()).broadcastResidenceState();
        }
        this.despawnSiegeSummons();
        if (this._oldOwner != null && this.containsObjects(HIRED_GUARDS)) {
            this.spawnAction(HIRED_GUARDS, false);
            this.removeObjects(HIRED_GUARDS);
        }
        super.stopEvent(force);
    }

    @Override
    public void reCalcNextTime(boolean onInit) {
        this.clearActions();
        long currentTimeMillis = System.currentTimeMillis();
        Calendar startSiegeDate = ((Castle)this.getResidence()).getSiegeDate();
        Calendar ownSiegeDate = ((Castle)this.getResidence()).getOwnDate();
        if (onInit) {
            if (startSiegeDate.getTimeInMillis() > currentTimeMillis) {
                this.addState(2);
                this.registerActions();
            } else if (startSiegeDate.getTimeInMillis() == 0L || startSiegeDate.getTimeInMillis() <= currentTimeMillis) {
                this.setNextSiegeTime();
            }
        } else {
            if (((Castle)this.getResidence()).getOwner() != null) {
                ((Castle)this.getResidence()).getSiegeDate().setTimeInMillis(0L);
                ((Castle)this.getResidence()).setJdbcState(JdbcEntityState.UPDATED);
                ((Castle)this.getResidence()).update();
            }
            this.setNextSiegeTime();
        }
    }

    @Override
    public void loadSiegeClans() {
        super.loadSiegeClans();
        this.addObjects(DEFENDERS_WAITING, SiegeClanDAO.getInstance().load((Residence)this.getResidence(), DEFENDERS_WAITING));
        this.addObjects(DEFENDERS_REFUSED, SiegeClanDAO.getInstance().load((Residence)this.getResidence(), DEFENDERS_REFUSED));
    }

    @Override
    public void removeState(int val) {
        super.removeState(val);
        if (val == 2) {
            this.broadcastToWorld((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_REGISTRATION_TERM_FOR_S1_HAS_ENDED).addResidenceName((Residence)this.getResidence()));
        }
    }

    @Override
    public void announce(int id, String value, int time) {
        if (id == 1) {
            int seconds = Integer.parseInt(value);
            int min = seconds / 60;
            int hour = min / 60;
            SystemMessagePacket msg = hour > 0 ? (SystemMessagePacket)new SystemMessagePacket(SystemMsg.S1_HOURS_UNTIL_CASTLE_SIEGE_CONCLUSION).addInteger(hour) : (min > 0 ? (SystemMessagePacket)new SystemMessagePacket(SystemMsg.S1_MINUTES_UNTIL_CASTLE_SIEGE_CONCLUSION).addInteger(min) : (SystemMessagePacket)new SystemMessagePacket(SystemMsg.THIS_CASTLE_SIEGE_WILL_END_IN_S1_SECONDS).addInteger(seconds));
            this.broadcastTo(msg, "attackers", "defenders");
        }
    }

    private void initControlTowers() {
        List<SpawnExObject> objects = this.getObjects(GUARDS);
        ArrayList<Spawner> spawns = new ArrayList<Spawner>();
        for (SpawnExObject o : objects) {
            spawns.addAll(o.getSpawns());
        }
        List<SiegeToggleNpcObject> ct = this.getObjects(CONTROL_TOWERS);
        for (Spawner spawn : spawns) {
            Location spawnLoc = spawn.getRandomSpawnRange().getRandomLoc(ReflectionManager.MAIN.getGeoIndex(), false);
            SiegeToggleNpcInstance closestCt = null;
            double distanceClosest = 0.0;
            for (SiegeToggleNpcObject c : ct) {
                SiegeToggleNpcInstance npcTower = c.getToggleNpc();
                double distance = npcTower.getDistance(spawnLoc);
                if (closestCt == null || distance < distanceClosest) {
                    closestCt = npcTower;
                    distanceClosest = distance;
                }
                closestCt.register(spawn);
            }
        }
    }

    private void damageZoneAction(boolean active) {
        if (this.containsObjects(BOUGHT_ZONES)) {
            this.zoneAction(BOUGHT_ZONES, active);
        }
    }

    private void setNextSiegeTime() {
        long startTime = this.generateSiegeDateTime(this._startTimePattern);
        if (startTime == 0L) {
            return;
        }
        this.broadcastToWorld((IBroadcastPacket)new SystemMessagePacket(SystemMsg.S1_HAS_ANNOUNCED_THE_NEXT_CASTLE_SIEGE_TIME).addResidenceName((Residence)this.getResidence()));
        this.clearActions();
        ((Castle)this.getResidence()).getSiegeDate().setTimeInMillis(startTime);
        ((Castle)this.getResidence()).setJdbcState(JdbcEntityState.UPDATED);
        ((Castle)this.getResidence()).update();
        this.registerActions();
        this.addState(2);
    }

    @Override
    public boolean isAttackersInAlly() {
        return !this._firstStep;
    }

    @Override
    public boolean canResurrect(Creature active, Creature target, boolean force, boolean quiet) {
        boolean playerInZone = this.checkIfInZone(active);
        boolean targetInZone = this.checkIfInZone(target);
        if (!playerInZone && !targetInZone || !targetInZone) {
            return true;
        }
        Player resurectPlayer = active.getPlayer();
        Player targetPlayer = target.getPlayer();
        if (!resurectPlayer.containsEvent(this) || !targetPlayer.containsEvent(this)) {
            if (!quiet) {
                if (force) {
                    targetPlayer.sendPacket((IBroadcastPacket)SystemMsg.IT_IS_NOT_POSSIBLE_TO_RESURRECT_IN_BATTLEFIELDS_WHERE_A_SIEGE_WAR_IS_TAKING_PLACE);
                }
                active.sendPacket((IBroadcastPacket)(force ? SystemMsg.IT_IS_NOT_POSSIBLE_TO_RESURRECT_IN_BATTLEFIELDS_WHERE_A_SIEGE_WAR_IS_TAKING_PLACE : SystemMsg.INVALID_TARGET));
            }
            return false;
        }
        SiegeClanObject targetSiegeClan = this.getSiegeClan("attackers", targetPlayer.getClan());
        if (targetSiegeClan == null) {
            targetSiegeClan = this.getSiegeClan("defenders", targetPlayer.getClan());
        }
        if (targetSiegeClan == null || targetSiegeClan.getType() == "attackers") {
            if (targetSiegeClan == null || targetSiegeClan.getFlag() == null) {
                if (!quiet) {
                    if (force) {
                        targetPlayer.sendPacket((IBroadcastPacket)SystemMsg.IF_A_BASE_CAMP_DOES_NOT_EXIST_RESURRECTION_IS_NOT_POSSIBLE);
                    }
                    active.sendPacket((IBroadcastPacket)(force ? SystemMsg.IF_A_BASE_CAMP_DOES_NOT_EXIST_RESURRECTION_IS_NOT_POSSIBLE : SystemMsg.INVALID_TARGET));
                }
                return false;
            }
        } else {
            List<SiegeToggleNpcObject> towers = this.getObjects(CONTROL_TOWERS);
            boolean canRes = true;
            for (SiegeToggleNpcObject t : towers) {
                if (t.isAlive()) continue;
                canRes = false;
            }
            if (!canRes) {
                if (!quiet) {
                    if (force) {
                        targetPlayer.sendPacket((IBroadcastPacket)SystemMsg.THE_GUARDIAN_TOWER_HAS_BEEN_DESTROYED_AND_RESURRECTION_IS_NOT_POSSIBLE);
                    }
                    active.sendPacket((IBroadcastPacket)(force ? SystemMsg.THE_GUARDIAN_TOWER_HAS_BEEN_DESTROYED_AND_RESURRECTION_IS_NOT_POSSIBLE : SystemMsg.INVALID_TARGET));
                }
                return false;
            }
        }
        if (force) {
            return true;
        }
        if (!quiet) {
            active.sendPacket((IBroadcastPacket)SystemMsg.INVALID_TARGET);
        }
        return false;
    }

    @Override
    public boolean ifVar(String name) {
        if (name.equals(LIGHT_SIDE)) {
            return ((Castle)this.getResidence()).getResidenceSide() == ResidenceSide.LIGHT;
        }
        if (name.equals(DARK_SIDE)) {
            return ((Castle)this.getResidence()).getResidenceSide() == ResidenceSide.DARK;
        }
        return super.ifVar(name);
    }

    public void addVisitedParticipant(Player player) {
        this._visitedParticipants.add(player.getObjectId());
    }

    public boolean canRegisterOnSiege(Player player, Clan clan, boolean attacker) {
        IBroadcastPacket msg;
        if (attacker) {
            if (((Castle)this.getResidence()).getOwnerId() == clan.getClanId()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.CASTLE_OWNING_CLANS_ARE_AUTOMATICALLY_REGISTERED_ON_THE_DEFENDING_SIDE);
                return false;
            }
            Alliance alliance = clan.getAlliance();
            if (alliance != null) {
                for (Clan c : alliance.getMembers()) {
                    if (c.getCastle() != ((Castle)this.getResidence()).getId()) continue;
                    player.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REGISTER_AS_AN_ATTACKER_BECAUSE_YOU_ARE_IN_AN_ALLIANCE_WITH_THE_CASTLE_OWNING_CLAN);
                    return false;
                }
            }
            if (clan.getCastle() != 0) {
                player.sendPacket((IBroadcastPacket)SystemMsg.A_CLAN_THAT_OWNS_A_CASTLE_CANNOT_PARTICIPATE_IN_ANOTHER_SIEGE);
                return false;
            }
            if (this.getSiegeClan("attackers", clan) != null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ALREADY_REQUESTED_A_CASTLE_SIEGE);
                return false;
            }
            if (this.getSiegeClan("defenders", clan) != null || this.getSiegeClan(DEFENDERS_WAITING, clan) != null || this.getSiegeClan(DEFENDERS_REFUSED, clan) != null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ALREADY_REGISTERED_TO_THE_DEFENDER_SIDE_AND_MUST_CANCEL_YOUR_REGISTRATION_BEFORE_SUBMITTING_YOUR_REQUEST);
                return false;
            }
        } else {
            if (((Castle)this.getResidence()).getOwnerId() == 0) {
                return false;
            }
            if (((Castle)this.getResidence()).getOwnerId() == clan.getClanId()) {
                player.sendPacket((IBroadcastPacket)SystemMsg.CASTLE_OWNING_CLANS_ARE_AUTOMATICALLY_REGISTERED_ON_THE_DEFENDING_SIDE);
                return false;
            }
            if (clan.getCastle() != 0) {
                player.sendPacket((IBroadcastPacket)SystemMsg.A_CLAN_THAT_OWNS_A_CASTLE_CANNOT_PARTICIPATE_IN_ANOTHER_SIEGE);
                return false;
            }
            if (this.getSiegeClan("defenders", clan) != null || this.getSiegeClan(DEFENDERS_WAITING, clan) != null || this.getSiegeClan(DEFENDERS_REFUSED, clan) != null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_HAVE_ALREADY_REQUESTED_A_CASTLE_SIEGE);
                return false;
            }
            if (this.getSiegeClan("attackers", clan) != null) {
                player.sendPacket((IBroadcastPacket)SystemMsg.YOU_ARE_ALREADY_REGISTERED_TO_THE_ATTACKER_SIDE_AND_MUST_CANCEL_YOUR_REGISTRATION_BEFORE_SUBMITTING_YOUR_REQUEST);
                return false;
            }
        }
        if ((msg = this.checkSiegeClanLevel(clan)) != null) {
            player.sendPacket(msg);
            return false;
        }
        return true;
    }

    public IBroadcastPacket checkSiegeClanLevel(Clan clan) {
        if (clan.getLevel() < 3) {
            return SystemMsg.ONLY_CLANS_OF_LEVEL_5_OR_HIGHER_MAY_REGISTER_FOR_A_CASTLE_SIEGE;
        }
        return null;
    }

    public boolean canCastSeal(Player player) {
        return true;
    }

    public void onLordDie(NpcInstance npc) {
    }

    public class KillListener
    implements OnKillListener {
        @Override
        public void onKill(Creature actor, Creature victim) {
            Player winner = actor.getPlayer();
            if (!(winner != null && victim.isPlayer() && winner != victim && CastleSiegeEvent.this.checkIfInZone(victim) && ((Player)victim).isUserRelationActive() && victim.containsEvent(CastleSiegeEvent.this))) {
                return;
            }
            List<Player> players = winner.getParty() == null ? Collections.singletonList(winner) : winner.getParty().getPartyMembers();
            double bonus = Config.ALT_PARTY_BONUS[Math.min(Config.ALT_PARTY_BONUS.length, players.size()) - 1];
            int value = (int)(Math.round(72.0 * bonus) / (long)players.size());
            for (Player temp : players) {
                if (!temp.containsEvent(CastleSiegeEvent.this) || temp.getLevel() < 40 || !temp.isInRange(winner, Config.ALT_PARTY_DISTRIBUTION_RANGE)) continue;
                temp.setFame(temp.getFame() + value, CastleSiegeEvent.this.toString(), true);
            }
            ((Player)victim).startEnableUserRelationTask(300000L, CastleSiegeEvent.this);
            CastleSiegeEvent.this._blockedFameOnKill.put(victim.getObjectId(), System.currentTimeMillis() + 300000L);
        }

        @Override
        public boolean ignorePetOrSummon() {
            return true;
        }
    }
}

