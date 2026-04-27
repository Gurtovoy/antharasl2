package l2s.gameserver.network.webserver;

import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import l2s.gameserver.dao.AutobotsDAO;
import l2s.gameserver.instancemanager.AutobotScheduler;
import l2s.gameserver.model.autobot.AutobotScheduleInfo;

public class ScheduleApiHandler extends ApiHandler
{
	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		String method = exchange.getRequestMethod();
		String path = exchange.getRequestURI().getPath();

		if("GET".equals(method) && path.equals("/api/autobots/schedule"))
		{
			handleGetAll(exchange);
			return;
		}

		if("POST".equals(method) && path.equals("/api/autobots/schedule"))
		{
			handleCreate(exchange);
			return;
		}

		if("PUT".equals(method) && path.matches("/api/autobots/schedule/\\d+"))
		{
			handleUpdate(exchange, path);
			return;
		}

		if("DELETE".equals(method) && path.matches("/api/autobots/schedule/\\d+"))
		{
			handleDelete(exchange, path);
			return;
		}

		sendError(exchange, 404, "Not found");
	}

	private void handleGetAll(HttpExchange exchange) throws IOException
	{
		List<AutobotScheduleInfo> schedules = AutobotsDAO.getInstance().loadSchedules();
		List<Map<String, Object>> result = new ArrayList<>();

		for(AutobotScheduleInfo s : schedules)
		{
			result.add(scheduleToMap(s));
		}

		sendJson(exchange, 200, result);
	}

	private void handleCreate(HttpExchange exchange) throws IOException
	{
		JsonObject body;
		try(InputStreamReader reader = new InputStreamReader(exchange.getRequestBody(), StandardCharsets.UTF_8))
		{
			body = new JsonParser().parse(reader).getAsJsonObject();
		}
		catch(Exception e)
		{
			sendError(exchange, 400, "Invalid JSON body");
			return;
		}

		if(!body.has("botId"))
		{
			sendError(exchange, 400, "Missing required field: botId");
			return;
		}

		AutobotScheduleInfo schedule = new AutobotScheduleInfo();
		schedule.setBotId(body.get("botId").getAsInt());
		schedule.setSpawnHour(body.has("spawnHour") ? body.get("spawnHour").getAsInt() : 0);
		schedule.setSpawnMinute(body.has("spawnMinute") ? body.get("spawnMinute").getAsInt() : 0);
		schedule.setDespawnHour(body.has("despawnHour") ? body.get("despawnHour").getAsInt() : 23);
		schedule.setDespawnMinute(body.has("despawnMinute") ? body.get("despawnMinute").getAsInt() : 59);
		schedule.setDaysOfWeek(body.has("daysOfWeek") ? body.get("daysOfWeek").getAsString() : "1,2,3,4,5,6,7");
		schedule.setEnabled(!body.has("enabled") || body.get("enabled").getAsBoolean());

		AutobotsDAO.getInstance().saveSchedule(schedule);
		AutobotScheduler.getInstance().reload();

		Map<String, Object> result = scheduleToMap(schedule);
		result.put("message", "Schedule created successfully");

		sendJson(exchange, 201, result);
	}

	private void handleUpdate(HttpExchange exchange, String path) throws IOException
	{
		int scheduleId = extractId(path, "/api/autobots/schedule/");
		if(scheduleId <= 0)
		{
			sendError(exchange, 400, "Invalid schedule ID");
			return;
		}

		JsonObject body;
		try(InputStreamReader reader = new InputStreamReader(exchange.getRequestBody(), StandardCharsets.UTF_8))
		{
			body = new JsonParser().parse(reader).getAsJsonObject();
		}
		catch(Exception e)
		{
			sendError(exchange, 400, "Invalid JSON body");
			return;
		}

		AutobotScheduleInfo existing = null;
		for(AutobotScheduleInfo s : AutobotsDAO.getInstance().loadSchedules())
		{
			if(s.getId() == scheduleId)
			{
				existing = s;
				break;
			}
		}
		if(existing == null)
		{
			sendError(exchange, 404, "Schedule not found");
			return;
		}

		if(body.has("botId"))         existing.setBotId(body.get("botId").getAsInt());
		if(body.has("spawnHour"))     existing.setSpawnHour(body.get("spawnHour").getAsInt());
		if(body.has("spawnMinute"))   existing.setSpawnMinute(body.get("spawnMinute").getAsInt());
		if(body.has("despawnHour"))   existing.setDespawnHour(body.get("despawnHour").getAsInt());
		if(body.has("despawnMinute")) existing.setDespawnMinute(body.get("despawnMinute").getAsInt());
		if(body.has("daysOfWeek"))    existing.setDaysOfWeek(body.get("daysOfWeek").getAsString());
		if(body.has("enabled"))       existing.setEnabled(body.get("enabled").getAsBoolean());

		AutobotsDAO.getInstance().saveSchedule(existing);
		AutobotScheduler.getInstance().reload();

		Map<String, Object> result = scheduleToMap(existing);
		result.put("message", "Schedule updated successfully");

		sendJson(exchange, 200, result);
	}

	private void handleDelete(HttpExchange exchange, String path) throws IOException
	{
		int scheduleId = extractId(path, "/api/autobots/schedule/");
		if(scheduleId <= 0)
		{
			sendError(exchange, 400, "Invalid schedule ID");
			return;
		}

		AutobotsDAO.getInstance().deleteSchedule(scheduleId);
		AutobotScheduler.getInstance().reload();

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", scheduleId);
		result.put("message", "Schedule deleted successfully");

		sendJson(exchange, 200, result);
	}

	private Map<String, Object> scheduleToMap(AutobotScheduleInfo s)
	{
		Map<String, Object> m = new LinkedHashMap<>();
		m.put("id", s.getId());
		m.put("botId", s.getBotId());
		m.put("spawnHour", s.getSpawnHour());
		m.put("spawnMinute", s.getSpawnMinute());
		m.put("despawnHour", s.getDespawnHour());
		m.put("despawnMinute", s.getDespawnMinute());
		m.put("daysOfWeek", s.getDaysOfWeek());
		m.put("enabled", s.isEnabled());
		return m;
	}

	private int extractId(String path, String prefix)
	{
		try
		{
			String idStr = path.substring(prefix.length());
			if(idStr.contains("/"))
				idStr = idStr.substring(0, idStr.indexOf('/'));
			return Integer.parseInt(idStr);
		}
		catch(Exception e)
		{
			return -1;
		}
	}
}
