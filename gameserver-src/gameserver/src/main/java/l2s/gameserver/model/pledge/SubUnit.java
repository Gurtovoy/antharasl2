/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.dbutils.DbUtils
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.CHashIntObjectMap
 *  org.napile.primitive.maps.impl.CTreeIntObjectMap
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model.pledge;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Collection;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.base.PledgeAttendanceType;
import l2s.gameserver.model.base.SubClassType;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExSubPledgetSkillAdd;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;
import org.napile.primitive.maps.impl.CTreeIntObjectMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SubUnit {
    private static final Logger _log = LoggerFactory.getLogger(SubUnit.class);
    private IntObjectMap<SkillEntry> _skills = new CTreeIntObjectMap();
    private IntObjectMap<UnitMember> _members = new CHashIntObjectMap();
    private int _type;
    private int _leaderObjectId;
    private UnitMember _leader;
    private String _name;
    private Clan _clan;
    private boolean _upgraded;

    public SubUnit(Clan c, int type, UnitMember leader, String name, boolean upgraded) {
        this._clan = c;
        this._type = type;
        this._name = name;
        this._upgraded = upgraded;
        this.setLeader(leader, false);
    }

    public SubUnit(Clan c, int type, int leader, String name) {
        this._clan = c;
        this._type = type;
        this._leaderObjectId = leader;
        this._name = name;
    }

    public int getType() {
        return this._type;
    }

    public String getName() {
        return this._name;
    }

    public UnitMember getLeader() {
        return this._leader;
    }

    public boolean isUnitMember(int obj) {
        return this._members.containsKey(obj);
    }

    public void addUnitMember(UnitMember member) {
        this._members.put(member.getObjectId(), member);
    }

    public UnitMember getUnitMember(int obj) {
        if (obj == 0) {
            return null;
        }
        return (UnitMember)this._members.get(obj);
    }

    public UnitMember getUnitMember(String obj) {
        for (UnitMember m : this.getUnitMembers()) {
            if (!m.getName().equalsIgnoreCase(obj)) continue;
            return m;
        }
        return null;
    }

    public void removeUnitMember(int objectId) {
        UnitMember m = (UnitMember)this._members.remove(objectId);
        if (m == null) {
            return;
        }
        if (objectId == this.getLeaderObjectId()) {
            this.setLeader(null, true);
        }
        if (m.hasSponsor()) {
            this._clan.getAnyMember(m.getSponsor()).setApprentice(0);
        }
        SubUnit.removeMemberInDatabase(m);
        m.setPlayerInstance(null, true);
    }

    public void replace(int objectId, int newUnitId) {
        SubUnit newUnit = this._clan.getSubUnit(newUnitId);
        if (newUnit == null) {
            return;
        }
        UnitMember m = (UnitMember)this._members.remove(objectId);
        if (m == null) {
            return;
        }
        m.setPledgeType(newUnitId);
        newUnit.addUnitMember(m);
        if (m.getPowerGrade() > 5) {
            m.setPowerGrade(this._clan.getAffiliationRank(m.getPledgeType()));
        }
    }

    public int getLeaderObjectId() {
        return this._leader == null ? 0 : this._leader.getObjectId();
    }

    public int size() {
        return this._members.size();
    }

    public Collection<UnitMember> getUnitMembers() {
        return this._members.valueCollection();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void setLeader(UnitMember newLeader, boolean updateDB) {
        UnitMember old = this._leader;
        if (old != null) {
            old.setLeaderOf(-128);
        }
        this._leader = newLeader;
        int n = this._leaderObjectId = newLeader == null ? 0 : newLeader.getObjectId();
        if (newLeader != null) {
            newLeader.setLeaderOf(this._type);
        }
        if (updateDB) {
            if (old != null && old.getPlayer() != null) {
                old.getPlayer().getInventory().validateItems();
            }
            if (newLeader.getPlayer() != null) {
                newLeader.getPlayer().getInventory().validateItems();
            }
            Connection con = null;
            PreparedStatement statement = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("UPDATE clan_subpledges SET leader_id=? WHERE clan_id=? and type=?");
                statement.setInt(1, this.getLeaderObjectId());
                statement.setInt(2, this._clan.getClanId());
                statement.setInt(3, this._type);
                statement.execute();
            }
            catch (Exception e) {
                try {
                    _log.error("Exception: " + e, (Throwable)e);
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

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void setName(String name, boolean updateDB) {
        this._name = name;
        if (updateDB) {
            Connection con = null;
            PreparedStatement statement = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("UPDATE clan_subpledges SET name=? WHERE clan_id=? and type=?");
                statement.setString(1, this._name);
                statement.setInt(2, this._clan.getClanId());
                statement.setInt(3, this._type);
                statement.execute();
            }
            catch (Exception e) {
                try {
                    _log.error("Exception: " + e, (Throwable)e);
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

    public String getLeaderName() {
        return this._leader == null ? "" : this._leader.getName();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public SkillEntry addSkill(SkillEntry newSkillEntry, boolean store) {
        SkillEntry oldSkillEntry = null;
        if (newSkillEntry != null) {
            oldSkillEntry = (SkillEntry)this._skills.put(newSkillEntry.getId(), newSkillEntry);
            if (store) {
                Connection con = null;
                PreparedStatement statement = null;
                try {
                    con = DatabaseFactory.getInstance().getConnection();
                    statement = con.prepareStatement("REPLACE INTO clan_subpledges_skills (clan_id,type,skill_id,skill_level) VALUES (?,?,?,?)");
                    statement.setInt(1, this._clan.getClanId());
                    statement.setInt(2, this._type);
                    statement.setInt(3, newSkillEntry.getId());
                    statement.setInt(4, newSkillEntry.getLevel());
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
            ExSubPledgetSkillAdd packet = new ExSubPledgetSkillAdd(this._type, newSkillEntry.getId(), newSkillEntry.getLevel());
            for (UnitMember temp : this._clan) {
                Player player;
                if (!temp.isOnline() || (player = temp.getPlayer()) == null) continue;
                player.sendPacket((IBroadcastPacket)packet);
                if (player.getPledgeType() != this._type) continue;
                this.addSkill(player, newSkillEntry);
            }
        }
        return oldSkillEntry;
    }

    public void addSkillsQuietly(Player player) {
        for (SkillEntry skillEntry : this._skills.valueCollection()) {
            this.addSkill(player, skillEntry);
        }
    }

    public void enableSkills(Player player) {
        for (SkillEntry skillEntry : this._skills.valueCollection()) {
            Skill skill = skillEntry.getTemplate();
            if (skill.getMinPledgeRank().ordinal() > player.getPledgeRank().ordinal() || skill.clanLeaderOnly() && (!skill.clanLeaderOnly() || !player.isClanLeader())) continue;
            player.removeUnActiveSkill(skill);
        }
    }

    public void disableSkills(Player player) {
        for (SkillEntry skillEntry : this._skills.valueCollection()) {
            player.addUnActiveSkill(skillEntry.getTemplate());
        }
    }

    private void addSkill(Player player, SkillEntry skillEntry) {
        Skill skill = skillEntry.getTemplate();
        if (skill.getMinPledgeRank().ordinal() <= player.getPledgeRank().ordinal() && (!skill.clanLeaderOnly() || skill.clanLeaderOnly() && player.isClanLeader())) {
            player.addSkill(skillEntry, false);
            if (this._clan.getReputationScore() < 0 || player.isInOlympiadMode()) {
                player.addUnActiveSkill(skill);
            }
        }
    }

    public Collection<SkillEntry> getSkills() {
        return this._skills.valueCollection();
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    private static void removeMemberInDatabase(UnitMember member) {
        Connection con = null;
        PreparedStatement statement = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("UPDATE characters SET clanid=0, clan_attendance=0, pledge_type=?, pledge_rank=0, lvl_joined_academy=0, apprentice=0, title='', leaveclan=? WHERE obj_Id=?");
            statement.setInt(1, -128);
            statement.setLong(2, System.currentTimeMillis() / 1000L);
            statement.setInt(3, member.getObjectId());
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

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restore() {
        ResultSet rset;
        PreparedStatement statement;
        Connection con;
        block6: {
            con = null;
            statement = null;
            rset = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("SELECT `c`.`char_name` AS `char_name`,`s`.`level` AS `level`,`s`.`class_id` AS `classid`,`c`.`obj_Id` AS `obj_id`,`c`.`title` AS `title`,`c`.`pledge_rank` AS `pledge_rank`,`c`.`apprentice` AS `apprentice`, `c`.`sex` AS `sex`, `c`.`clan_attendance` AS `clan_attendance` FROM `characters` `c` LEFT JOIN `character_subclasses` `s` ON (`s`.`char_obj_id` = `c`.`obj_Id` AND `s`.`type` = '" + SubClassType.BASE_CLASS.ordinal() + "') " + "WHERE `c`.`clanid`=? AND `c`.`pledge_type`=? ORDER BY `c`.`lastaccess` DESC");
                statement.setInt(1, this._clan.getClanId());
                statement.setInt(2, this._type);
                rset = statement.executeQuery();
                while (rset.next()) {
                    UnitMember member = new UnitMember(this._clan, rset.getString("char_name"), rset.getString("title"), rset.getInt("level"), rset.getInt("classid"), rset.getInt("obj_Id"), this._type, rset.getInt("pledge_rank"), rset.getInt("apprentice"), rset.getInt("sex"), -128, PledgeAttendanceType.VALUES[rset.getInt("clan_attendance")]);
                    this.addUnitMember(member);
                }
                if (this._type == -1) break block6;
                SubUnit mainClan = this._clan.getSubUnit(0);
                UnitMember leader = mainClan.getUnitMember(this._leaderObjectId);
                if (leader != null) {
                    this.setLeader(leader, false);
                    break block6;
                }
                if (this._type != 0) break block6;
                _log.error("Clan " + this._name + " have no leader!");
            }
            catch (Exception e) {
                try {
                    _log.warn("Error while restoring clan members for clan: " + this._clan.getClanId() + " " + e, (Throwable)e);
                }
                catch (Throwable throwable) {
                    DbUtils.closeQuietly((Connection)con, statement, rset);
                    throw throwable;
                }
                DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
            }
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void restoreSkills() {
        Connection con = null;
        PreparedStatement statement = null;
        ResultSet rset = null;
        try {
            con = DatabaseFactory.getInstance().getConnection();
            statement = con.prepareStatement("SELECT skill_id,skill_level FROM clan_subpledges_skills WHERE clan_id=? AND type=?");
            statement.setInt(1, this._clan.getClanId());
            statement.setInt(2, this._type);
            rset = statement.executeQuery();
            while (rset.next()) {
                int id = rset.getInt("skill_id");
                int level = rset.getInt("skill_level");
                SkillEntry skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, id, level);
                this._skills.put(skillEntry.getId(), skillEntry);
            }
        }
        catch (Exception e) {
            try {
                _log.warn("Exception: " + e, (Throwable)e);
            }
            catch (Throwable throwable) {
                DbUtils.closeQuietly((Connection)con, statement, rset);
                throw throwable;
            }
            DbUtils.closeQuietly((Connection)con, (Statement)statement, rset);
        }
        DbUtils.closeQuietly((Connection)con, (Statement)statement, (ResultSet)rset);
    }

    public int getSkillLevel(int id, int def) {
        SkillEntry skillEntry = (SkillEntry)this._skills.get(id);
        return skillEntry == null ? def : skillEntry.getLevel();
    }

    public int getSkillLevel(int id) {
        return this.getSkillLevel(id, -1);
    }

    public boolean isUpgraded() {
        return this._upgraded;
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     */
    public void setUpgraded(boolean upgraded, boolean updateInDb) {
        this._upgraded = upgraded;
        if (updateInDb) {
            Connection con = null;
            PreparedStatement statement = null;
            try {
                con = DatabaseFactory.getInstance().getConnection();
                statement = con.prepareStatement("UPDATE clan_subpledges SET upgraded=? WHERE clan_id=? and type=?");
                statement.setInt(1, this.isUpgraded() ? 1 : 0);
                statement.setInt(2, this._clan.getClanId());
                statement.setInt(3, this._type);
                statement.execute();
            }
            catch (Exception e) {
                try {
                    _log.error("Exception: " + e, (Throwable)e);
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
}

