package l2s.gameserver.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.model.autobot.TradeZoneInfo;
import l2s.gameserver.model.autobot.TraderInfo;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TradeBotsDAO
{
	private static final Logger _log = LoggerFactory.getLogger(TradeBotsDAO.class);
	private static final TradeBotsDAO _instance = new TradeBotsDAO();

	public static TradeBotsDAO getInstance()
	{
		return _instance;
	}

	// ==================== Trade Zones ====================

	public List<TradeZoneInfo> loadTradeZones()
	{
		List<TradeZoneInfo> result = new ArrayList<>();
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobot_trade_zones ORDER BY id");
			rset = statement.executeQuery();
			while(rset.next())
			{
				result.add(mapTradeZone(rset));
			}
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.loadTradeZones(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return result;
	}

	public TradeZoneInfo loadTradeZone(int id)
	{
		TradeZoneInfo info = null;
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobot_trade_zones WHERE id=?");
			statement.setInt(1, id);
			rset = statement.executeQuery();
			if(rset.next())
			{
				info = mapTradeZone(rset);
			}
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.loadTradeZone(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return info;
	}

	public void saveTradeZone(TradeZoneInfo zone)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			if(zone.getId() > 0)
			{
				statement = con.prepareStatement("UPDATE autobot_trade_zones SET name=?, x1=?, y1=?, x2=?, y2=?, z=?, max_traders=? WHERE id=?");
				statement.setString(1, zone.getName());
				statement.setInt(2, zone.getX1());
				statement.setInt(3, zone.getY1());
				statement.setInt(4, zone.getX2());
				statement.setInt(5, zone.getY2());
				statement.setInt(6, zone.getZ());
				statement.setInt(7, zone.getMaxTraders());
				statement.setInt(8, zone.getId());
				statement.executeUpdate();
			}
			else
			{
				statement = con.prepareStatement("INSERT INTO autobot_trade_zones (name, x1, y1, x2, y2, z, max_traders) VALUES (?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
				statement.setString(1, zone.getName());
				statement.setInt(2, zone.getX1());
				statement.setInt(3, zone.getY1());
				statement.setInt(4, zone.getX2());
				statement.setInt(5, zone.getY2());
				statement.setInt(6, zone.getZ());
				statement.setInt(7, zone.getMaxTraders());
				statement.executeUpdate();
				try(ResultSet keys = statement.getGeneratedKeys())
				{
					if(keys.next())
					{
						zone.setId(keys.getInt(1));
					}
				}
			}
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.saveTradeZone(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	public void deleteTradeZone(int id)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("DELETE FROM autobot_trade_zones WHERE id=?");
			statement.setInt(1, id);
			statement.execute();
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.deleteTradeZone(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	// ==================== Traders ====================

	public List<TraderInfo> loadTraders()
	{
		List<TraderInfo> result = new ArrayList<>();
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobot_traders ORDER BY id");
			rset = statement.executeQuery();
			while(rset.next())
			{
				result.add(mapTrader(rset));
			}
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.loadTraders(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return result;
	}

	public List<TraderInfo> loadTradersByZone(int zoneId)
	{
		List<TraderInfo> result = new ArrayList<>();
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobot_traders WHERE zone_id=? ORDER BY slot_index");
			statement.setInt(1, zoneId);
			rset = statement.executeQuery();
			while(rset.next())
			{
				result.add(mapTrader(rset));
			}
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.loadTradersByZone(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return result;
	}

	public TraderInfo loadTrader(int id)
	{
		TraderInfo info = null;
		Connection con = null;
		PreparedStatement statement = null;
		ResultSet rset = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("SELECT * FROM autobot_traders WHERE id=?");
			statement.setInt(1, id);
			rset = statement.executeQuery();
			if(rset.next())
			{
				info = mapTrader(rset);
			}
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.loadTrader(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement, rset);
		}
		return info;
	}

	public void saveTrader(TraderInfo trader)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			if(trader.getId() > 0)
			{
				statement = con.prepareStatement("UPDATE autobot_traders SET bot_id=?, zone_id=?, slot_index=?, trade_type=?, store_name=?, items_json=?, is_active=? WHERE id=?");
				statement.setInt(1, trader.getBotId());
				statement.setInt(2, trader.getZoneId());
				statement.setInt(3, trader.getSlotIndex());
				statement.setString(4, trader.getTradeType());
				statement.setString(5, trader.getStoreName());
				statement.setString(6, trader.getItemsJson());
				statement.setInt(7, trader.isActive() ? 1 : 0);
				statement.setInt(8, trader.getId());
				statement.executeUpdate();
			}
			else
			{
				statement = con.prepareStatement("INSERT INTO autobot_traders (bot_id, zone_id, slot_index, trade_type, store_name, items_json, is_active) VALUES (?,?,?,?,?,?,?)", Statement.RETURN_GENERATED_KEYS);
				statement.setInt(1, trader.getBotId());
				statement.setInt(2, trader.getZoneId());
				statement.setInt(3, trader.getSlotIndex());
				statement.setString(4, trader.getTradeType());
				statement.setString(5, trader.getStoreName());
				statement.setString(6, trader.getItemsJson());
				statement.setInt(7, trader.isActive() ? 1 : 0);
				statement.executeUpdate();
				try(ResultSet keys = statement.getGeneratedKeys())
				{
					if(keys.next())
					{
						trader.setId(keys.getInt(1));
					}
				}
			}
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.saveTrader(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	public void deleteTrader(int id)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("DELETE FROM autobot_traders WHERE id=?");
			statement.setInt(1, id);
			statement.execute();
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.deleteTrader(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	public void updateTraderActive(int id, boolean active)
	{
		Connection con = null;
		PreparedStatement statement = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();
			statement = con.prepareStatement("UPDATE autobot_traders SET is_active=? WHERE id=?");
			statement.setInt(1, active ? 1 : 0);
			statement.setInt(2, id);
			statement.executeUpdate();
		}
		catch(Exception e)
		{
			_log.error("TradeBotsDAO.updateTraderActive(): " + e, e);
		}
		finally
		{
			DbUtils.closeQuietly(con, statement);
		}
	}

	// ==================== Mappers ====================

	private TradeZoneInfo mapTradeZone(ResultSet rset) throws Exception
	{
		TradeZoneInfo info = new TradeZoneInfo();
		info.setId(rset.getInt("id"));
		info.setName(rset.getString("name"));
		info.setX1(rset.getInt("x1"));
		info.setY1(rset.getInt("y1"));
		info.setX2(rset.getInt("x2"));
		info.setY2(rset.getInt("y2"));
		info.setZ(rset.getInt("z"));
		info.setMaxTraders(rset.getInt("max_traders"));
		return info;
	}

	private TraderInfo mapTrader(ResultSet rset) throws Exception
	{
		TraderInfo info = new TraderInfo();
		info.setId(rset.getInt("id"));
		info.setBotId(rset.getInt("bot_id"));
		info.setZoneId(rset.getInt("zone_id"));
		info.setSlotIndex(rset.getInt("slot_index"));
		info.setTradeType(rset.getString("trade_type"));
		info.setStoreName(rset.getString("store_name"));
		info.setItemsJson(rset.getString("items_json"));
		info.setActive(rset.getInt("is_active") == 1);
		return info;
	}
}
