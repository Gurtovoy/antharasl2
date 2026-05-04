/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.impl;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.Map;
import l2s.commons.collections.LazyArrayList;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.Config;
import l2s.gameserver.dao.SiegeClanDAO;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.actor.OnDeathListener;
import l2s.gameserver.listener.actor.OnKillListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.base.RestartType;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.objects.SiegeClanObject;
import l2s.gameserver.model.entity.events.objects.ZoneObject;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.instances.DoorInstance;
import l2s.gameserver.model.instances.SummonInstance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.templates.DoorTemplate;
import l2s.gameserver.utils.TeleportUtils;
import org.apache.commons.lang3.StringUtils;
import org.napile.primitive.maps.IntLongMap;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntLongMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.pair.IntObjectPair;

public abstract class SiegeEvent<R extends Residence, S extends SiegeClanObject>
extends Event {
    public static final String HAVE_OWNER = "have_owner";
    public static final String HAVE_OLD_OWNER = "have_old_owner";
    public static final String ATTACKERS = "attackers";
    public static final String DEFENDERS = "defenders";
    public static final String SPECTATORS = "spectators";
    public static final String FROM_RESIDENCE_TO_TOWN = "from_residence_to_town";
    public static final String SIEGE_ZONES = "siege_zones";
    public static final String FLAG_ZONES = "flag_zones";
    public static final String DAY_OF_WEEK = "day_of_week";
    public static final String HOUR_OF_DAY = "hour_of_day";
    public static final String SIEGE_INTERVAL_IN_WEEKS = "siege_interval_in_weeks";
    public static final String REGISTRATION = "registration";
    public static final String DOORS = "doors";
    public static final int PROGRESS_STATE = 1;
    public static final int REGISTRATION_STATE = 2;
    public static final long BLOCK_FAME_TIME = 300000L;
    public static final long DAY_IN_MILISECONDS = 86400000L;
    protected R _residence;
    private int _state;
    protected Clan _oldOwner;
    protected OnKillListener _killListener;
    protected OnDeathListener _doorDeathListener = new DoorDeathListener();
    protected IntObjectMap<SiegeSummonInfo> _siegeSummons = new CHashIntObjectMap();
    protected IntLongMap _blockedFameOnKill = new CHashIntLongMap();
    protected final SchedulingPattern _startTimePattern;
    protected final Calendar _validationDate;

    public SiegeEvent(MultiValueSet<String> set) {
        super(set);
        String startTime = set.getString("start_time", null);
        this._startTimePattern = !StringUtils.isEmpty((CharSequence)startTime) ? new SchedulingPattern(startTime) : null;
        int[] validationTimeArray = set.getIntegerArray("validation_date", new int[]{2, 4, 2003});
        this._validationDate = Calendar.getInstance();
        this._validationDate.set(5, validationTimeArray[0]);
        this._validationDate.set(2, validationTimeArray[1] - 1);
        this._validationDate.set(1, validationTimeArray[2]);
        this._validationDate.set(11, 0);
        this._validationDate.set(12, 0);
        this._validationDate.set(13, 0);
        this._validationDate.set(14, 0);
    }

    public long generateSiegeDateTime(SchedulingPattern pattern) {
        if (pattern == null) {
            return 0L;
        }
        long currentTime = System.currentTimeMillis();
        long time = pattern.next(this._validationDate.getTimeInMillis());
        while (time < currentTime) {
            time = pattern.next(time);
        }
        return time;
    }

    @Override
    public void startEvent() {
        this.addState(1);
        super.startEvent();
    }

    @Override
    public void stopEvent(boolean force) {
        this.removeState(1);
        this.despawnSiegeSummons();
        this.reCalcNextTime(false);
        super.stopEvent(force);
    }

    public void processStep(Clan clan) {
    }

    @Override
    public void reCalcNextTime(boolean onInit) {
        this.clearActions();
        Calendar startSiegeDate = ((Residence)this.getResidence()).getSiegeDate();
        if (onInit) {
            if (startSiegeDate.getTimeInMillis() <= System.currentTimeMillis()) {
                startSiegeDate.setTimeInMillis(this.generateSiegeDateTime(this._startTimePattern));
                ((Residence)this.getResidence()).setJdbcState(JdbcEntityState.UPDATED);
            }
        } else {
            startSiegeDate.setTimeInMillis(this.generateSiegeDateTime(this._startTimePattern));
            ((Residence)this.getResidence()).setJdbcState(JdbcEntityState.UPDATED);
        }
        this.registerActions();
        this.getResidence().update();
    }

    @Override
    protected long startTimeMillis() {
        return this.getSiegeDate().getTimeInMillis();
    }

    public Calendar getSiegeDate() {
        return ((Residence)this.getResidence()).getSiegeDate();
    }

    @Override
    public void teleportPlayers(String t) {
        S siegeClan;
        List<Player> players = new ArrayList<Player>();
        Clan ownerClan = ((Residence)this.getResidence()).getOwner();
        if (t.equalsIgnoreCase(HAVE_OWNER)) {
            if (ownerClan != null) {
                for (Player player : this.getPlayersInZone()) {
                    if (player.getClan() != ownerClan) continue;
                    players.add(player);
                }
            }
        } else if (t.equalsIgnoreCase(ATTACKERS)) {
            for (Player player : this.getPlayersInZone()) {
                siegeClan = this.getSiegeClan(ATTACKERS, player.getClan());
                if (siegeClan == null || !((SiegeClanObject)siegeClan).isParticle(player)) continue;
                players.add(player);
            }
        } else if (t.equalsIgnoreCase(DEFENDERS)) {
            for (Player player : this.getPlayersInZone()) {
                if (ownerClan != null && player.getClan() != null && player.getClan() == ownerClan || (siegeClan = this.getSiegeClan(DEFENDERS, player.getClan())) == null || !((SiegeClanObject)siegeClan).isParticle(player)) continue;
                players.add(player);
            }
        } else if (t.equalsIgnoreCase(SPECTATORS)) {
            for (Player player : this.getPlayersInZone()) {
                if (ownerClan != null && player.getClan() != null && player.getClan() == ownerClan || player.getClan() != null && (this.getSiegeClan(ATTACKERS, player.getClan()) != null || this.getSiegeClan(DEFENDERS, player.getClan()) != null)) continue;
                players.add(player);
            }
        } else if (t.equalsIgnoreCase(FROM_RESIDENCE_TO_TOWN)) {
            for (Player player : ((Residence)this.getResidence()).getZone().getInsidePlayers()) {
                if (ownerClan != null && player.getClan() != null && player.getClan() == ownerClan) continue;
                players.add(player);
            }
        } else {
            players = (List<Player>)(List<?>)this.getPlayersInZone();
        }
        for (Player player : players) {
            Location loc = null;
            loc = t.equalsIgnoreCase(HAVE_OWNER) || t.equalsIgnoreCase(DEFENDERS) ? ((Residence)this.getResidence()).getOwnerRestartPoint() : (t.equalsIgnoreCase(FROM_RESIDENCE_TO_TOWN) ? TeleportUtils.getRestartPoint(player, RestartType.TO_VILLAGE).getLoc() : ((Residence)this.getResidence()).getNotOwnerRestartPoint(player));
            player.teleToLocation((ILocation)loc, ReflectionManager.MAIN);
        }
    }

    public List<Player> getPlayersInZone() {
        List<ZoneObject> zones = this.getObjects(SIEGE_ZONES);
        LazyArrayList result = new LazyArrayList();
        for (ZoneObject zone : zones) {
            result.addAll(zone.getInsidePlayers());
        }
        return result;
    }

    public void broadcastInZone(IBroadcastPacket ... packet) {
        for (Player player : this.getPlayersInZone()) {
            player.sendPacket(packet);
        }
    }

    public boolean checkIfInZone(Creature character) {
        List<ZoneObject> zones = this.getObjects(SIEGE_ZONES);
        for (ZoneObject zone : zones) {
            if (!zone.checkIfInZone(character)) continue;
            return true;
        }
        return false;
    }

    public void broadcastInZone2(IBroadcastPacket ... packet) {
        for (Player player : ((Residence)this.getResidence()).getZone().getInsidePlayers()) {
            player.sendPacket(packet);
        }
    }

    public void loadSiegeClans() {
        this.addObjects(ATTACKERS, SiegeClanDAO.getInstance().load((Residence)this.getResidence(), ATTACKERS));
        this.addObjects(DEFENDERS, SiegeClanDAO.getInstance().load((Residence)this.getResidence(), DEFENDERS));
    }

    public S newSiegeClan(String type, int clanId, long param, long date) {
        Clan clan = ClanTable.getInstance().getClan(clanId);
        return (S)(clan == null ? null : new SiegeClanObject(type, clan, param, date));
    }

    public void updateParticles(boolean start, String ... arg) {
        for (String a : arg) {
            List<SiegeClanObject> siegeClans = this.getObjects(a);
            for (SiegeClanObject s : siegeClans) {
                s.setEvent(start, this);
            }
        }
    }

    public S getSiegeClan(String name, Clan clan) {
        if (clan == null) {
            return null;
        }
        return this.getSiegeClan(name, clan.getClanId());
    }

    public S getSiegeClan(String name, int objectId) {
        List<SiegeClanObject> siegeClanList = this.getObjects(name);
        if (siegeClanList.isEmpty()) {
            return null;
        }
        for (int i = 0; i < siegeClanList.size(); ++i) {
            SiegeClanObject siegeClan = (SiegeClanObject)siegeClanList.get(i);
            if (siegeClan.getObjectId() != objectId) continue;
            return (S)siegeClan;
        }
        return null;
    }

    public void broadcastTo(IBroadcastPacket packet, String ... types) {
        for (String type : types) {
            List<SiegeClanObject> siegeClans = this.getObjects(type);
            for (SiegeClanObject siegeClan : siegeClans) {
                siegeClan.broadcast(packet);
            }
        }
    }

    @Override
    public void initEvent() {
        this._residence = ResidenceHolder.getInstance().getResidence(this.getId());
        this.loadSiegeClans();
        this.clearActions();
        super.initEvent();
    }

    @Override
    public boolean ifVar(String name) {
        if (name.equals(HAVE_OWNER)) {
            return ((Residence)this.getResidence()).getOwner() != null;
        }
        if (name.equals(HAVE_OLD_OWNER)) {
            return this._oldOwner != null;
        }
        return false;
    }

    @Override
    public void findEvent(Player player) {
        if (!this.isInProgress() || player.getClan() == null) {
            return;
        }
        if (this.getSiegeClan(ATTACKERS, player.getClan()) != null || this.getSiegeClan(DEFENDERS, player.getClan()) != null) {
            long diff;
            player.addEvent(this);
            long val = this._blockedFameOnKill.get(player.getObjectId());
            if (val > 0L && (diff = val - System.currentTimeMillis()) > 0L) {
                player.startEnableUserRelationTask(diff, this);
            }
        }
    }

    @Override
    public void checkRestartLocs(Player player, Map<RestartType, Boolean> r) {
        if (this.getObjects(FLAG_ZONES).isEmpty()) {
            return;
        }
        S clan = this.getSiegeClan(ATTACKERS, player.getClan());
        if (clan != null && ((SiegeClanObject)clan).getFlag() != null) {
            r.put(RestartType.TO_FLAG, Boolean.TRUE);
        }
    }

    @Override
    public Location getRestartLoc(Player player, RestartType type) {
        if (!player.getReflection().isMain()) {
            return null;
        }
        if (type == RestartType.TO_FLAG) {
            S attackerClan = this.getSiegeClan(ATTACKERS, player.getClan());
            if (!this.getObjects(FLAG_ZONES).isEmpty() && attackerClan != null && ((SiegeClanObject)attackerClan).getFlag() != null) {
                return Location.findPointToStay(((SiegeClanObject)attackerClan).getFlag(), 50, 75);
            }
            player.sendPacket((IBroadcastPacket)SystemMsg.IF_A_BASE_CAMP_DOES_NOT_EXIST_RESURRECTION_IS_NOT_POSSIBLE);
        }
        return null;
    }

    @Override
    public int getRelation(Player thisPlayer, Player targetPlayer, int result) {
        Clan clan1 = thisPlayer.getClan();
        Clan clan2 = targetPlayer.getClan();
        if (clan1 == null || clan2 == null) {
            return result;
        }
        if (targetPlayer.containsEvent(this)) {
            result |= 0x200;
            S siegeClan1 = this.getSiegeClan(ATTACKERS, clan1);
            S siegeClan2 = this.getSiegeClan(ATTACKERS, clan2);
            result = siegeClan1 == null && siegeClan2 == null || siegeClan1 == siegeClan2 || siegeClan1 != null && siegeClan2 != null && this.isAttackersInAlly() ? (result |= 0x800) : (result |= 0x1000);
            if (siegeClan1 != null) {
                result |= 0x400;
            }
        }
        return result;
    }

    @Override
    public int getUserRelation(Player thisPlayer, int oldRelation) {
        oldRelation |= 0x80;
        S siegeClan = this.getSiegeClan(ATTACKERS, thisPlayer.getClan());
        if (siegeClan != null) {
            oldRelation |= 0x100;
        }
        return oldRelation;
    }

    @Override
    public SystemMsg checkForAttack(Creature target, Creature attacker, Skill skill, boolean force) {
        if (!this.checkIfInZone(target) || !this.checkIfInZone(attacker)) {
            return null;
        }
        if (!target.containsEvent(this)) {
            return null;
        }
        Player player = target.getPlayer();
        if (player == null) {
            return null;
        }
        S siegeClan1 = this.getSiegeClan(ATTACKERS, player.getClan());
        if (siegeClan1 == null && attacker.isSiegeGuard()) {
            return SystemMsg.INVALID_TARGET;
        }
        Player playerAttacker = attacker.getPlayer();
        if (playerAttacker == null) {
            return SystemMsg.INVALID_TARGET;
        }
        S siegeClan2 = this.getSiegeClan(ATTACKERS, playerAttacker.getClan());
        if (force && siegeClan1 != null && siegeClan2 != null && this.isAttackersInAlly()) {
            return SystemMsg.FORCE_ATTACK_IS_IMPOSSIBLE_AGAINST_A_TEMPORARY_ALLIED_MEMBER_DURING_A_SIEGE;
        }
        if (siegeClan1 == null && siegeClan2 == null) {
            return SystemMsg.INVALID_TARGET;
        }
        return null;
    }

    @Override
    public boolean isInProgress() {
        return this.hasState(1);
    }

    @Override
    public void action(String name, boolean start) {
        if (name.equalsIgnoreCase(REGISTRATION)) {
            if (start) {
                this.addState(2);
            } else {
                this.removeState(2);
            }
        } else {
            super.action(name, start);
        }
    }

    public boolean isAttackersInAlly() {
        return false;
    }

    @Override
    public void onAddEvent(GameObject object) {
        if (this._killListener == null) {
            return;
        }
        if (object.isPlayer()) {
            ((Player)object).addListener(this._killListener);
        }
    }

    @Override
    public void onRemoveEvent(GameObject object) {
        if (this._killListener == null) {
            return;
        }
        if (object.isPlayer()) {
            ((Player)object).removeListener(this._killListener);
        }
    }

    @Override
    public List<Player> broadcastPlayers(int range) {
        return this.itemObtainPlayers();
    }

    @Override
    public EventType getType() {
        return EventType.SIEGE_EVENT;
    }

    @Override
    public List<Player> itemObtainPlayers() {
        List<Player> playersInZone = this.getPlayersInZone();
        LazyArrayList list = new LazyArrayList(playersInZone.size());
        for (Player player : this.getPlayersInZone()) {
            if (!player.containsEvent(this)) continue;
            list.add(player);
        }
        return list;
    }

    @Override
    public void giveItem(Player player, int itemId, long count) {
        if (Config.ALT_NO_FAME_FOR_DEAD && itemId == -300 && player.isDead()) {
            return;
        }
        super.giveItem(player, itemId, count);
    }

    public Location getEnterLoc(Player player, Zone zone) {
        S siegeClan = this.getSiegeClan(ATTACKERS, player.getClan());
        if (siegeClan != null) {
            if (((SiegeClanObject)siegeClan).getFlag() != null) {
                return Location.findAroundPosition(((SiegeClanObject)siegeClan).getFlag(), 50, 75);
            }
            return ((Residence)this.getResidence()).getNotOwnerRestartPoint(player);
        }
        return ((Residence)this.getResidence()).getOwnerRestartPoint();
    }

    public boolean canPK(Player target, Player killer) {
        if (!this.isInProgress()) {
            return true;
        }
        if (!target.containsEvent(this)) {
            return true;
        }
        S targetClan = this.getSiegeClan(ATTACKERS, target.getClan());
        S killerClan = this.getSiegeClan(ATTACKERS, killer.getClan());
        if (targetClan != null && killerClan != null && this.isAttackersInAlly()) {
            return true;
        }
        return targetClan == null && killerClan == null;
    }

    public R getResidence() {
        return this._residence;
    }

    public void addState(int b) {
        this._state |= b;
    }

    public void removeState(int b) {
        this._state &= ~b;
    }

    public boolean hasState(int val) {
        return (this._state & val) == val;
    }

    public boolean isRegistrationOver() {
        return !this.hasState(2);
    }

    public void addSiegeSummon(Player player, SummonInstance summon) {
        this._siegeSummons.put(player.getObjectId(), new SiegeSummonInfo(summon));
    }

    public boolean containsSiegeSummon(Servitor cha) {
        SiegeSummonInfo siegeSummonInfo = (SiegeSummonInfo)this._siegeSummons.get(cha.getPlayer().getObjectId());
        if (siegeSummonInfo == null) {
            return false;
        }
        return siegeSummonInfo._summonRef.get() == cha;
    }

    public void removeSiegeSummon(Player player, Servitor cha) {
        this._siegeSummons.remove(player.getObjectId());
    }

    public void updateSiegeSummon(Player player, SummonInstance summon) {
        SiegeSummonInfo siegeSummonInfo = (SiegeSummonInfo)this._siegeSummons.get(player.getObjectId());
        if (siegeSummonInfo == null) {
            return;
        }
        if (siegeSummonInfo.getSkillId() == summon.getSkillId()) {
            summon.setSiegeSummon(true);
            siegeSummonInfo._summonRef = summon.getRef();
        }
    }

    public void despawnSiegeSummons() {
        for (IntObjectPair entry : this._siegeSummons.entrySet()) {
            SiegeSummonInfo summonInfo = (SiegeSummonInfo)entry.getValue();
            SummonInstance summon = (SummonInstance)summonInfo._summonRef.get();
            if (summon == null) continue;
            summon.unSummon(false);
        }
        this._siegeSummons.clear();
    }

    public void removeBlockFame(Player player) {
        this._blockedFameOnKill.remove(player.getObjectId());
    }

    public class DoorDeathListener
    implements OnDeathListener {
        @Override
        public void onDeath(Creature actor, Creature killer) {
            if (!SiegeEvent.this.isInProgress()) {
                return;
            }
            DoorInstance door = (DoorInstance)actor;
            if (door.getDoorType() == DoorTemplate.DoorType.WALL) {
                return;
            }
            SiegeEvent.this.broadcastTo(SystemMsg.THE_CASTLE_GATE_HAS_BEEN_DESTROYED, SiegeEvent.ATTACKERS, SiegeEvent.DEFENDERS);
        }
    }

    protected class SiegeSummonInfo {
        private int _skillId;
        private int _ownerObjectId;
        private HardReference<SummonInstance> _summonRef = HardReferences.emptyRef();

        SiegeSummonInfo(SummonInstance summonInstance) {
            this._skillId = summonInstance.getSkillId();
            this._ownerObjectId = summonInstance.getPlayer().getObjectId();
            this._summonRef = summonInstance.getRef();
        }

        public int getSkillId() {
            return this._skillId;
        }

        public int getOwnerObjectId() {
            return this._ownerObjectId;
        }
    }
}

