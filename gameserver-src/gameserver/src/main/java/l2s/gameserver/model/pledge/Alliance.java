/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.pledge;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.tables.ClanTable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Alliance {
    private static final Logger _log = LoggerFactory.getLogger(Alliance.class);
    private String _allyName;
    private int _allyId;
    private Clan _leader = null;
    private Map<Integer, Clan> _members = new ConcurrentHashMap<Integer, Clan>();
    private int _allyCrestId;
    private long _expelledMemberTime;
    public static long EXPELLED_MEMBER_PENALTY = 86400000L;

    public Alliance(int allyId) {
        this._allyId = allyId;
        this.restore();
    }

    public Alliance(int allyId, String allyName, Clan leader) {
        this._allyId = allyId;
        this._allyName = allyName;
        this.setLeader(leader);
    }

    public int getLeaderId() {
        return this._leader != null ? this._leader.getClanId() : 0;
    }

    public Clan getLeader() {
        return this._leader;
    }

    public void setLeader(Clan leader) {
        this._leader = leader;
        this._members.put(leader.getClanId(), leader);
    }

    public String getAllyLeaderName() {
        return this._leader != null ? this._leader.getLeaderName() : "";
    }

    public void addAllyMember(Clan member, boolean storeInDb) {
        this._members.put(member.getClanId(), member);
        if (storeInDb) {
            this.storeNewMemberInDatabase(member);
        }
    }

    public Clan getAllyMember(int id) {
        return this._members.get(id);
    }

    public void removeAllyMember(int id) {
        if (this._leader != null && this._leader.getClanId() == id) {
            return;
        }
        Clan exMember = this._members.remove(id);
        if (exMember == null) {
            _log.warn("Clan " + id + " not found in alliance while trying to remove");
            return;
        }
        this.removeMemberInDatabase(exMember);
    }

    public Clan[] getMembers() {
        return this._members.values().toArray(new Clan[this._members.size()]);
    }

    public int getMembersCount() {
        return this._members.size();
    }

    public int getAllyId() {
        return this._allyId;
    }

    public String getAllyName() {
        return this._allyName;
    }

    public void setAllyCrestId(int allyCrestId) {
        this._allyCrestId = allyCrestId;
    }

    public int getAllyCrestId() {
        return this._allyCrestId;
    }

    public void setAllyId(int allyId) {
        this._allyId = allyId;
    }

    public void setAllyName(String allyName) {
        this._allyName = allyName;
    }

    public boolean isMember(int id) {
        return this._members.containsKey(id);
    }

    public void setExpelledMemberTime(long time) {
        this._expelledMemberTime = time;
    }

    public long getExpelledMemberTime() {
        return this._expelledMemberTime;
    }

    public void setExpelledMember() {
        this._expelledMemberTime = System.currentTimeMillis();
        this.updateAllyInDB();
    }

    public boolean canInvite() {
        return System.currentTimeMillis() - this._expelledMemberTime >= EXPELLED_MEMBER_PENALTY;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void updateAllyInDB() {
        if (this.getLeaderId() == 0) {
            _log.warn("updateAllyInDB with empty LeaderId");
            Thread.dumpStack();
            return;
        }
        if (this.getAllyId() == 0) {
            _log.warn("updateAllyInDB with empty AllyId");
            Thread.dumpStack();
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE ally_data SET leader_id=?,expelled_member=? WHERE ally_id=?");
            statement.setInt(1, this.getLeaderId());
            statement.setLong(2, this.getExpelledMemberTime() / 1000L);
            statement.setInt(3, this.getAllyId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("error while updating ally '" + this.getAllyId() + "' data in db: " + e);
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
    public void store() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO ally_data (ally_id,ally_name,leader_id) values (?,?,?)");
            statement.setInt(1, this.getAllyId());
            statement.setString(2, this.getAllyName());
            statement.setInt(3, this.getLeaderId());
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE clan_data SET ally_id=? WHERE clan_id=?");
            statement.setInt(1, this.getAllyId());
            statement.setInt(2, this.getLeaderId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("error while saving new ally to db " + e);
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
    private void storeNewMemberInDatabase(Clan member) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET ally_id=? WHERE clan_id=?");
            statement.setInt(1, this.getAllyId());
            statement.setInt(2, member.getClanId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("error while saving new alliance member to db " + e);
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
    private void removeMemberInDatabase(Clan member) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET ally_id=0 WHERE clan_id=?");
            statement.setInt(1, member.getClanId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("error while removing ally member in db " + e);
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
    private void restore() {
        if (this.getAllyId() == 0) {
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT ally_name,leader_id FROM ally_data where ally_id=?");
            statement.setInt(1, this.getAllyId());
            rset = statement.executeQuery();
            if (rset.next()) {
                this.setAllyName(rset.getString("ally_name"));
                int leaderId = rset.getInt("leader_id");
                DbUtils.close((Statement)statement, (ResultSet)rset);
                statement = con.prepareStatement("SELECT clan_id FROM clan_data WHERE ally_id=?");
                statement.setInt(1, this.getAllyId());
                rset = statement.executeQuery();
                while (rset.next()) {
                    Clan member = ClanTable.getInstance().getClan(rset.getInt("clan_id"));
                    if (member == null) continue;
                    if (member.getClanId() == leaderId) {
                        this.setLeader(member);
                        continue;
                    }
                    this.addAllyMember(member, false);
                }
            }
            this.setAllyCrestId(CrestCache.getInstance().getAllyCrestId(this.getAllyId()));
        }
        catch (Exception e) {
            try {
                _log.warn("error while restoring ally");
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public void broadcastToOnlineMembers(L2GameServerPacket packet) {
        for (Clan member : this._members.values()) {
            if (member == null) continue;
            member.broadcastToOnlineMembers(packet);
        }
    }

    public void broadcastToOtherOnlineMembers(L2GameServerPacket packet, Player player) {
        for (Clan member : this._members.values()) {
            if (member == null) continue;
            member.broadcastToOtherOnlineMembers(packet, player);
        }
    }

    public String toString() {
        return this.getAllyName();
    }

    public boolean hasAllyCrest() {
        return this._allyCrestId > 0;
    }

    public void broadcastAllyStatus() {
        for (Clan member : this.getMembers()) {
            member.broadcastClanStatus(false, true, false);
        }
    }
}

