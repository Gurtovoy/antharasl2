/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.CHashIntObjectMap
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.tables;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.ClanLeaderRequestDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.idfactory.IdFactory;
import l2s.gameserver.instancemanager.ServerVariables;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.PledgeAttendanceType;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.ClanChangeLeaderRequest;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.TimeUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ClanTable {
    private static final Logger _log = LoggerFactory.getLogger(ClanTable.class);
    private static final long CLAN_WAR_STORE_DELAY = TimeUnit.MILLISECONDS.convert(10L, TimeUnit.MINUTES);
    private static final String REFRESH_CLAN_ATTENDANCE_INFO_VAR = "clan_refresh_date";
    private static ClanTable _instance;
    private final Map<Integer, Clan> _clans = new ConcurrentHashMap<Integer, Clan>();
    private final Map<Integer, Alliance> _alliances = new ConcurrentHashMap<Integer, Alliance>();
    private final IntObjectMap<ClanChangeLeaderRequest> _changeRequests = new CHashIntObjectMap();
    private final List<ClanWar> _clanWarUpdateCache = new ArrayList<ClanWar>();

    public static ClanTable getInstance() {
        if (_instance == null) {
            new ClanTable();
        }
        return _instance;
    }

    public Clan[] getClans() {
        return this._clans.values().toArray(new Clan[this._clans.size()]);
    }

    public Alliance[] getAlliances() {
        return this._alliances.values().toArray(new Alliance[this._alliances.size()]);
    }

    private ClanTable() {
        _instance = this;
        this.restoreClans();
        this.restoreAllies();
        this.restoreClanWars();
        this._changeRequests.putAll(ClanLeaderRequestDAO.getInstance().select());
    }

    public Clan getClan(int clanId) {
        if (clanId <= 0) {
            return null;
        }
        return this._clans.get(clanId);
    }

    public String getClanName(int clanId) {
        Clan c = this.getClan(clanId);
        return c != null ? c.getName() : "";
    }

    public Clan getClanByCharId(int charId) {
        if (charId <= 0) {
            return null;
        }
        for (Clan clan : this.getClans()) {
            if (clan == null || !clan.isAnyMember(charId)) continue;
            return clan;
        }
        return null;
    }

    public Alliance getAlliance(int allyId) {
        if (allyId <= 0) {
            return null;
        }
        return this._alliances.get(allyId);
    }

    public Alliance getAllianceByCharId(int charId) {
        if (charId <= 0) {
            return null;
        }
        Clan charClan = this.getClanByCharId(charId);
        return charClan == null ? null : charClan.getAlliance();
    }

    public Map.Entry<Clan, Alliance> getClanAndAllianceByCharId(int charId) {
        Player player = GameObjectsStorage.getPlayer(charId);
        Clan charClan = player != null ? player.getClan() : this.getClanByCharId(charId);
        return new AbstractMap.SimpleEntry<Clan, Alliance>(charClan, charClan == null ? null : charClan.getAlliance());
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restoreClans() {
        ArrayList<Integer> clanIds = new ArrayList<Integer>();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet result = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT clan_id FROM clan_data");
            result = statement.executeQuery();
            while (result.next()) {
                clanIds.add(result.getInt("clan_id"));
            }
        }
        catch (Exception e) {
            try {
                _log.warn("Error while restoring clans!!! " + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, result);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)result);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)result);
        Iterator e = clanIds.iterator();
        while (e.hasNext()) {
            int clanId = (Integer)e.next();
            Clan clan = Clan.restore(clanId);
            if (clan == null) {
                _log.warn("Error while restoring clanId: " + clanId);
                continue;
            }
            if (clan.getAllSize() <= 0) {
                _log.warn("membersCount = 0 for clanId: " + clanId);
                continue;
            }
            if (clan.getLeader() == null) {
                _log.warn("Not found leader for clanId: " + clanId);
                continue;
            }
            this._clans.put(clan.getClanId(), clan);
        }
        long lastRefreshTime = ServerVariables.getLong(REFRESH_CLAN_ATTENDANCE_INFO_VAR, System.currentTimeMillis());
        if (TimeUtils.DAILY_DATE_PATTERN.next(lastRefreshTime) < System.currentTimeMillis()) {
            this.refreshClanAttendanceInfo();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restoreAllies() {
        ArrayList<Integer> allyIds = new ArrayList<Integer>();
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet result = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT ally_id FROM ally_data");
            result = statement.executeQuery();
            while (result.next()) {
                allyIds.add(result.getInt("ally_id"));
            }
        }
        catch (Exception e) {
            try {
                _log.warn("Error while restoring allies!!! " + e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, result);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)result);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)result);
        Iterator iterator = allyIds.iterator();
        while (iterator.hasNext()) {
            int allyId = (Integer)iterator.next();
            Alliance ally = new Alliance(allyId);
            if (ally.getMembersCount() <= 0) {
                _log.warn("membersCount = 0 for allyId: " + allyId);
                continue;
            }
            if (ally.getLeader() == null) {
                _log.warn("Not found leader for allyId: " + allyId);
                continue;
            }
            this._alliances.put(ally.getAllyId(), ally);
        }
    }

    public Clan getClanByName(String clanName) {
        for (Clan clan : this._clans.values()) {
            if (!clan.getName().equalsIgnoreCase(clanName)) continue;
            return clan;
        }
        return null;
    }

    public int getClansSizeByName(String clanName) {
        int result = 0;
        for (Clan clan : this._clans.values()) {
            if (!clan.getName().equalsIgnoreCase(clanName)) continue;
            ++result;
        }
        return result;
    }

    public Alliance getAllyByName(String allyName) {
        for (Alliance ally : this._alliances.values()) {
            if (!ally.getAllyName().equalsIgnoreCase(allyName)) continue;
            return ally;
        }
        return null;
    }

    public Clan createClan(Player player, String clanName) {
        if (this.getClanByName(clanName) == null) {
            UnitMember leader = new UnitMember(player);
            leader.setLeaderOf(0);
            Clan clan = new Clan(IdFactory.getInstance().getNextId());
            SubUnit unit = new SubUnit(clan, 0, leader, clanName, false);
            unit.addUnitMember(leader);
            clan.addSubUnit(unit, false);
            clan.store();
            clan.checkSkills();
            player.setPledgeType(0);
            player.setClan(clan);
            player.setPowerGrade(6);
            leader.setAttendanceType(PledgeAttendanceType.NOT_ACQUIRED);
            leader.setPlayerInstance(player, false);
            this._clans.put(clan.getClanId(), clan);
            clan.onEnterClan(player);
            return clan;
        }
        return null;
    }

    public void dissolveClan(Clan clan) {
        int leaderId = clan.getLeaderId();
        clan.flush();
        ClanTable.deleteClanFromDb(clan.getClanId(), leaderId);
        this._clans.remove(clan.getClanId());
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public static void deleteClanFromDb(int clanId, int leaderId) {
        long curtime = System.currentTimeMillis();
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET clanid=0,title='',pledge_type=0,pledge_rank=0,lvl_joined_academy=0,apprentice=0,leaveclan=? WHERE clanid=?");
            statement.setLong(1, curtime / 1000L);
            statement.setInt(2, clanId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE characters SET deleteclan=? WHERE obj_Id=?");
            statement.setLong(1, curtime / 1000L);
            statement.setInt(2, leaderId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM clan_data WHERE clan_id=?");
            statement.setInt(1, clanId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM clan_subpledges WHERE clan_id=?");
            statement.setInt(1, clanId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM clan_privs WHERE clan_id=?");
            statement.setInt(1, clanId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM siege_clans WHERE clan_id=?");
            statement.setInt(1, clanId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM siege_players WHERE clan_id=?");
            statement.setInt(1, clanId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM clan_wars WHERE attacker_clan=? OR attacked_clan=?");
            statement.setInt(1, clanId);
            statement.setInt(2, clanId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM clan_skills WHERE clan_id=?");
            statement.setInt(1, clanId);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("could not dissolve clan: ", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public Alliance createAlliance(Player player, String allyName) {
        Alliance alliance = null;
        if (this.getAllyByName(allyName) == null) {
            Clan leader = player.getClan();
            alliance = new Alliance(IdFactory.getInstance().getNextId(), allyName, leader);
            alliance.store();
            this._alliances.put(alliance.getAllyId(), alliance);
            player.getClan().setAllyId(alliance.getAllyId());
            for (Player temp : player.getClan().getOnlineMembers()) {
                temp.broadcastCharInfo();
            }
        }
        return alliance;
    }

    public void dissolveAlly(Player player) {
        int allyId = player.getAllyId();
        for (Clan member : player.getAlliance().getMembers()) {
            member.setAllyId(0);
            member.broadcastClanStatus(false, true, false);
            member.broadcastToOnlineMembers(SystemMsg.YOU_HAVE_WITHDRAWN_FROM_THE_ALLIANCE);
            member.setLeavedAlly();
        }
        this.deleteAllyFromDb(allyId);
        this._alliances.remove(allyId);
        player.sendPacket((IBroadcastPacket)SystemMsg.THE_ALLIANCE_HAS_BEEN_DISSOLVED);
        player.getClan().setDissolvedAlly();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void deleteAllyFromDb(int allyId) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET ally_id=0 WHERE ally_id=?");
            statement.setInt(1, allyId);
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("DELETE FROM ally_data WHERE ally_id=?");
            statement.setInt(1, allyId);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("could not dissolve clan: ", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public void storeClanWar(ClanWar war, boolean force) {
        if (force) {
            this.storeClanWar0(war);
        } else if (!this._clanWarUpdateCache.contains(war)) {
            this._clanWarUpdateCache.add(war);
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void storeClanWar0(ClanWar war) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO clan_wars (attacker_clan, attacked_clan, period, period_start_time, last_kill_time, attackers_kill_counter, opposers_kill_counter) VALUES(?,?,?,?,?,?,?)");
            statement.setInt(1, war.getAttackerClanId());
            statement.setInt(2, war.getAttackedClanId());
            statement.setString(3, war.getPeriod().toString());
            statement.setInt(4, war.getCurrentPeriodStartTime());
            statement.setInt(5, war.getLastKillTime());
            statement.setInt(6, war.getAttackersKillCounter());
            statement.setInt(7, war.getAttackedKillCounter());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("Error storing clan wars data: ", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void storeClanWars() {
        List<ClanWar> list = this._clanWarUpdateCache;
        synchronized (list) {
            for (ClanWar war : this._clanWarUpdateCache) {
                this.storeClanWar0(war);
            }
            this._clanWarUpdateCache.clear();
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void deleteClanWar(ClanWar war) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("DELETE FROM clan_wars WHERE attacker_clan=? AND attacked_clan=?");
            statement.setInt(1, war.getAttackerClanId());
            statement.setInt(2, war.getAttackedClanId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("Error removing clan wars data: ", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private void restoreClanWars() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT attacker_clan, attacked_clan, period, period_start_time, last_kill_time, attackers_kill_counter, opposers_kill_counter FROM clan_wars");
            rset = statement.executeQuery();
            while (rset.next()) {
                int attackerClanId = rset.getInt("attacker_clan");
                int opposinClanId = rset.getInt("attacked_clan");
                Clan attackerClan = this.getClan(attackerClanId);
                Clan opposinClan = this.getClan(opposinClanId);
                if (attackerClan != null && opposinClan != null) {
                    ClanWar.ClanWarPeriod period = ClanWar.ClanWarPeriod.valueOf(rset.getString("period"));
                    int periodStartTime = rset.getInt("period_start_time");
                    int lastKillTime = rset.getInt("last_kill_time");
                    int attackersKillCounter = rset.getInt("attackers_kill_counter");
                    int opposersKilLCounter = rset.getInt("opposers_kill_counter");
                    ClanWar war = new ClanWar(attackerClan, opposinClan, period, periodStartTime, lastKillTime, attackersKillCounter, opposersKilLCounter);
                    war.restore();
                    continue;
                }
                _log.warn(this.getClass().getSimpleName() + ": restorewars one of clans is null attacker_clan:" + attackerClanId + " attacked_clan:" + opposinClanId);
            }
        }
        catch (Exception e) {
            try {
                _log.error("Error restoring clan wars data: ", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        ThreadPoolManager.getInstance().scheduleAtFixedRate(() -> this.storeClanWars(), CLAN_WAR_STORE_DELAY, CLAN_WAR_STORE_DELAY);
    }

    public void checkClans() {
        long currentTime = System.currentTimeMillis();
        for (Clan clan : this.getClans()) {
            if (clan.getDisbandEndTime() <= 0L || clan.getDisbandEndTime() >= currentTime) continue;
            this.dissolveClan(clan);
        }
        for (ClanChangeLeaderRequest changeLeaderRequest : this._changeRequests.valueCollection()) {
            UnitMember newLeader;
            SubUnit subUnit;
            if (changeLeaderRequest.getTime() >= System.currentTimeMillis()) continue;
            Clan clan = this.getClan(changeLeaderRequest.getClanId());
            if (clan != null && (subUnit = clan.getSubUnit(0)) != null && (newLeader = subUnit.getUnitMember(changeLeaderRequest.getNewLeaderId())) != null) {
                subUnit.setLeader(newLeader, true);
            }
            this.cancelRequest(changeLeaderRequest, true);
        }
    }

    public void cancelRequest(ClanChangeLeaderRequest changeLeaderRequest, boolean done) {
        this._changeRequests.remove(changeLeaderRequest.getClanId());
        ClanLeaderRequestDAO.getInstance().delete(changeLeaderRequest);
        Log.add("Clan: " + changeLeaderRequest.getClanId() + ", newLeaderId: " + changeLeaderRequest.getNewLeaderId() + ", endTime: " + TimeUtils.toSimpleFormat(changeLeaderRequest.getTime()), done ? "ClanChangeLeaderRequestDone" : "ClanChangeLeaderRequestCancel");
    }

    public ClanChangeLeaderRequest getRequest(int clanId) {
        return (ClanChangeLeaderRequest)this._changeRequests.get(clanId);
    }

    public void addRequest(ClanChangeLeaderRequest request) {
        this._changeRequests.put(request.getClanId(), request);
        ClanLeaderRequestDAO.getInstance().insert(request);
        Log.add("Clan: " + request.getClanId() + ", newLeaderId: " + request.getNewLeaderId() + ", endTime: " + TimeUtils.toSimpleFormat(request.getTime()), "ClanChangeLeaderRequestAdd");
    }

    public void refreshClanAttendanceInfo() {
        for (Clan clan : this.getClans()) {
            clan.refreshAttendanceInfo();
        }
        ServerVariables.set(REFRESH_CLAN_ATTENDANCE_INFO_VAR, System.currentTimeMillis());
    }

    public void saveClanHuntingProgress() {
        for (Clan clan : this.getClans()) {
            clan.saveHuntingProgress();
        }
    }
}

