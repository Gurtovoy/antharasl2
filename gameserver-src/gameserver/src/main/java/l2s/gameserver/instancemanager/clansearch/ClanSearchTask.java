/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.instancemanager.clansearch;

import gnu.trove.list.TIntList;
import gnu.trove.list.array.TIntArrayList;
import gnu.trove.map.TIntLongMap;
import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntLongHashMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Statement;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.instancemanager.clansearch.ClanSearchQueries;
import l2s.gameserver.model.clansearch.ClanSearchClan;
import l2s.gameserver.model.clansearch.ClanSearchPlayer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ClanSearchTask
implements Runnable {
    private static final Logger _log = LoggerFactory.getLogger(ClanSearchTask.class);
    private final TIntObjectMap<ClanSearchClan> _newClans = new TIntObjectHashMap();
    private final TIntObjectMap<ClanSearchPlayer> _newWaiters = new TIntObjectHashMap();
    private final TIntObjectMap<ClanSearchPlayer> _newApplicants = new TIntObjectHashMap();
    private final TIntList _removalClans = new TIntArrayList();
    private final TIntList _removalWaiters = new TIntArrayList();
    private final TIntList _removalApplicants = new TIntArrayList();
    private final TIntLongMap _clanLocks = new TIntLongHashMap();
    private final TIntLongMap _applicantLocks = new TIntLongHashMap();
    private final TIntLongMap _waiterLocks = new TIntLongHashMap();

    public void scheduleClanForAddition(ClanSearchClan clan) {
        this._newClans.put(clan.getClanId(), clan);
    }

    public void scheduleWaiterForAddition(ClanSearchPlayer player) {
        this._newWaiters.put(player.getCharId(), player);
    }

    public void scheduleApplicantForAddition(ClanSearchPlayer player) {
        this._newApplicants.put(player.getCharId(), player);
    }

    public void scheduleClanForRemoval(int clanId) {
        this._removalClans.add(clanId);
    }

    public void scheduleWaiterForRemoval(int playerId) {
        this._removalWaiters.add(playerId);
    }

    public void scheduleApplicantForRemoval(int playerId) {
        this._removalApplicants.add(playerId);
    }

    
    @Override
    public void run() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            for (Object csClan : this._newClans.valueCollection()) {
                statement = con.prepareStatement("INSERT INTO `clan_search_registered_clans`(`clan_id`, `search_type`, `desc`, `timestamp`, `application`, `sub_unit`) VALUES (?, ?, ?, UNIX_TIMESTAMP(), ?, ?) ON DUPLICATE KEY UPDATE `search_type` = ?, `desc` = ?, `application` = ?, `sub_unit` = ?");
                statement.setInt(1, ((ClanSearchClan)csClan).getClanId());
                statement.setString(2, ((ClanSearchClan)csClan).getSearchType().name());
                statement.setString(3, ((ClanSearchClan)csClan).getDesc());
                statement.setInt(4, ((ClanSearchClan)csClan).getApplication());
                statement.setInt(5, ((ClanSearchClan)csClan).getSubUnit());
                statement.setString(6, ((ClanSearchClan)csClan).getSearchType().name());
                statement.setString(7, ((ClanSearchClan)csClan).getDesc());
                statement.setInt(8, ((ClanSearchClan)csClan).getApplication());
                statement.setInt(9, ((ClanSearchClan)csClan).getSubUnit());
                statement.executeUpdate();
                DbUtils.closeQuietly((Statement)statement);
            }
        }
        catch (SQLException e) {
            this.failed(e);
        }
        if (this._newWaiters.size() > 0) {
            int offset = 0;
            try {
                statement = con.prepareStatement(ClanSearchQueries.getAddWaitingPlayerQuery(this._newWaiters.size()));
                for (ClanSearchPlayer csPlayer : this._newWaiters.valueCollection()) {
                    statement.setInt(++offset, csPlayer.getCharId());
                    statement.setString(++offset, csPlayer.getName());
                    statement.setInt(++offset, csPlayer.getLevel());
                    statement.setInt(++offset, csPlayer.getClassId());
                    statement.setString(++offset, csPlayer.getSearchType().name());
                }
                statement.executeUpdate();
            }
            catch (SQLException e) {
                try {
                    this.failed(e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly(statement);
                    throw throwable;
                }
                DbUtils.closeQuietly((Statement)statement);
            }
            DbUtils.closeQuietly((Statement)statement);
        }
        if (this._newApplicants.size() > 0) {
            int offset = 0;
            try {
                statement = con.prepareStatement(ClanSearchQueries.getAddApplicantPlayerQuery(this._newApplicants.size()));
                for (ClanSearchPlayer csPlayer : this._newApplicants.valueCollection()) {
                    statement.setInt(++offset, csPlayer.getCharId());
                    statement.setInt(++offset, csPlayer.getPrefferedClanId());
                    statement.setString(++offset, csPlayer.getName());
                    statement.setInt(++offset, csPlayer.getLevel());
                    statement.setInt(++offset, csPlayer.getClassId());
                    statement.setString(++offset, csPlayer.getSearchType().name());
                    statement.setString(++offset, csPlayer.getDesc());
                }
                statement.executeUpdate();
            }
            catch (SQLException e) {
                this.failed(e);
            }
            finally {
                DbUtils.closeQuietly((Statement)statement);
            }
        }
        if (this._removalClans.size() > 0) {
            int offset = 0;
            try {
                statement = con.prepareStatement(ClanSearchQueries.getRemoveClanQuery(this._removalClans.size()));
                for (int clanId : this._removalClans.toArray()) {
                    statement.setInt(++offset, clanId);
                }
                statement.executeUpdate();
            }
            catch (SQLException e) {
                this.failed(e);
            }
            finally {
                DbUtils.closeQuietly((Statement)statement);
            }
            offset = 0;
            try {
                statement = con.prepareStatement(ClanSearchQueries.getRemoveClanApplicants(this._removalClans.size()));
                for (int clanId : this._removalClans.toArray()) {
                    statement.setInt(++offset, clanId);
                }
                statement.executeUpdate();
            }
            catch (SQLException e) {
                this.failed(e);
            }
            finally {
                DbUtils.closeQuietly((Statement)statement);
            }
        }
        if (this._removalWaiters.size() > 0) {
            int offset = 0;
            try {
                statement = con.prepareStatement(ClanSearchQueries.getRemoveWaiterQuery(this._removalWaiters.size()));
                for (int playerId : this._removalWaiters.toArray()) {
                    statement.setInt(++offset, playerId);
                }
                statement.executeUpdate();
            }
            catch (SQLException e) {
                this.failed(e);
            }
            finally {
                DbUtils.closeQuietly((Statement)statement);
            }
        }
        if (this._removalApplicants.size() > 0) {
            int offset = 0;
            try {
                statement = con.prepareStatement(ClanSearchQueries.getRemoveApplicantQuery(this._removalApplicants.size()));
                for (int charId : this._removalApplicants.toArray()) {
                    statement.setInt(++offset, charId);
                }
                statement.executeUpdate();
            }
            catch (SQLException e) {
                this.failed(e);
            }
            finally {
                DbUtils.closeQuietly((Statement)statement);
            }
        }
        try {
            statement = con.prepareStatement("DELETE FROM `clan_search_registered_clans` WHERE (UNIX_TIMESTAMP() - `timestamp`) >= 60 * 60 * 24 * 30");
            statement.executeUpdate();
        }
        catch (SQLException e) {
            this.failed(e);
        }
        finally {
            DbUtils.closeQuietly((Statement)statement);
        }
        try {
            statement = con.prepareStatement("DELETE FROM `clan_search_clan_applicants` WHERE (UNIX_TIMESTAMP() - `timestamp`) >= 60 * 60 * 24 * 30");
            statement.executeUpdate();
        }
        catch (SQLException e) {
            this.failed(e);
        }
        finally {
            DbUtils.closeQuietly((Statement)statement);
        }
        try {
            statement = con.prepareStatement("DELETE FROM `clan_search_waiting_players` WHERE (UNIX_TIMESTAMP() - `timestamp`) >= 60 * 60 * 24 * 30");
            statement.executeUpdate();
        }
        catch (SQLException e) {
            this.failed(e);
        }
        finally {
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        this._newClans.clear();
        this._newWaiters.clear();
        this._newApplicants.clear();
        this._removalClans.clear();
        this._removalApplicants.clear();
        this._removalWaiters.clear();
    }

    private void failed(Exception e) {
        _log.error(this.getClass().getSimpleName() + ": Failed to update database for clan search system.", (Throwable)e);
    }

    public void lockClan(int clanId, long lockTime) {
        this._clanLocks.put(clanId, System.currentTimeMillis() + lockTime);
        ThreadPoolManager.getInstance().schedule(() -> this._clanLocks.remove(clanId), lockTime);
    }

    public boolean isClanLocked(int clanId) {
        return this._clanLocks.containsKey(clanId);
    }

    public long getClanLockTime(int clanId) {
        return this._clanLocks.containsKey(clanId) ? Math.max(0L, System.currentTimeMillis() - this._clanLocks.get(clanId)) : 0L;
    }

    public void lockWaiter(int charId, long lockTime) {
        this._waiterLocks.put(charId, System.currentTimeMillis() + lockTime);
        ThreadPoolManager.getInstance().schedule(() -> this._waiterLocks.remove(charId), lockTime);
    }

    public boolean isWaiterLocked(int charId) {
        return this._waiterLocks.containsKey(charId);
    }

    public long getWaiterLockTime(int clanId) {
        return this._waiterLocks.containsKey(clanId) ? Math.max(0L, System.currentTimeMillis() - this._waiterLocks.get(clanId)) : 0L;
    }

    public void lockApplicant(int charId, long lockTime) {
        this._applicantLocks.put(charId, System.currentTimeMillis() + lockTime);
        ThreadPoolManager.getInstance().schedule(() -> this._applicantLocks.remove(charId), lockTime);
    }

    public boolean isApplicantLocked(int charId) {
        return this._applicantLocks.containsKey(charId);
    }

    public long getApplicantLockTime(int clanId) {
        return this._applicantLocks.containsKey(clanId) ? Math.max(0L, System.currentTimeMillis() - this._applicantLocks.get(clanId)) : 0L;
    }
}

