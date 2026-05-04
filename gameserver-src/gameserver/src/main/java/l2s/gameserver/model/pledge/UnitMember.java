/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.pledge;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.PledgeAttendanceType;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.RankPrivs;
import l2s.gameserver.model.pledge.SubUnit;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ExPledgeBonusUpdate;
import l2s.gameserver.network.l2.s2c.NickNameChangedPacket;
import l2s.gameserver.network.l2.s2c.PledgeShowMemberListUpdatePacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.utils.PledgeBonusUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class UnitMember {
    private static final Logger _log = LoggerFactory.getLogger(UnitMember.class);
    private static final int ATTENDANCE_CHANGE_DELAY = 1800000;
    private Player _player;
    private Clan _clan;
    private String _name;
    private String _title;
    private int _objectId;
    private int _level;
    private int _classId;
    private int _sex;
    private int _pledgeType;
    private int _powerGrade;
    private int _apprentice;
    private PledgeAttendanceType _attendanceType;
    private int _leaderOf = -128;
    private ScheduledFuture<?> _changeAttendanceTask = null;

    public UnitMember(Clan clan, String name, String title, int level, int classId, int objectId, int pledgeType, int powerGrade, int apprentice, int sex, int leaderOf, PledgeAttendanceType clanAttendance) {
        this._clan = clan;
        this._objectId = objectId;
        this._name = name;
        this._title = title;
        this._level = level;
        this._classId = classId;
        this._pledgeType = pledgeType;
        this._powerGrade = powerGrade;
        this._apprentice = apprentice;
        this._sex = sex;
        this._leaderOf = leaderOf;
        this._attendanceType = clanAttendance;
        if (powerGrade != 0) {
            RankPrivs r = clan.getRankPrivs(powerGrade);
            r.setParty(clan.countMembersByRank(powerGrade));
        }
    }

    public UnitMember(Player player) {
        this._objectId = player.getObjectId();
        this._player = player;
    }

    public void setPlayerInstance(Player player, boolean exit) {
        Player player2 = this._player = exit ? null : player;
        if (player == null) {
            this.cancelChangeAttendanceTask();
            return;
        }
        this._clan = player.getClan();
        this._name = player.getName();
        this._title = player.getTitle();
        this._level = player.getLevel();
        this._classId = player.getClassId().getId();
        this._pledgeType = player.getPledgeType();
        this._powerGrade = player.getPowerGrade();
        this._apprentice = player.getApprentice();
        this._sex = player.getSex().ordinal();
        if (!exit) {
            if (this._attendanceType == PledgeAttendanceType.NOT_ACQUIRED && this._changeAttendanceTask == null) {
                this._changeAttendanceTask = ThreadPoolManager.getInstance().schedule(() -> {
                    int oldLevel = PledgeBonusUtils.getAttendanceProgressLevel(this._clan.getAttendanceProgress());
                    this.setAttendanceType(PledgeAttendanceType.ACQUIRED);
                    this._clan.broadcastToOnlineMembers(new PledgeShowMemberListUpdatePacket(this));
                    this._clan.broadcastToOnlineMembers(new ExPledgeBonusUpdate(ExPledgeBonusUpdate.BonusType.ATTENDANCE, this._clan.getAttendanceProgress()));
                    int newLevel = PledgeBonusUtils.getAttendanceProgressLevel(this._clan.getAttendanceProgress());
                    if (newLevel > oldLevel) {
                        this._clan.broadcastToOnlineMembers(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.YOUR_CLAN_HAS_ACHIEVED_LOGIN_BONUS_LV_S1).addInteger(newLevel)});
                    }
                }, 1800000L);
            }
        } else {
            this.cancelChangeAttendanceTask();
        }
    }

    private void cancelChangeAttendanceTask() {
        if (this._changeAttendanceTask != null) {
            this._changeAttendanceTask.cancel(false);
            this._changeAttendanceTask = null;
        }
    }

    public Player getPlayer() {
        return this._player;
    }

    public boolean isOnline() {
        Player player = this.getPlayer();
        return player != null && !player.isInOfflineMode();
    }

    public Clan getClan() {
        Player player = this.getPlayer();
        return player == null ? this._clan : player.getClan();
    }

    public int getClassId() {
        Player player = this.getPlayer();
        return player == null ? this._classId : player.getClassId().getId();
    }

    public int getSex() {
        Player player = this.getPlayer();
        return player == null ? this._sex : player.getSex().ordinal();
    }

    public int getLevel() {
        Player player = this.getPlayer();
        return player == null ? this._level : player.getLevel();
    }

    public String getName() {
        Player player = this.getPlayer();
        return player == null ? this._name : player.getName();
    }

    public int getObjectId() {
        return this._objectId;
    }

    public String getTitle() {
        Player player = this.getPlayer();
        return player == null ? this._title : player.getTitle();
    }

    
    public void setTitle(String title) {
        Player player = this.getPlayer();
        this._title = title;
        if (player != null) {
            player.setTitle(title);
            player.broadcastPacket(new NickNameChangedPacket(player));
            return;
        }
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET title=? WHERE obj_Id=?");
            statement.setString(1, title);
            statement.setInt(2, this.getObjectId());
            statement.execute();
        }
        catch (Exception e) {
            try {
                _log.error("", (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement);
            return;
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement);
        return;
    }

    public SubUnit getSubUnit() {
        return this._clan.getSubUnit(this._pledgeType);
    }

    public int getPledgeType() {
        Player player = this.getPlayer();
        return player == null ? this._pledgeType : player.getPledgeType();
    }

    public void setPledgeType(int pledgeType) {
        Player player = this.getPlayer();
        this._pledgeType = pledgeType;
        if (player != null) {
            player.setPledgeType(pledgeType);
        } else {
            this.updatePledgeType();
        }
    }

    
    private void updatePledgeType() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET pledge_type=? WHERE obj_Id=?");
            statement.setInt(1, this._pledgeType);
            statement.setInt(2, this.getObjectId());
            statement.execute();
        }
        catch (Exception e) {
            try {
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

    public int getPowerGrade() {
        Player player = this.getPlayer();
        return player == null ? this._powerGrade : player.getPowerGrade();
    }

    public void setPowerGrade(int newPowerGrade) {
        Player player = this.getPlayer();
        int oldPowerGrade = this.getPowerGrade();
        this._powerGrade = newPowerGrade;
        if (player != null) {
            player.setPowerGrade(newPowerGrade);
        } else {
            this.updatePowerGrade();
        }
        this.updatePowerGradeParty(oldPowerGrade, newPowerGrade);
    }

    private void updatePowerGradeParty(int oldGrade, int newGrade) {
        if (oldGrade != 0) {
            RankPrivs r1 = this.getClan().getRankPrivs(oldGrade);
            r1.setParty(this.getClan().countMembersByRank(oldGrade));
        }
        if (newGrade != 0) {
            RankPrivs r2 = this.getClan().getRankPrivs(newGrade);
            r2.setParty(this.getClan().countMembersByRank(newGrade));
        }
    }

    
    private void updatePowerGrade() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET pledge_rank=? WHERE obj_Id=?");
            statement.setInt(1, this._powerGrade);
            statement.setInt(2, this.getObjectId());
            statement.execute();
        }
        catch (Exception e) {
            try {
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

    private int getApprentice() {
        Player player = this.getPlayer();
        return player == null ? this._apprentice : player.getApprentice();
    }

    public void setApprentice(int apprentice) {
        Player player = this.getPlayer();
        this._apprentice = apprentice;
        if (player != null) {
            player.setApprentice(apprentice);
        } else {
            this.updateApprentice();
        }
    }

    
    private void updateApprentice() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET apprentice=? WHERE obj_Id=?");
            statement.setInt(1, this._apprentice);
            statement.setInt(2, this.getObjectId());
            statement.execute();
        }
        catch (Exception e) {
            try {
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

    public PledgeAttendanceType getAttendanceType() {
        return this._attendanceType;
    }

    public void setAttendanceType(PledgeAttendanceType attendanceType) {
        if (this._attendanceType == attendanceType) {
            return;
        }
        this._attendanceType = attendanceType;
        this.updateAttendance();
    }

    
    private void updateAttendance() {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET clan_attendance=? WHERE obj_Id=?");
            statement.setInt(1, this._attendanceType.ordinal());
            statement.setInt(2, this.getObjectId());
            statement.execute();
        }
        catch (Exception e) {
            try {
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

    public String getApprenticeName() {
        if (this.getApprentice() != 0 && this.getClan().getAnyMember(this.getApprentice()) != null) {
            return this.getClan().getAnyMember(this.getApprentice()).getName();
        }
        return "";
    }

    public boolean hasApprentice() {
        return this.getApprentice() != 0;
    }

    public int getSponsor() {
        if (this.getPledgeType() != -1) {
            return 0;
        }
        int id = this.getObjectId();
        for (UnitMember element : this.getClan()) {
            if (element.getApprentice() != id) continue;
            return element.getObjectId();
        }
        return 0;
    }

    private String getSponsorName() {
        int sponsorId = this.getSponsor();
        if (sponsorId == 0) {
            return "";
        }
        if (this.getClan().getAnyMember(sponsorId) != null) {
            return this.getClan().getAnyMember(sponsorId).getName();
        }
        return "";
    }

    public boolean hasSponsor() {
        return this.getSponsor() != 0;
    }

    public String getRelatedName() {
        if (this.getPledgeType() == -1) {
            return this.getSponsorName();
        }
        return this.getApprenticeName();
    }

    public boolean isClanLeader() {
        Player player = this.getPlayer();
        return player == null ? this._leaderOf == 0 : player.isClanLeader();
    }

    public int isSubLeader() {
        for (SubUnit pledge : this.getClan().getAllSubUnits()) {
            if (pledge.getLeaderObjectId() != this.getObjectId()) continue;
            return pledge.getType();
        }
        return 0;
    }

    public void setLeaderOf(int leaderOf) {
        this._leaderOf = leaderOf;
    }

    public int isLeaderOf() {
        return this._leaderOf;
    }
}

