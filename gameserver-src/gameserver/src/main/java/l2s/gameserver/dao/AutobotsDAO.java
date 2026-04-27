package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.autobot.AutobotInfo;
import l2s.gameserver.model.autobot.AutobotScheduleInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class AutobotsDAO
{
	private static final Logger _log = LoggerFactory.getLogger(AutobotsDAO.class);
	private static final AutobotsDAO _instance = new AutobotsDAO();

	public static AutobotsDAO getInstance()
	{
		return _instance;
	}

	public List<AutobotInfo> loadAll()
	{
		List<AutobotInfo> result = new ArrayList<>();
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobots ORDER BY obj_id");
			rset = statement.executeQuery();
			while(rset.next())
			{
				result.add(mapAutobotInfo(rset));
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.loadAll(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return result;
	}

	public AutobotInfo loadById(int objId)
	{
		AutobotInfo info = null;
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobots WHERE obj_id=?");
			statement.setInt(1, objId);
			rset = statement.executeQuery();
			if(rset.next())
			{
				info = mapAutobotInfo(rset);
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.loadById(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return info;
	}

	public AutobotInfo loadByName(String name)
	{
		AutobotInfo info = null;
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobots WHERE name=?");
			statement.setString(1, name);
			rset = statement.executeQuery();
			if(rset.next())
			{
				info = mapAutobotInfo(rset);
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.loadByName(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return info;
	}

	public void save(AutobotInfo info)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			if(info.getObjId() > 0)
			{
				statement = con.prepareStatement("UPDATE autobots SET name=?, level=?, classid=?, base_class=?, race=?, sex=?, face=?, hair_style=?, hair_color=?, x=?, y=?, z=?, heading=?, title=?, combat_prefs=?, social_prefs=?, activity_prefs=?, skill_prefs=?, is_online=? WHERE obj_id=?");
				statement.setString(1, info.getName());
				statement.setInt(2, info.getLevel());
				statement.setInt(3, info.getClassId());
				statement.setInt(4, info.getBaseClass());
				statement.setInt(5, info.getRace());
				statement.setInt(6, info.getSex());
				statement.setInt(7, info.getFace());
				statement.setInt(8, info.getHairStyle());
				statement.setInt(9, info.getHairColor());
				statement.setInt(10, info.getX());
				statement.setInt(11, info.getY());
				statement.setInt(12, info.getZ());
				statement.setInt(13, info.getHeading());
				statement.setString(14, info.getTitle());
				statement.setString(15, info.getCombatPrefsJson());
				statement.setString(16, info.getSocialPrefsJson());
				statement.setString(17, info.getActivityPrefsJson());
				statement.setString(18, info.getSkillPrefsJson());
				statement.setInt(19, info.isOnline() ? 1 : 0);
				statement.setInt(20, info.getObjId());
				statement.executeUpdate();
			}
			else
			{
				statement = con.prepareStatement("INSERT INTO autobots (name, level, classid, base_class, race, sex, face, hair_style, hair_color, x, y, z, heading, title, combat_prefs, social_prefs, activity_prefs, skill_prefs, is_online) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
				statement.setString(1, info.getName());
				statement.setInt(2, info.getLevel());
				statement.setInt(3, info.getClassId());
				statement.setInt(4, info.getBaseClass());
				statement.setInt(5, info.getRace());
				statement.setInt(6, info.getSex());
				statement.setInt(7, info.getFace());
				statement.setInt(8, info.getHairStyle());
				statement.setInt(9, info.getHairColor());
				statement.setInt(10, info.getX());
				statement.setInt(11, info.getY());
				statement.setInt(12, info.getZ());
				statement.setInt(13, info.getHeading());
				statement.setString(14, info.getTitle());
				statement.setString(15, info.getCombatPrefsJson());
				statement.setString(16, info.getSocialPrefsJson());
				statement.setString(17, info.getActivityPrefsJson());
				statement.setString(18, info.getSkillPrefsJson());
				statement.setInt(19, info.isOnline() ? 1 : 0);
				statement.executeUpdate();
				try(ResultSet keys = statement.getGeneratedKeys())
				{
					if(keys.next())
					{
						info.setObjId(keys.getInt(1));
					}
				}
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.save(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	public void delete(int objId)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("DELETE FROM autobots WHERE obj_id=?");
			statement.setInt(1, objId);
			statement.execute();
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.delete(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	public void updateOnlineStatus(int objId, boolean online)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("UPDATE autobots SET is_online=? WHERE obj_id=?");
			statement.setInt(1, online ? 1 : 0);
			statement.setInt(2, objId);
			statement.executeUpdate();
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.updateOnlineStatus(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	public void updateObjId(int oldObjId, int newObjId)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("UPDATE autobots SET obj_id=? WHERE obj_id=?");
			statement.setInt(1, newObjId);
			statement.setInt(2, oldObjId);
			statement.executeUpdate();
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.updateObjId(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	public List<AutobotInfo> searchBots(String nameFilter, int page, int pageSize)
	{
		List<AutobotInfo> result = new ArrayList<>();
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			if(nameFilter != null && !nameFilter.isEmpty())
			{
				statement = con.prepareStatement("SELECT * FROM autobots WHERE name LIKE ? ORDER BY obj_id LIMIT ?, ?");
				statement.setString(1, "%" + nameFilter + "%");
				statement.setInt(2, page * pageSize);
				statement.setInt(3, pageSize);
			}
			else
			{
				statement = con.prepareStatement("SELECT * FROM autobots ORDER BY obj_id LIMIT ?, ?");
				statement.setInt(1, page * pageSize);
				statement.setInt(2, pageSize);
			}
			rset = statement.executeQuery();
			while(rset.next())
			{
				result.add(mapAutobotInfo(rset));
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.searchBots(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return result;
	}

	public int countBots(String nameFilter)
	{
		int count = 0;
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			if(nameFilter != null && !nameFilter.isEmpty())
			{
				statement = con.prepareStatement("SELECT COUNT(*) FROM autobots WHERE name LIKE ?");
				statement.setString(1, "%" + nameFilter + "%");
			}
			else
			{
				statement = con.prepareStatement("SELECT COUNT(*) FROM autobots");
			}
			rset = statement.executeQuery();
			if(rset.next())
			{
				count = rset.getInt(1);
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.countBots(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return count;
	}

	public List<AutobotScheduleInfo> loadSchedules()
	{
		List<AutobotScheduleInfo> result = new ArrayList<>();
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobot_schedules ORDER BY id");
			rset = statement.executeQuery();
			while(rset.next())
			{
				result.add(mapScheduleInfo(rset));
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.loadSchedules(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return result;
	}

	public void saveSchedule(AutobotScheduleInfo schedule)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			if(schedule.getId() > 0)
			{
				statement = con.prepareStatement("UPDATE autobot_schedules SET bot_id=?, spawn_hour=?, spawn_minute=?, despawn_hour=?, despawn_minute=?, days_of_week=?, enabled=? WHERE id=?");
				statement.setInt(1, schedule.getBotId());
				statement.setInt(2, schedule.getSpawnHour());
				statement.setInt(3, schedule.getSpawnMinute());
				statement.setInt(4, schedule.getDespawnHour());
				statement.setInt(5, schedule.getDespawnMinute());
				statement.setString(6, schedule.getDaysOfWeek());
				statement.setInt(7, schedule.isEnabled() ? 1 : 0);
				statement.setInt(8, schedule.getId());
				statement.executeUpdate();
			}
			else
			{
				statement = con.prepareStatement("INSERT INTO autobot_schedules (bot_id, spawn_hour, spawn_minute, despawn_hour, despawn_minute, days_of_week, enabled) VALUES (?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
				statement.setInt(1, schedule.getBotId());
				statement.setInt(2, schedule.getSpawnHour());
				statement.setInt(3, schedule.getSpawnMinute());
				statement.setInt(4, schedule.getDespawnHour());
				statement.setInt(5, schedule.getDespawnMinute());
				statement.setString(6, schedule.getDaysOfWeek());
				statement.setInt(7, schedule.isEnabled() ? 1 : 0);
				statement.executeUpdate();
				try(ResultSet keys = statement.getGeneratedKeys())
				{
					if(keys.next())
					{
						schedule.setId(keys.getInt(1));
					}
				}
			}
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.saveSchedule(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	public void deleteSchedule(int scheduleId)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("DELETE FROM autobot_schedules WHERE id=?");
			statement.setInt(1, scheduleId);
			statement.execute();
		}
		catch(Exception e)
		{
			_log.error("AutobotsDAO.deleteSchedule(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	private AutobotInfo mapAutobotInfo(ResultSet rset) throws Exception
	{
		AutobotInfo info = new AutobotInfo();
		info.setObjId(rset.getInt("obj_id"));
		info.setName(rset.getString("name"));
		info.setLevel(rset.getInt("level"));
		info.setClassId(rset.getInt("classid"));
		info.setBaseClass(rset.getInt("base_class"));
		info.setRace(rset.getInt("race"));
		info.setSex(rset.getInt("sex"));
		info.setFace(rset.getInt("face"));
		info.setHairStyle(rset.getInt("hair_style"));
		info.setHairColor(rset.getInt("hair_color"));
		info.setX(rset.getInt("x"));
		info.setY(rset.getInt("y"));
		info.setZ(rset.getInt("z"));
		info.setHeading(rset.getInt("heading"));
		info.setTitle(rset.getString("title"));
		info.setCombatPrefsJson(rset.getString("combat_prefs"));
		info.setSocialPrefsJson(rset.getString("social_prefs"));
		info.setActivityPrefsJson(rset.getString("activity_prefs"));
		info.setSkillPrefsJson(rset.getString("skill_prefs"));
		info.setOnline(rset.getInt("is_online") == 1);
		info.setCreationDate(rset.getTimestamp("creation_date"));
		return info;
	}

	private AutobotScheduleInfo mapScheduleInfo(ResultSet rset) throws Exception
	{
		AutobotScheduleInfo info = new AutobotScheduleInfo();
		info.setId(rset.getInt("id"));
		info.setBotId(rset.getInt("bot_id"));
		info.setSpawnHour(rset.getInt("spawn_hour"));
		info.setSpawnMinute(rset.getInt("spawn_minute"));
		info.setDespawnHour(rset.getInt("despawn_hour"));
		info.setDespawnMinute(rset.getInt("despawn_minute"));
		info.setDaysOfWeek(rset.getString("days_of_week"));
		info.setEnabled(rset.getInt("enabled") == 1);
		return info;
	}
}
