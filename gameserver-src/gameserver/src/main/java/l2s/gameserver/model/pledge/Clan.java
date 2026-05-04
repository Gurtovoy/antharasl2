/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.pledge;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import l2s.commons.collections.JoinedIterator;
import l2s.commons.dao.JdbcEntityState;
import l2s.commons.dbutils.DbUtils;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.Config;
import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.data.xml.holder.ResidenceHolder;
import l2s.gameserver.data.xml.holder.SkillAcquireHolder;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.database.mysql;
import l2s.gameserver.instancemanager.clansearch.ClanSearchManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.SkillLearn;
import l2s.gameserver.model.base.AcquireType;
import l2s.gameserver.model.base.PledgeAttendanceType;
import l2s.gameserver.model.entity.events.impl.ClanHallAuctionEvent;
import l2s.gameserver.model.entity.residence.Castle;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceType;
import l2s.gameserver.model.entity.residence.clanhall.AuctionClanHall;
import l2s.gameserver.model.items.ClanWarehouse;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.model.pledge.Alliance;
import l2s.gameserver.model.pledge.ClanChangeLeaderRequest;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.model.pledge.PledgeHuntingProgress;
import l2s.gameserver.model.pledge.RankPrivs;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExNeedToChangeName;
import l2s.gameserver.network.l2.s2c.ExPledgeBonusMarkReset;
import l2s.gameserver.network.l2.s2c.ExPledgeBonusUpdate;
import l2s.gameserver.network.l2.s2c.ExPledgeCount;
import l2s.gameserver.network.l2.s2c.JoinPledgePacket;
import l2s.gameserver.network.l2.s2c.PledgeReceiveSubPledgeCreated;
import l2s.gameserver.network.l2.s2c.PledgeShowInfoUpdatePacket;
import l2s.gameserver.network.l2.s2c.PledgeShowMemberListAddPacket;
import l2s.gameserver.network.l2.s2c.PledgeShowMemberListAllPacket;
import l2s.gameserver.network.l2.s2c.PledgeShowMemberListDeleteAllPacket;
import l2s.gameserver.network.l2.s2c.PledgeShowMemberListUpdatePacket;
import l2s.gameserver.network.l2.s2c.PledgeSkillListAddPacket;
import l2s.gameserver.network.l2.s2c.PledgeSkillListPacket;
import l2s.gameserver.network.l2.s2c.PledgeStatusChangedPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.tables.ClanTable;
import l2s.gameserver.utils.Log;
import l2s.gameserver.utils.PlayerUtils;
import l2s.gameserver.utils.PledgeBonusUtils;
import l2s.gameserver.utils.SiegeUtils;
import org.apache.commons.lang3.StringUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.maps.impl.CTreeIntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Clan
implements Iterable<UnitMember> {
    private static final Logger _log = LoggerFactory.getLogger(Clan.class);
    private final int _clanId;
    private int _allyId;
    private int _level = Config.START_CLAN_LEVEL;
    private int _hasCastle;
    private int _castleDefendCount;
    private int _hasHideout;
    private int _crestId;
    private int _crestLargeId;
    private long _expelledMemberTime;
    private long _leavedAllyTime;
    private long _dissolvedAllyTime;
    private long _disbandEndTime;
    private long _disbandPenaltyTime;
    private int _academyGraduatesCount;
    private final PledgeHuntingProgress _huntingProgress = new PledgeHuntingProgress(this);
    private int _yesterdayHuntingReward;
    private int _yesterdayAttendanceReward;
    public static long EXPELLED_MEMBER_PENALTY = (long)(Config.ALT_EXPELLED_MEMBER_PENALTY_TIME * 60 * 60) * 1000L;
    public static long LEAVED_ALLY_PENALTY = (long)(Config.ALT_LEAVED_ALLY_PENALTY_TIME * 60 * 60) * 1000L;
    public static long DISSOLVED_ALLY_PENALTY = (long)(Config.ALT_DISSOLVED_ALLY_PENALTY_TIME * 60 * 60) * 1000L;
    public static long DISBAND_PENALTY = 604800000L;
    public static SchedulingPattern DISBAND_TIME_PATTERN = new SchedulingPattern(Config.CLAN_DELETE_TIME);
    public static SchedulingPattern CHANGE_LEADER_TIME_PATTERN = new SchedulingPattern(Config.CLAN_CHANGE_LEADER_TIME);
    public static long JOIN_PLEDGE_PENALTY = 86400000L;
    public static long CREATE_PLEDGE_PENALTY = 864000000L;
    private final ClanWarehouse _warehouse;
    private int _whBonus = -1;
    private String _notice = null;
    private final IntObjectMap<ClanWar> _atWarWith = new CHashIntObjectMap();
    protected IntObjectMap<SkillEntry> _skills = new CTreeIntObjectMap();
    protected IntObjectMap<RankPrivs> _privs = new CTreeIntObjectMap();
    protected IntObjectMap<SubUnit> _subUnits = new CTreeIntObjectMap();
    private int _reputation = 0;
    public static final int CP_NOTHING = 0;
    public static final int CP_CL_INVITE_CLAN = 2;
    public static final int CP_CL_MANAGE_TITLES = 4;
    public static final int CP_CL_WAREHOUSE_SEARCH = 8;
    public static final int CP_CL_MANAGE_RANKS = 16;
    public static final int CP_CL_CLAN_WAR = 32;
    public static final int CP_CL_DISMISS = 64;
    public static final int CP_CL_EDIT_CREST = 128;
    public static final int CP_CL_APPRENTICE = 256;
    public static final int CP_CL_TROOPS_FAME = 512;
    public static final int CP_CH_ENTRY_EXIT = 2048;
    public static final int CP_CH_USE_FUNCTIONS = 4096;
    public static final int CP_CH_AUCTION = 8192;
    public static final int CP_CH_DISMISS = 16384;
    public static final int CP_CH_SET_FUNCTIONS = 32768;
    public static final int CP_CS_ENTRY_EXIT = 65536;
    public static final int CP_CS_MANOR_ADMIN = 131072;
    public static final int CP_CS_MANAGE_SIEGE = 262144;
    public static final int CP_CS_USE_FUNCTIONS = 524288;
    public static final int CP_CS_DISMISS = 0x100000;
    public static final int CP_CS_TAXES = 0x200000;
    public static final int CP_CS_MERCENARIES = 0x400000;
    public static final int CP_CS_SET_FUNCTIONS = 0x7FFFFE;
    public static final int CP_ALL = 0xFFFFFE;
    public static final int RANK_FIRST = 1;
    public static final int RANK_LAST = 9;
    public static final int SUBUNIT_NONE = -128;
    public static final int SUBUNIT_ACADEMY = -1;
    public static final int SUBUNIT_MAIN_CLAN = 0;
    public static final int SUBUNIT_ROYAL1 = 100;
    public static final int SUBUNIT_ROYAL2 = 200;
    public static final int SUBUNIT_KNIGHT1 = 1001;
    public static final int SUBUNIT_KNIGHT2 = 1002;
    public static final int SUBUNIT_KNIGHT3 = 2001;
    public static final int SUBUNIT_KNIGHT4 = 2002;
    private static final ClanReputationComparator REPUTATION_COMPARATOR = new ClanReputationComparator();
    private static final int REPUTATION_PLACES = 100;
    private static final SkillEntry CLAN_REBIRTH_SKILL = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 19009, 1);
    private String _desc;
    private String _title;
    private int arenaStage = 0;

    public Clan(int clanId) {
        this._clanId = clanId;
        this.initializePrivs();
        this._warehouse = new ClanWarehouse(this);
        this._warehouse.restore();
    }

    public int getClanId() {
        return this._clanId;
    }

    public int getLeaderId() {
        return this.getLeaderId(0);
    }

    public UnitMember getLeader() {
        return this.getLeader(0);
    }

    public String getLeaderName() {
        return this.getLeaderName(0);
    }

    public String getName() {
        return this.getUnitName(0);
    }

    public UnitMember getAnyMember(int id) {
        for (SubUnit unit : this.getAllSubUnits()) {
            UnitMember m = unit.getUnitMember(id);
            if (m == null) continue;
            return m;
        }
        return null;
    }

    public UnitMember getAnyMember(String name) {
        for (SubUnit unit : this.getAllSubUnits()) {
            UnitMember m = unit.getUnitMember(name);
            if (m == null) continue;
            return m;
        }
        return null;
    }

    public int getAllSize() {
        int size = 0;
        for (SubUnit unit : this.getAllSubUnits()) {
            size += unit.size();
        }
        return size;
    }

    public String getUnitName(int unitType) {
        if (unitType == -128 || !this._subUnits.containsKey(unitType)) {
            return "";
        }
        return this.getSubUnit(unitType).getName();
    }

    public String getLeaderName(int unitType) {
        if (unitType == -128 || !this._subUnits.containsKey(unitType)) {
            return "";
        }
        return this.getSubUnit(unitType).getLeaderName();
    }

    public int getLeaderId(int unitType) {
        if (unitType == -128 || !this._subUnits.containsKey(unitType)) {
            return 0;
        }
        return this.getSubUnit(unitType).getLeaderObjectId();
    }

    public UnitMember getLeader(int unitType) {
        if (unitType == -128 || !this._subUnits.containsKey(unitType)) {
            return null;
        }
        return this.getSubUnit(unitType).getLeader();
    }

    
    public void flush() {
        for (UnitMember member : this) {
            this.removeClanMember(member.getObjectId());
        }
        this._warehouse.writeLock();
        try {
            for (ItemInstance item : this._warehouse.getItems()) {
                this._warehouse.destroyItem(item);
            }
        }
        finally {
            this._warehouse.writeUnlock();
        }
        if (this._hasCastle != 0) {
            ResidenceHolder.getInstance().getResidence(Castle.class, this._hasCastle).changeOwner(null);
        }
    }

    public void removeClanMember(int id) {
        if (id == this.getLeaderId(0)) {
            return;
        }
        ClanChangeLeaderRequest changeLeaderRequest = ClanTable.getInstance().getRequest(this.getClanId());
        if (changeLeaderRequest != null && changeLeaderRequest.getNewLeaderId() == id) {
            ClanTable.getInstance().cancelRequest(changeLeaderRequest, false);
        }
        for (SubUnit unit : this.getAllSubUnits()) {
            UnitMember member = unit.getUnitMember(id);
            if (member == null) continue;
            this.onLeaveClan(member.getPlayer());
            this.removeClanMember(unit.getType(), id);
            break;
        }
    }

    public void removeClanMember(int subUnitId, int objectId) {
        SubUnit subUnit = this.getSubUnit(subUnitId);
        if (subUnit == null) {
            return;
        }
        subUnit.removeUnitMember(objectId);
    }

    public List<UnitMember> getAllMembers() {
        ArrayList<UnitMember> members = new ArrayList<UnitMember>();
        for (SubUnit unit : this.getAllSubUnits()) {
            members.addAll(unit.getUnitMembers());
        }
        return members;
    }

    public List<Player> getOnlineMembers(int excludePlayerId) {
        ArrayList<Player> result = new ArrayList<Player>();
        for (UnitMember temp : this) {
            if (!temp.isOnline() || temp.getObjectId() == excludePlayerId) continue;
            result.add(temp.getPlayer());
        }
        return result;
    }

    public List<Player> getOnlineMembers() {
        return this.getOnlineMembers(0);
    }

    public int getOnlineMembersCount(int excludePlayerId) {
        int result = 0;
        for (UnitMember temp : this) {
            if (temp == null || !temp.isOnline() || temp.getObjectId() == excludePlayerId) continue;
            ++result;
        }
        return result;
    }

    public int getOnlineMembersCount() {
        return this.getOnlineMembersCount(0);
    }

    public int getAllyId() {
        return this._allyId;
    }

    public int getLevel() {
        return this._level;
    }

    public int getCastle() {
        return this._hasCastle;
    }

    public int getHasHideout() {
        return this._hasHideout;
    }

    public int getResidenceId(ResidenceType r) {
        switch (r) {
            case CASTLE: {
                return this._hasCastle;
            }
            case CLANHALL: {
                return this._hasHideout;
            }
        }
        return 0;
    }

    public void setAllyId(int allyId) {
        this._allyId = allyId;
    }

    public void setHasCastle(int castle) {
        this._hasCastle = castle;
    }

    public void setHasHideout(int hasHideout) {
        this._hasHideout = hasHideout;
    }

    public void setLevel(int level) {
        this._level = level;
    }

    public boolean isAnyMember(int id) {
        for (SubUnit unit : this.getAllSubUnits()) {
            if (!unit.isUnitMember(id)) continue;
            return true;
        }
        return false;
    }

    
    private void updateClanAttendanceInfoInDB() {
        if (this.getClanId() == 0) {
            _log.warn("updateClanAttendanceInDB with empty ClanId");
            Thread.dumpStack();
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET hunting_progress=?,yesterday_hunting_reward=?,yesterday_attendance_reward=? WHERE clan_id=?");
            statement.setInt(1, this.getHuntingProgress());
            statement.setInt(2, this.getYesterdayHuntingReward());
            statement.setInt(3, this.getYesterdayAttendanceReward());
            statement.setInt(4, this.getClanId());
            statement.execute();
            this._huntingProgress.setJdbcState(JdbcEntityState.STORED);
        }
        catch (Exception e) {
            try {
                _log.warn("error while updating clan attendance '" + this.getClanId() + "' data in db");
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    private void updateClanScoreInDB() {
        if (this.getClanId() == 0) {
            _log.warn("updateClanScoreInDB with empty ClanId");
            Thread.dumpStack();
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET reputation_score=? WHERE clan_id=?");
            statement.setInt(1, this.getReputationScore());
            statement.setInt(2, this.getClanId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("error while updating clan reputation score '" + this.getClanId() + "' data in db");
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    public void updateClanInDB() {
        if (this.getLeaderId() == 0) {
            _log.warn("updateClanInDB with empty LeaderId");
            Thread.dumpStack();
            return;
        }
        if (this.getClanId() == 0) {
            _log.warn("updateClanInDB with empty ClanId");
            Thread.dumpStack();
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE clan_data SET ally_id=?,reputation_score=?,expelled_member=?,leaved_ally=?,dissolved_ally=?,clan_level=?,warehouse=?,academy_graduates=?,castle_defend_count=?,disband_end=?,disband_penalty=?,arena_stage=? WHERE clan_id=?");
            statement.setInt(1, this.getAllyId());
            statement.setInt(2, this.getReputationScore());
            statement.setLong(3, this.getExpelledMemberTime() / 1000L);
            statement.setLong(4, this.getLeavedAllyTime() / 1000L);
            statement.setLong(5, this.getDissolvedAllyTime() / 1000L);
            statement.setInt(6, this._level);
            statement.setInt(7, this.getWhBonus());
            statement.setInt(8, this.getAcademyGraduatesCount());
            statement.setInt(9, this.getCastleDefendCount());
            statement.setInt(10, (int)(this.getDisbandEndTime() / 1000L));
            statement.setInt(11, (int)(this.getDisbandPenaltyTime() / 1000L));
            statement.setInt(12, this.getArenaStage());
            statement.setInt(13, this.getClanId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("error while updating clan '" + this.getClanId() + "' data in db");
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    public void store() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("INSERT INTO clan_data (clan_id,clan_level,ally_id,expelled_member,leaved_ally,dissolved_ally,academy_graduates) values (?,?,?,?,?,?,?)");
            statement.setInt(1, this._clanId);
            statement.setInt(2, this._level);
            statement.setInt(3, this._allyId);
            statement.setLong(4, this.getExpelledMemberTime() / 1000L);
            statement.setLong(5, this.getLeavedAllyTime() / 1000L);
            statement.setLong(6, this.getDissolvedAllyTime() / 1000L);
            statement.setInt(7, this.getAcademyGraduatesCount());
            statement.execute();
            DbUtils.close((Statement)statement);
            SubUnit mainSubUnit = (SubUnit)this._subUnits.get(0);
            statement = con.prepareStatement("INSERT INTO clan_subpledges (clan_id, type, leader_id, name) VALUES (?,?,?,?)");
            statement.setInt(1, this._clanId);
            statement.setInt(2, mainSubUnit.getType());
            statement.setInt(3, mainSubUnit.getLeaderObjectId());
            statement.setString(4, mainSubUnit.getName());
            statement.execute();
            DbUtils.close((Statement)statement);
            statement = con.prepareStatement("UPDATE characters SET clanid=?,pledge_type=? WHERE obj_Id=?");
            statement.setInt(1, this.getClanId());
            statement.setInt(2, mainSubUnit.getType());
            statement.setInt(3, this.getLeaderId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("Exception: " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    
    public static Clan restore(int clanId) {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        Clan clan;
        block12: {
            Clan clan2 = null;
            if (clanId == 0) {
                return null;
            }
            clan = null;
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT clan_level,ally_id,reputation_score,expelled_member,leaved_ally,dissolved_ally,warehouse,academy_graduates,castle_defend_count,disband_end,disband_penalty,hunting_progress,yesterday_hunting_reward,yesterday_attendance_reward,arena_stage FROM clan_data WHERE clan_id=?");
                statement.setInt(1, clanId);
                rset = statement.executeQuery();
                if (rset.next()) {
                    clan = new Clan(clanId);
                    clan.setLevel(rset.getInt("clan_level"));
                    clan.setAllyId(rset.getInt("ally_id"));
                    clan._reputation = rset.getInt("reputation_score");
                    clan.setExpelledMemberTime(rset.getLong("expelled_member") * 1000L);
                    clan.setLeavedAllyTime(rset.getLong("leaved_ally") * 1000L);
                    clan.setDissolvedAllyTime(rset.getLong("dissolved_ally") * 1000L);
                    clan.setDisbandEndTime(rset.getLong("disband_end") * 1000L);
                    clan.setDisbandPenaltyTime(rset.getLong("disband_penalty") * 1000L);
                    clan.setWhBonus(rset.getInt("warehouse"));
                    clan.setCastleDefendCount(rset.getInt("castle_defend_count"));
                    clan.setAcademyGraduatesCount(rset.getInt("academy_graduates"));
                    clan.setHuntingProgress(rset.getInt("hunting_progress"));
                    clan.setYesterdayHuntingReward(rset.getInt("yesterday_hunting_reward"));
                    clan.setYesterdayAttendanceReward(rset.getInt("yesterday_attendance_reward"));
                    clan.setArenaStage(rset.getInt("arena_stage"));
                    DbUtils.close((Statement)statement, (ResultSet)rset);
                    statement = con.prepareStatement("SELECT id FROM castle WHERE owner_id=?");
                    statement.setInt(1, clanId);
                    rset = statement.executeQuery();
                    if (rset.next()) {
                        clan.setHasCastle(rset.getInt("id"));
                    }
                    DbUtils.close((Statement)statement, (ResultSet)rset);
                    statement = con.prepareStatement("SELECT id FROM clanhall WHERE owner_id=?");
                    statement.setInt(1, clanId);
                    rset = statement.executeQuery();
                    if (rset.next()) {
                        clan.setHasHideout(rset.getInt("id"));
                    }
                    if (clan.getHasHideout() == 0) {
                        DbUtils.close((Statement)statement, (ResultSet)rset);
                        statement = con.prepareStatement("SELECT id FROM instant_clanhall_owners WHERE owner_id=?");
                        statement.setInt(1, clanId);
                        rset = statement.executeQuery();
                        if (rset.next()) {
                            clan.setHasHideout(Residence.getInstantResidenceId(rset.getInt("id")));
                        }
                    }
                    break block12;
                }
                _log.warn("Clan " + clanId + " doesnt exists!");
                clan2 = null;
            }
            catch (Exception e) {
                try {
                    _log.error("Error while restoring clan!", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
            return clan2;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        if (clan == null) {
            _log.warn("Clan " + clanId + " does't exist");
            return null;
        }
        clan.restoreSkills();
        clan.restoreSubPledges();
        for (SubUnit unit : clan.getAllSubUnits()) {
            unit.restore();
            unit.restoreSkills();
        }
        clan.restoreRankPrivs();
        clan.setCrestId(CrestCache.getInstance().getPledgeCrestId(clanId));
        clan.setCrestLargeId(CrestCache.getInstance().getPledgeCrestLargeId(clanId));
        clan.checkSkills();
        return clan;
    }

    public void broadcastToOnlineMembers(IBroadcastPacket ... packets) {
        for (UnitMember member : this) {
            if (!member.isOnline()) continue;
            member.getPlayer().sendPacket(packets);
        }
    }

    public void broadcastToOtherOnlineMembers(IBroadcastPacket packet, Player player) {
        for (UnitMember member : this) {
            if (!member.isOnline() || member.getPlayer() == player) continue;
            member.getPlayer().sendPacket(packet);
        }
    }

    public String toString() {
        return this.getName();
    }

    public void setCrestId(int newcrest) {
        this._crestId = newcrest;
    }

    public int getCrestId() {
        return this._crestId;
    }

    public boolean hasCrest() {
        return this._crestId > 0;
    }

    public int getCrestLargeId() {
        return this._crestLargeId;
    }

    public void setCrestLargeId(int newcrest) {
        this._crestLargeId = newcrest;
    }

    public boolean hasCrestLarge() {
        return this._crestLargeId > 0;
    }

    public long getAdenaCount() {
        return this._warehouse.getCountOfAdena();
    }

    public ClanWarehouse getWarehouse() {
        return this._warehouse;
    }

    public boolean isAtWarWith(int clanId) {
        return this._atWarWith.containsKey(clanId);
    }

    public boolean isAtWarWith(Clan clan) {
        if (clan == null) {
            return false;
        }
        return this._atWarWith.containsKey(clan.getClanId());
    }

    public boolean isAtWar() {
        return !this._atWarWith.isEmpty();
    }

    public IntObjectMap<ClanWar> getWars() {
        return this._atWarWith;
    }

    public int getWarCount() {
        return this._atWarWith.size();
    }

    public void addWar(int clanId, ClanWar war) {
        this._atWarWith.put(clanId, war);
    }

    public void deleteWar(int clanId) {
        this._atWarWith.remove(clanId);
    }

    public ClanWar getWarWith(int clanId) {
        return (ClanWar)this._atWarWith.get(clanId);
    }

    public void broadcastClanStatus(boolean updateList, boolean needUserInfo, boolean relation) {
        List<IBroadcastPacket> listAll = updateList ? this.listAll() : null;
        PledgeShowInfoUpdatePacket update = new PledgeShowInfoUpdatePacket(this);
        for (UnitMember member : this) {
            if (!member.isOnline()) continue;
            if (updateList) {
                member.getPlayer().sendPacket((IBroadcastPacket)PledgeShowMemberListDeleteAllPacket.STATIC);
                member.getPlayer().sendPacket(listAll);
            }
            member.getPlayer().sendPacket((IBroadcastPacket)update);
            if (needUserInfo) {
                member.getPlayer().broadcastCharInfo();
            }
            if (!relation) continue;
            PlayerUtils.updateAttackableFlags(member.getPlayer());
        }
    }

    public Alliance getAlliance() {
        return this._allyId == 0 ? null : ClanTable.getInstance().getAlliance(this._allyId);
    }

    public void setExpelledMemberTime(long time) {
        this._expelledMemberTime = time;
    }

    public long getExpelledMemberTime() {
        return this._expelledMemberTime;
    }

    public void setExpelledMember() {
        this._expelledMemberTime = System.currentTimeMillis();
        this.updateClanInDB();
    }

    public void setLeavedAllyTime(long time) {
        this._leavedAllyTime = time;
    }

    public long getLeavedAllyTime() {
        return this._leavedAllyTime;
    }

    public void setLeavedAlly() {
        this._leavedAllyTime = System.currentTimeMillis();
        this.updateClanInDB();
    }

    public void setDissolvedAllyTime(long time) {
        this._dissolvedAllyTime = time;
    }

    public long getDissolvedAllyTime() {
        return this._dissolvedAllyTime;
    }

    public void setDissolvedAlly() {
        this._dissolvedAllyTime = System.currentTimeMillis();
        this.updateClanInDB();
    }

    public boolean canInvite() {
        return System.currentTimeMillis() - this._expelledMemberTime >= EXPELLED_MEMBER_PENALTY;
    }

    public boolean canJoinAlly() {
        return System.currentTimeMillis() - this._leavedAllyTime >= LEAVED_ALLY_PENALTY;
    }

    public boolean canCreateAlly() {
        return System.currentTimeMillis() - this._dissolvedAllyTime >= DISSOLVED_ALLY_PENALTY;
    }

    public boolean canDisband() {
        return System.currentTimeMillis() > this._disbandPenaltyTime;
    }

    public int getRank() {
        Clan[] clans = ClanTable.getInstance().getClans();
        Arrays.sort(clans, REPUTATION_COMPARATOR);
        int place = 1;
        for (int i = 0; i < clans.length; ++i) {
            if (i == 100) {
                return 0;
            }
            Clan clan = clans[i];
            if (clan != this) continue;
            return place + i;
        }
        return 0;
    }

    public int getReputationScore() {
        return this._reputation;
    }

    private void setReputationScore(int rep) {
        if (this._reputation >= 0 && rep < 0) {
            this.broadcastToOnlineMembers(SystemMsg.SINCE_THE_CLAN_REPUTATION_SCORE_HAS_DROPPED_TO_0_OR_LOWER_YOUR_CLAN_SKILLS_WILL_BE_DEACTIVATED);
            for (UnitMember member : this) {
                if (!member.isOnline() || member.getPlayer() == null) continue;
                this.disableSkills(member.getPlayer());
            }
        } else if (this._reputation < 0 && rep >= 0) {
            this.broadcastToOnlineMembers(SystemMsg.CLAN_SKILLS_WILL_NOW_BE_ACTIVATED_SINCE_THE_CLANS_REPUTATION_SCORE_IS_0_OR_HIGHER);
            for (UnitMember member : this) {
                if (!member.isOnline() || member.getPlayer() == null) continue;
                this.enableSkills(member.getPlayer());
            }
        }
        if (this._reputation != rep) {
            this._reputation = rep;
            this.broadcastToOnlineMembers(new PledgeShowInfoUpdatePacket(this));
        }
        this.updateClanScoreInDB();
    }

    public int incReputation(int inc, boolean rate, String source) {
        if (this._level < 3) {
            return 0;
        }
        if (rate && Math.abs(inc) <= Config.RATE_CLAN_REP_SCORE_MAX_AFFECTED) {
            inc = (int)Math.round((double)inc * Config.RATE_CLAN_REP_SCORE);
        }
        this.setReputationScore(this._reputation + inc);
        Log.add(this.getName() + "|" + inc + "|" + this._reputation + "|" + source, "clan_reputation");
        return inc;
    }

    
    private void restoreSkills() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT skill_id,skill_level FROM clan_skills WHERE clan_id=?");
            statement.setInt(1, this.getClanId());
            rset = statement.executeQuery();
            while (rset.next()) {
                int level;
                int id = rset.getInt("skill_id");
                SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, id, level = rset.getInt("skill_level"));
                if (skillEntry == null) continue;
                this._skills.put(skillEntry.getId(), skillEntry);
            }
        }
        catch (Exception e) {
            try {
                _log.warn("Could not restore clan skills: " + e);
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public Collection<SkillEntry> getSkills() {
        return this._skills.valueCollection();
    }

    
    public SkillEntry addSkill(SkillEntry newSkillEntry, boolean store) {
        SkillEntry oldSkillEntry = null;
        if (newSkillEntry != null) {
            oldSkillEntry = (SkillEntry)this._skills.put(newSkillEntry.getId(), newSkillEntry);
            if (store) {
                Connection con = null;
                PreparedStatement statement = null;
                try {
                    con = DatabaseFactory.getInstance().getConnection();
                    statement = con.prepareStatement("REPLACE INTO clan_skills (clan_id,skill_id,skill_level) VALUES (?,?,?)");
                    statement.setInt(1, this.getClanId());
                    statement.setInt(2, newSkillEntry.getId());
                    statement.setInt(3, newSkillEntry.getLevel());
                    statement.execute();
                }
                catch (Exception e) {
                    try {
                        _log.warn("Error could not store char skills: " + e);
                        _log.error("", (Throwable)e);
                    }
                    catch (Throwable throwable) {
                        DbUtils.closeQuietly((Connection)con, statement);
                        throw throwable;
                    }
                    DbUtils.closeQuietly((Connection)con, (Statement)statement);
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
            }
            PledgeSkillListAddPacket p = new PledgeSkillListAddPacket(newSkillEntry.getId(), newSkillEntry.getLevel());
            PledgeSkillListPacket p2 = new PledgeSkillListPacket(this);
            for (UnitMember temp : this) {
                Player player;
                if (!temp.isOnline() || (player = temp.getPlayer()) == null) continue;
                this.addSkill(player, newSkillEntry);
                player.sendPacket(p, p2);
                player.sendSkillList();
            }
        }
        return oldSkillEntry;
    }

    public void addSkillsQuietly(Player player) {
        for (SkillEntry skillEntry : this._skills.valueCollection()) {
            this.addSkill(player, skillEntry);
        }
        SubUnit subUnit = this.getSubUnit(player.getPledgeType());
        if (subUnit != null) {
            subUnit.addSkillsQuietly(player);
        }
        if (player.isClanLeader() && this.getLevel() >= 3) {
            SiegeUtils.addSiegeSkills(player);
        }
    }

    public void enableSkills(Player player) {
        if (player.isInOlympiadMode()) {
            return;
        }
        for (SkillEntry skillEntry : this._skills.valueCollection()) {
            Skill skill = skillEntry.getTemplate();
            if (skill.getMinPledgeRank().ordinal() > player.getPledgeRank().ordinal() || skill.clanLeaderOnly() && (!skill.clanLeaderOnly() || !player.isClanLeader())) continue;
            player.removeUnActiveSkill(skill);
        }
        SubUnit subUnit = this.getSubUnit(player.getPledgeType());
        if (subUnit != null) {
            subUnit.enableSkills(player);
        }
    }

    public void disableSkills(Player player) {
        for (SkillEntry skillEntry : this._skills.valueCollection()) {
            player.addUnActiveSkill(skillEntry.getTemplate());
        }
        SubUnit subUnit = this.getSubUnit(player.getPledgeType());
        if (subUnit != null) {
            subUnit.disableSkills(player);
        }
    }

    private void addSkill(Player player, SkillEntry skillEntry) {
        Skill skill = skillEntry.getTemplate();
        if (skill.getMinPledgeRank().ordinal() <= player.getPledgeRank().ordinal() && (!skill.clanLeaderOnly() || skill.clanLeaderOnly() && player.isClanLeader())) {
            player.addSkill(skillEntry, false);
            if (this._reputation < 0 || player.isInOlympiadMode()) {
                player.addUnActiveSkill(skill);
            }
        }
    }

    
    public void removeSkill(int skill, boolean store) {
        if (this._skills.remove(skill) == null) {
            return;
        }
        if (store) {
            Connection con = null;
            PreparedStatement statement = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("DELETE FROM clan_skills WHERE skill_id=? AND clan_id=?");
                statement.setInt(1, skill);
                statement.setInt(2, this.getClanId());
                statement.execute();
            }
            catch (Exception e) {
                try {
                    _log.warn("Error could not delete char skills: " + e);
                    _log.error("", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        PledgeSkillListAddPacket p = new PledgeSkillListAddPacket(skill, 0);
        for (UnitMember temp : this) {
            Player player = temp.getPlayer();
            if (player == null || !player.isOnline()) continue;
            player.removeSkillById(skill);
            player.sendPacket((IBroadcastPacket)p);
            player.sendSkillList();
        }
    }

    public void broadcastSkillListToOnlineMembers() {
        for (UnitMember temp : this) {
            Player player = temp.getPlayer();
            if (player == null || !player.isOnline()) continue;
            player.sendPacket((IBroadcastPacket)new PledgeSkillListPacket(this));
            player.sendSkillList();
        }
    }

    public static boolean isAcademy(int pledgeType) {
        return pledgeType == -1;
    }

    public static boolean isRoyalGuard(int pledgeType) {
        return pledgeType == 100 || pledgeType == 200;
    }

    public static boolean isOrderOfKnights(int pledgeType) {
        return pledgeType == 1001 || pledgeType == 1002 || pledgeType == 2001 || pledgeType == 2002;
    }

    public int getAffiliationRank(int pledgeType) {
        if (Clan.isAcademy(pledgeType)) {
            return 9;
        }
        if (Clan.isOrderOfKnights(pledgeType)) {
            return 8;
        }
        if (Clan.isRoyalGuard(pledgeType)) {
            return 7;
        }
        return 6;
    }

    public final SubUnit getSubUnit(int pledgeType) {
        return (SubUnit)this._subUnits.get(pledgeType);
    }

    
    public final void addSubUnit(SubUnit sp, boolean updateDb) {
        this._subUnits.put(sp.getType(), sp);
        if (updateDb) {
            this.broadcastToOnlineMembers(new PledgeReceiveSubPledgeCreated(sp));
            Connection con = null;
            PreparedStatement statement = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("INSERT INTO `clan_subpledges` (clan_id,type,leader_id,name) VALUES (?,?,?,?)");
                statement.setInt(1, this.getClanId());
                statement.setInt(2, sp.getType());
                statement.setInt(3, sp.getLeaderObjectId());
                statement.setString(4, sp.getName());
                statement.execute();
            }
            catch (Exception e) {
                try {
                    _log.warn("Could not store clan Sub pledges: " + e);
                    _log.error("", (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement);
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
    }

    public int createSubPledge(Player player, int pledgeType, UnitMember leader, String name) {
        int temp = pledgeType;
        if ((pledgeType = this.getAvailablePledgeTypes(pledgeType)) == -128) {
            return -128;
        }
        switch (pledgeType) {
            case -1: {
                break;
            }
            case 100: 
            case 200: {
                if (this.getReputationScore() < 5000) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_REPUTATION_SCORE_IS_TOO_LOW);
                    return -128;
                }
                this.incReputation(-5000, false, "SubunitCreate");
                break;
            }
            case 1001: 
            case 1002: 
            case 2001: 
            case 2002: {
                if (this.getReputationScore() < 10000) {
                    player.sendPacket((IBroadcastPacket)SystemMsg.THE_CLAN_REPUTATION_SCORE_IS_TOO_LOW);
                    return -128;
                }
                this.incReputation(-10000, false, "SubunitCreate");
            }
        }
        this.addSubUnit(new SubUnit(this, pledgeType, leader, name, false), true);
        return pledgeType;
    }

    public int getAvailablePledgeTypes(int pledgeType) {
        if (pledgeType == 0) {
            return -128;
        }
        if (this._subUnits.get(pledgeType) != null) {
            switch (pledgeType) {
                case -1: {
                    return -128;
                }
                case 100: {
                    pledgeType = this.getAvailablePledgeTypes(200);
                    break;
                }
                case 200: {
                    return -128;
                }
                case 1001: {
                    pledgeType = this.getAvailablePledgeTypes(1002);
                    break;
                }
                case 1002: {
                    pledgeType = this.getAvailablePledgeTypes(2001);
                    break;
                }
                case 2001: {
                    pledgeType = this.getAvailablePledgeTypes(2002);
                    break;
                }
                case 2002: {
                    return -128;
                }
            }
        }
        return pledgeType;
    }

    
    private void restoreSubPledges() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT * FROM clan_subpledges WHERE clan_id=?");
            statement.setInt(1, this.getClanId());
            rset = statement.executeQuery();
            while (rset.next()) {
                int type = rset.getInt("type");
                int leaderId = rset.getInt("leader_id");
                String name = rset.getString("name");
                SubUnit pledge = new SubUnit(this, type, leaderId, name);
                pledge.setUpgraded(rset.getBoolean("upgraded"), false);
                this.addSubUnit(pledge, false);
            }
        }
        catch (Exception e) {
            try {
                _log.warn("Could not restore clan SubPledges: " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public int getClanMembersLimit() {
        int limit = 0;
        for (SubUnit su : this.getAllSubUnits()) {
            limit += this.getSubPledgeLimit(su.getType());
        }
        return limit;
    }

    public int getSubPledgeLimit(int pledgeType) {
        int limit = 0;
        SubUnit subUnit = (SubUnit)this._subUnits.get(pledgeType);
        block0 : switch (pledgeType) {
            case 0: {
                switch (this._level) {
                    case 0: {
                        limit = 10;
                        break block0;
                    }
                    case 1: {
                        limit = 15;
                        break block0;
                    }
                    case 2: {
                        limit = 20;
                        break block0;
                    }
                    case 3: {
                        limit = 30;
                        break block0;
                    }
                }
                limit = 40;
                break;
            }
            case -1: {
                limit = 20;
                break;
            }
            case 100: 
            case 200: {
                if (subUnit != null && subUnit.isUpgraded()) {
                    limit = 30;
                    break;
                }
                limit = 20;
                break;
            }
            case 1001: 
            case 1002: {
                if (subUnit != null && subUnit.isUpgraded()) {
                    limit = 25;
                    break;
                }
                limit = 10;
                break;
            }
            case 2001: 
            case 2002: {
                limit = subUnit != null && subUnit.isUpgraded() ? 25 : 10;
            }
        }
        return limit;
    }

    public int getUnitMembersSize(int pledgeType) {
        if (pledgeType == -128 || !this._subUnits.containsKey(pledgeType)) {
            return 0;
        }
        return this.getSubUnit(pledgeType).size();
    }

    
    private void restoreRankPrivs() {
        if (this._privs == null) {
            this.initializePrivs();
        }
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT `privilleges`, `rank` FROM `clan_privs` WHERE `clan_id`=?");
            statement.setInt(1, this.getClanId());
            rset = statement.executeQuery();
            while (rset.next()) {
                int rank = rset.getInt("rank");
                int privileges = rset.getInt("privilleges");
                RankPrivs p = (RankPrivs)this._privs.get(rank);
                if (p != null) {
                    p.setPrivs(privileges);
                    continue;
                }
                _log.warn("Invalid rank value (" + rank + "), please check clan_privs table");
            }
        }
        catch (Exception e) {
            try {
                _log.warn("Could not restore clan privs by rank: " + e);
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public void initializePrivs() {
        for (int i = 1; i <= 9; ++i) {
            this._privs.put(i, new RankPrivs(i, 0, 0));
        }
    }

    public void updatePrivsForRank(int rank) {
        for (UnitMember member : this) {
            if (!member.isOnline() || member.getPlayer() == null || member.getPlayer().getPowerGrade() != rank || member.getPlayer().isClanLeader()) continue;
            member.getPlayer().sendUserInfo();
        }
    }

    public RankPrivs getRankPrivs(int rank) {
        if (rank < 1 || rank > 9) {
            _log.warn("Requested invalid rank value: " + rank);
            Thread.dumpStack();
            return null;
        }
        if (this._privs.get(rank) == null) {
            _log.warn("Request of rank before init: " + rank);
            Thread.dumpStack();
            this.setRankPrivs(rank, 0);
        }
        return (RankPrivs)this._privs.get(rank);
    }

    public int countMembersByRank(int rank) {
        int ret = 0;
        for (UnitMember m : this) {
            if (m.getPowerGrade() != rank) continue;
            ++ret;
        }
        return ret;
    }

    
    public void setRankPrivs(int rank, int privs) {
        if (rank < 1 || rank > 9) {
            _log.warn("Requested set of invalid rank value: " + rank);
            Thread.dumpStack();
            return;
        }
        if (this._privs.get(rank) != null) {
            ((RankPrivs)this._privs.get(rank)).setPrivs(privs);
        } else {
            this._privs.put(rank, new RankPrivs(rank, this.countMembersByRank(rank), privs));
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("REPLACE INTO clan_privs (`clan_id`,`rank`,`privilleges`) VALUES (?,?,?)");
            statement.setInt(1, this.getClanId());
            statement.setInt(2, rank);
            statement.setInt(3, privs);
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.warn("Could not store clan privs for rank: " + e);
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
    }

    public final RankPrivs[] getAllRankPrivs() {
        if (this._privs == null) {
            return new RankPrivs[0];
        }
        return (RankPrivs[])this._privs.values(new RankPrivs[this._privs.size()]);
    }

    public int getWhBonus() {
        return this._whBonus;
    }

    public void setWhBonus(int i) {
        if (this._whBonus != -1) {
            mysql.set("UPDATE `clan_data` SET `warehouse`=? WHERE `clan_id`=?", i, this.getClanId());
        }
        this._whBonus = i;
    }

    public final Collection<SubUnit> getAllSubUnits() {
        return this._subUnits.valueCollection();
    }

    public List<IBroadcastPacket> listAll() {
        ArrayList<IBroadcastPacket> p = new ArrayList<IBroadcastPacket>(this._subUnits.size());
        for (SubUnit unit : this.getAllSubUnits()) {
            p.add(new PledgeShowMemberListAllPacket(this, unit));
        }
        return p;
    }

    public String getNotice() {
        return this._notice;
    }

    public void setNotice(String notice) {
        this._notice = notice;
    }

    public int getSkillLevel(int id, int def) {
        SkillEntry skillEntry = (SkillEntry)this._skills.get(id);
        return skillEntry == null ? def : skillEntry.getLevel();
    }

    public int getSkillLevel(int id) {
        return this.getSkillLevel(id, -1);
    }

    public String getDesc() {
        return this._desc;
    }

    public void setDesc(String desc) {
        this._desc = desc;
    }

    public String getTitle() {
        return this._title;
    }

    public void setTitle(String title) {
        this._title = title;
    }

    @Override
    public Iterator<UnitMember> iterator() {
        ArrayList<Iterator<UnitMember>> iterators = new ArrayList<Iterator<UnitMember>>(this._subUnits.size());
        for (SubUnit subUnit : this._subUnits.valueCollection()) {
            iterators.add(subUnit.getUnitMembers().iterator());
        }
        return new JoinedIterator(iterators);
    }

    public int getAcademyGraduatesCount() {
        return this._academyGraduatesCount;
    }

    public void setAcademyGraduatesCount(int val) {
        this._academyGraduatesCount = val;
    }

    public void loginClanCond(Player player, boolean login) {
        if (login) {
            String changedOldName;
            SubUnit subUnit = player.getSubUnit();
            if (subUnit == null) {
                return;
            }
            UnitMember member = subUnit.getUnitMember(player.getObjectId());
            if (member == null) {
                return;
            }
            member.setPlayerInstance(player, false);
            int sponsor = player.getSponsor();
            int apprentice = player.getApprentice();
            Object msg = new SystemMessagePacket(SystemMsg.CLAN_MEMBER_S1_HAS_LOGGED_INTO_GAME).addName(player);
            PledgeShowMemberListUpdatePacket memberUpdate = new PledgeShowMemberListUpdatePacket(player);
            for (Player clanMember : this.getOnlineMembers(player.getObjectId())) {
                clanMember.sendPacket((IBroadcastPacket)memberUpdate);
                if (clanMember.getObjectId() == sponsor) {
                    clanMember.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUR_APPRENTICE_C1_HAS_LOGGED_OUT).addName(player));
                    continue;
                }
                if (clanMember.getObjectId() == apprentice) {
                    clanMember.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOUR_SPONSOR_C1_HAS_LOGGED_IN).addName(player));
                    continue;
                }
                clanMember.sendPacket((IBroadcastPacket)msg);
            }
            if (player.isClanLeader()) {
                AuctionClanHall clanHall;
                if (this.getLevel() >= 5) {
                    for (Player clanMember : this.getOnlineMembers()) {
                        CLAN_REBIRTH_SKILL.getEffects(player, clanMember);
                    }
                }
                AuctionClanHall auctionClanHall = clanHall = this.getHasHideout() != 0 ? ResidenceHolder.getInstance().getResidence(AuctionClanHall.class, this.getHasHideout()) : null;
                if (clanHall != null && clanHall.getAuctionLength() == 0 && clanHall.getSiegeEvent().getClass() == ClanHallAuctionEvent.class && this.getWarehouse().getCountOf(clanHall.getFeeItemId()) < clanHall.getRentalFee()) {
                    player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.PAYMENT_FOR_YOUR_CLAN_HALL_HAS_NOT_BEEN_MADE_PLEASE_ME_PAYMENT_TO_YOUR_CLAN_WAREHOUSE_BY_S1_TOMORROW).addLong(clanHall.getRentalFee()));
                }
            } else if (this.getLevel() >= 5 && this.getLeader().isOnline()) {
                CLAN_REBIRTH_SKILL.getEffects(this.getLeader().getPlayer(), player);
            }
            if (subUnit.getLeaderObjectId() == player.getObjectId() && (changedOldName = player.getVar("changed_old_pledge_name")) != null && !StringUtils.isEmpty((CharSequence)changedOldName)) {
                player.sendPacket((IBroadcastPacket)new ExNeedToChangeName(1, 0, changedOldName));
            }
        } else if (player.isClanLeader()) {
            for (Player clanMember : this.getOnlineMembers(player.getObjectId())) {
                clanMember.getAbnormalList().stop(CLAN_REBIRTH_SKILL, false);
            }
        }
        ExPledgeCount pledgeCount = new ExPledgeCount(this.getOnlineMembersCount(login ? 0 : player.getObjectId()));
        for (Player clanMember : this.getOnlineMembers(login ? 0 : player.getObjectId())) {
            clanMember.sendPacket((IBroadcastPacket)pledgeCount);
        }
    }

    public void onLevelChange(int oldLevel, int newLevel) {
        if (this.getLeader().isOnline()) {
            Player clanLeader = this.getLeader().getPlayer();
            if (oldLevel < 3 && newLevel >= 3) {
                SiegeUtils.addSiegeSkills(clanLeader);
            }
            if (newLevel == 3) {
                clanLeader.sendPacket((IBroadcastPacket)SystemMsg.NOW_THAT_YOUR_CLAN_LEVEL_IS_ABOVE_LEVEL_5_IT_CAN_ACCUMULATE_CLAN_REPUTATION_POINTS);
            }
            if (newLevel > oldLevel && oldLevel < 5 && newLevel >= 5) {
                for (Player clanMember : this.getOnlineMembers()) {
                    CLAN_REBIRTH_SKILL.getEffects(clanLeader, clanMember);
                }
            } else if (newLevel < 5 && oldLevel >= 5) {
                for (Player member : this.getOnlineMembers()) {
                    member.getAbnormalList().stop(CLAN_REBIRTH_SKILL, false);
                }
            }
        }
        this.checkSkills();
        PledgeShowInfoUpdatePacket pu = new PledgeShowInfoUpdatePacket(this);
        PledgeStatusChangedPacket ps = new PledgeStatusChangedPacket(this);
        for (Player member : this.getOnlineMembers()) {
            member.updatePledgeRank();
            member.sendPacket(SystemMsg.YOUR_CLANS_LEVEL_HAS_INCREASED, pu, ps);
            member.broadcastUserInfo(true);
        }
    }

    public void onEnterClan(Player player) {
        if (this.getLevel() >= 5 && this.getLeader().isOnline()) {
            CLAN_REBIRTH_SKILL.getEffects(this.getLeader().getPlayer(), player);
        }
        ExPledgeCount pledgeCount = new ExPledgeCount(this.getOnlineMembersCount());
        for (Player clanMember : this.getOnlineMembers()) {
            clanMember.sendPacket((IBroadcastPacket)pledgeCount);
        }
        ClanSearchManager.getInstance().removeApplicant(this.getClanId(), player.getObjectId());
        player.getListeners().onClanInvite();
    }

    public void onLeaveClan(Player player) {
        int playerId = 0;
        if (player != null) {
            playerId = player.getObjectId();
            player.sendPacket((IBroadcastPacket)new ExPledgeCount(0));
            player.getAbnormalList().stop(CLAN_REBIRTH_SKILL, false);
        }
        ExPledgeCount pledgeCount = new ExPledgeCount(this.getOnlineMembersCount(playerId));
        for (Player clanMember : this.getOnlineMembers(playerId)) {
            clanMember.sendPacket((IBroadcastPacket)pledgeCount);
        }
    }

    public boolean isSpecialAbnormal(Skill skill) {
        return this.getLevel() >= 5 && this.getLeader().isOnline() && CLAN_REBIRTH_SKILL.getId() == skill.getId();
    }

    public boolean checkJoinPledgeCondition(Player player, int pledgeType) {
        if (pledgeType == -1) {
            if (player.isAcademyGraduated()) {
                return false;
            }
            if (player.getLevel() >= 85) {
                return false;
            }
        }
        return true;
    }

    public boolean joinInPledge(Player player, int pledgeType) {
        player.sendPacket((IBroadcastPacket)new JoinPledgePacket(this.getClanId()));
        SubUnit subUnit = this.getSubUnit(pledgeType);
        if (subUnit == null) {
            return false;
        }
        UnitMember member = new UnitMember(this, player.getName(), player.getTitle(), player.getLevel(), player.getClassId().getId(), player.getObjectId(), pledgeType, player.getPowerGrade(), player.getApprentice(), player.getSex().ordinal(), -128, PledgeAttendanceType.NEW_RECRUIT);
        subUnit.addUnitMember(member);
        player.setPledgeType(pledgeType);
        player.setClan(this);
        member.setPlayerInstance(player, false);
        if (pledgeType == -1) {
            player.setLvlJoinedAcademy(player.getLevel());
        }
        member.setPowerGrade(this.getAffiliationRank(player.getPledgeType()));
        this.broadcastToOtherOnlineMembers(new PledgeShowMemberListAddPacket(member), player);
        this.broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.S1_HAS_JOINED_THE_CLAN).addString(player.getName()), new PledgeShowInfoUpdatePacket(this)});
        player.sendPacket((IBroadcastPacket)SystemMsg.ENTERED_THE_CLAN);
        player.sendPacket(player.getClan().listAll());
        player.setLeaveClanTime(0L);
        player.updatePledgeRank();
        this.addSkillsQuietly(player);
        player.sendPacket((IBroadcastPacket)new PledgeSkillListPacket(this));
        player.sendSkillList();
        EventHolder.getInstance().findEvent(player);
        player.broadcastCharInfo();
        this.onEnterClan(player);
        player.store(false);
        return true;
    }

    public int getCastleDefendCount() {
        return this._castleDefendCount;
    }

    public void setCastleDefendCount(int castleDefendCount) {
        this._castleDefendCount = castleDefendCount;
    }

    public boolean isPlacedForDisband() {
        return this._disbandEndTime != 0L;
    }

    public void placeForDisband() {
        this._disbandEndTime = DISBAND_TIME_PATTERN.next(System.currentTimeMillis());
        this.updateClanInDB();
    }

    public void unPlaceDisband() {
        this._disbandEndTime = 0L;
        this._disbandPenaltyTime = System.currentTimeMillis() + DISBAND_PENALTY;
        this.updateClanInDB();
    }

    public long getDisbandEndTime() {
        return this._disbandEndTime;
    }

    public void setDisbandEndTime(long disbandEndTime) {
        this._disbandEndTime = disbandEndTime;
    }

    public long getDisbandPenaltyTime() {
        return this._disbandPenaltyTime;
    }

    public void setDisbandPenaltyTime(long disbandPenaltyTime) {
        this._disbandPenaltyTime = disbandPenaltyTime;
    }

    public int getAttendanceProgress() {
        int result = 0;
        for (UnitMember member : this.getAllMembers()) {
            if (member.getAttendanceType() != PledgeAttendanceType.ACQUIRED) continue;
            ++result;
        }
        return result;
    }

    public int getHuntingProgress() {
        return this._huntingProgress.getValue();
    }

    public void setHuntingProgress(int value) {
        this._huntingProgress.setValue(value);
    }

    public void addHuntingProgress(int value) {
        if (value <= 0) {
            return;
        }
        int oldLevel = PledgeBonusUtils.getHuntingProgressLevel(this.getHuntingProgress());
        this._huntingProgress.setValue(this._huntingProgress.getValue() + value);
        this._huntingProgress.setJdbcState(JdbcEntityState.UPDATED);
        this.broadcastToOnlineMembers(new ExPledgeBonusUpdate(ExPledgeBonusUpdate.BonusType.HUNTING, this.getHuntingProgress()));
        int newLevel = PledgeBonusUtils.getHuntingProgressLevel(this.getHuntingProgress());
        if (newLevel > oldLevel) {
            this.broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.YOUR_CLAN_HAS_ACHIEVED_HUNTING_BONUS_LV_S1).addInteger(newLevel)});
        }
    }

    public int getYesterdayHuntingReward() {
        return this._yesterdayHuntingReward;
    }

    public void setYesterdayHuntingReward(int value) {
        this._yesterdayHuntingReward = value;
    }

    public int getYesterdayAttendanceReward() {
        return this._yesterdayAttendanceReward;
    }

    public void setYesterdayAttendanceReward(int value) {
        this._yesterdayAttendanceReward = value;
    }

    public void refreshAttendanceInfo() {
        this.setYesterdayAttendanceReward(PledgeBonusUtils.getAttendanceProgressLevel(this.getAttendanceProgress()));
        this.setYesterdayHuntingReward(PledgeBonusUtils.getHuntingProgressLevel(this.getHuntingProgress()));
        for (UnitMember member : this.getAllMembers()) {
            if (member.getAttendanceType() == PledgeAttendanceType.NEW_RECRUIT) {
                if (member.isOnline()) {
                    member.setAttendanceType(PledgeAttendanceType.ACQUIRED);
                } else {
                    member.setAttendanceType(PledgeAttendanceType.NOT_ACQUIRED);
                }
                this.broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(member));
                continue;
            }
            if (member.isOnline()) continue;
            member.setAttendanceType(PledgeAttendanceType.NOT_ACQUIRED);
            this.broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(member));
        }
        this.setHuntingProgress(0);
        this.updateClanAttendanceInfoInDB();
        this.broadcastToOnlineMembers(ExPledgeBonusMarkReset.STATIC);
        this.broadcastToOnlineMembers(new ExPledgeBonusUpdate(ExPledgeBonusUpdate.BonusType.ATTENDANCE, this.getAttendanceProgress()));
        this.broadcastToOnlineMembers(new ExPledgeBonusUpdate(ExPledgeBonusUpdate.BonusType.HUNTING, this.getHuntingProgress()));
    }

    public void saveHuntingProgress() {
        this._huntingProgress.save();
    }

    public void checkSkills() {
        SkillEntry skillEntry;
        for (SkillEntry skill : this.getSkills()) {
            SkillLearn sl = SkillAcquireHolder.getInstance().getSkillLearn(null, skill.getId(), skill.getLevel(), AcquireType.CLAN);
            if (sl == null || sl.getMinLevel() <= this.getLevel()) continue;
            this.removeSkill(skill.getId(), true);
        }
        ArrayList<SkillLearn> skillLearns = new ArrayList<SkillLearn>(SkillAcquireHolder.getInstance().getAvailableNextLevelsSkills(null, null, AcquireType.CLAN, this, null));
        Collections.sort(skillLearns);
        Collections.reverse(skillLearns);
        HashIntObjectMap skillsToLearnMap = new HashIntObjectMap();
        for (SkillLearn sl : skillLearns) {
            if (!sl.isFreeAutoGet(AcquireType.CLAN)) {
                skillsToLearnMap.remove(sl.getId());
                continue;
            }
            if (skillsToLearnMap.containsKey(sl.getId())) continue;
            skillsToLearnMap.put(sl.getId(), sl);
        }
        for (SkillLearn sl : (Iterable<SkillLearn>)skillsToLearnMap.valueCollection()) {
            SkillEntry skillEntry2 = SkillEntry.makeSkillEntry(SkillEntryType.NONE, sl.getId(), sl.getLevel());
            if (skillEntry2 == null) continue;
            this.addSkill(skillEntry2, true);
        }
        int arenaSkillLevel = this.getArenaStage() / 5;
        if (this.getSkillLevel(55887) != arenaSkillLevel) {
            this.removeSkill(55887, false);
        }
        if (arenaSkillLevel > 0 && (skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, 55887, arenaSkillLevel)) != null) {
            this.addSkill(skillEntry, false);
        }
    }

    public int getArenaStage() {
        return this.arenaStage;
    }

    public void setArenaStage(int value) {
        this.arenaStage = value;
    }

    private static class ClanReputationComparator
    implements Comparator<Clan> {
        private ClanReputationComparator() {
        }

        @Override
        public int compare(Clan o1, Clan o2) {
            if (o1 == null || o2 == null) {
                return 0;
            }
            return o2.getReputationScore() - o1.getReputationScore();
        }
    }
}

