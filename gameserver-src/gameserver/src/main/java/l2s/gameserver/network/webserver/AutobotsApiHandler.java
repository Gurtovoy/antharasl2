package l2s.gameserver.network.webserver;

import com.google.gson.JsonElement;
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
import l2s.gameserver.instancemanager.AutobotsManager;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.autobot.AutobotInfo;

public class AutobotsApiHandler extends ApiHandler
{
	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		String method = exchange.getRequestMethod();
		String path = exchange.getRequestURI().getPath();

		// POST /api/autobots/spawn-random
		if("POST".equals(method) && path.equals("/api/autobots/spawn-random"))
		{
			handleSpawnRandom(exchange);
			return;
		}

		// POST /api/autobots/despawn-all
		if("POST".equals(method) && path.equals("/api/autobots/despawn-all"))
		{
			handleDespawnAll(exchange);
			return;
		}

		// POST /api/autobots/{id}/spawn
		if("POST".equals(method) && path.matches("/api/autobots/\\d+/spawn"))
		{
			handleSpawnBot(exchange, path);
			return;
		}

		// POST /api/autobots/{id}/despawn
		if("POST".equals(method) && path.matches("/api/autobots/\\d+/despawn"))
		{
			handleDespawnBot(exchange, path);
			return;
		}

		// GET /api/autobots — list
		if("GET".equals(method) && path.equals("/api/autobots"))
		{
			handleList(exchange);
			return;
		}

		// GET /api/autobots/{id}
		if("GET".equals(method) && path.matches("/api/autobots/\\d+"))
		{
			handleGetBot(exchange, path);
			return;
		}

		// POST /api/autobots — create
		if("POST".equals(method) && path.equals("/api/autobots"))
		{
			handleCreateBot(exchange);
			return;
		}

		// PUT /api/autobots/{id}
		if("PUT".equals(method) && path.matches("/api/autobots/\\d+"))
		{
			handleUpdateBot(exchange, path);
			return;
		}

		// DELETE /api/autobots/{id}
		if("DELETE".equals(method) && path.matches("/api/autobots/\\d+"))
		{
			handleDeleteBot(exchange, path);
			return;
		}

		sendError(exchange, 404, "Not found");
	}

	private void handleList(HttpExchange exchange) throws IOException
	{
		String nameFilter = getQueryParam(exchange, "name");
		int page = getIntQueryParam(exchange, "page", 0);
		int pageSize = getIntQueryParam(exchange, "pageSize", 20);

		if(pageSize < 1) pageSize = 1;
		if(pageSize > 100) pageSize = 100;
		if(page < 1) page = 1;

		// Frontend sends 1-based page number, DAO expects 0-based offset page
		List<AutobotInfo> bots = AutobotsManager.getInstance().searchBots(nameFilter, page - 1, pageSize);
		int total = AutobotsDAO.getInstance().countBots(nameFilter);

		List<Map<String, Object>> botList = new ArrayList<>();
		for(AutobotInfo bot : bots)
		{
			Map<String, Object> m = new LinkedHashMap<>();
			m.put("objId", bot.getObjId());
			m.put("name", bot.getName());
			m.put("level", bot.getLevel());
			m.put("classId", bot.getClassId());
			m.put("race", bot.getRace());
			m.put("sex", bot.getSex());
			m.put("x", bot.getX());
			m.put("y", bot.getY());
			m.put("z", bot.getZ());
			m.put("isOnline", AutobotsManager.getInstance().isActive(bot.getObjId()));
			botList.add(m);
		}

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("bots", botList);
		result.put("total", total);
		result.put("page", page);
		result.put("pageSize", pageSize);

		sendJson(exchange, 200, result);
	}

	private void handleGetBot(HttpExchange exchange, String path) throws IOException
	{
		int objId = extractIdFromPath(path, "/api/autobots/");
		if(objId <= 0)
		{
			sendError(exchange, 400, "Invalid bot ID");
			return;
		}

		AutobotInfo info = AutobotsManager.getInstance().getBotInfo(objId);
		if(info == null)
		{
			sendError(exchange, 404, "Bot not found");
			return;
		}

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("objId", info.getObjId());
		result.put("name", info.getName());
		result.put("level", info.getLevel());
		result.put("classId", info.getClassId());
		result.put("baseClass", info.getBaseClass());
		result.put("race", info.getRace());
		result.put("sex", info.getSex());
		result.put("face", info.getFace());
		result.put("hairStyle", info.getHairStyle());
		result.put("hairColor", info.getHairColor());
		result.put("x", info.getX());
		result.put("y", info.getY());
		result.put("z", info.getZ());
		result.put("heading", info.getHeading());
		result.put("title", info.getTitle());
		result.put("combatPrefs", info.getCombatPrefs());
		result.put("socialPrefs", info.getSocialPrefs());
		result.put("activityPrefs", info.getActivityPrefs());
		result.put("skillPrefs", info.getSkillPrefs());
		result.put("isOnline", AutobotsManager.getInstance().isActive(objId));
		result.put("creationDate", info.getCreationDate() != null ? info.getCreationDate().getTime() : null);

		sendJson(exchange, 200, result);
	}

	private void handleCreateBot(HttpExchange exchange) throws IOException
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

		if(!body.has("name") || !body.has("classId"))
		{
			sendError(exchange, 400, "Missing required fields: name, classId");
			return;
		}

		AutobotInfo info = new AutobotInfo();
		info.setName(body.get("name").getAsString());
		info.setClassId(body.get("classId").getAsInt());
		info.setBaseClass(body.has("baseClass") ? body.get("baseClass").getAsInt() : body.get("classId").getAsInt());
		info.setRace(body.has("race") ? body.get("race").getAsInt() : 0);
		info.setSex(body.has("sex") ? body.get("sex").getAsInt() : 0);
		info.setLevel(body.has("level") ? body.get("level").getAsInt() : 1);
		info.setFace(body.has("face") ? body.get("face").getAsInt() : 0);
		info.setHairStyle(body.has("hairStyle") ? body.get("hairStyle").getAsInt() : 0);
		info.setHairColor(body.has("hairColor") ? body.get("hairColor").getAsInt() : 0);
		info.setTitle(body.has("title") ? body.get("title").getAsString() : "");

		// Default spawn location (Talking Island)
		info.setX(body.has("x") ? body.get("x").getAsInt() : -84318);
		info.setY(body.has("y") ? body.get("y").getAsInt() : 244579);
		info.setZ(body.has("z") ? body.get("z").getAsInt() : -3730);

		AutobotsManager.getInstance().saveBotInfo(info);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("objId", info.getObjId());
		result.put("name", info.getName());
		result.put("message", "Bot created successfully");

		sendJson(exchange, 201, result);
	}

	private void handleUpdateBot(HttpExchange exchange, String path) throws IOException
	{
		int objId = extractIdFromPath(path, "/api/autobots/");
		if(objId <= 0)
		{
			sendError(exchange, 400, "Invalid bot ID");
			return;
		}

		AutobotInfo info = AutobotsManager.getInstance().getBotInfo(objId);
		if(info == null)
		{
			sendError(exchange, 404, "Bot not found");
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

		if(body.has("name")) info.setName(body.get("name").getAsString());
		if(body.has("level")) info.setLevel(body.get("level").getAsInt());
		if(body.has("classId")) info.setClassId(body.get("classId").getAsInt());
		if(body.has("baseClass")) info.setBaseClass(body.get("baseClass").getAsInt());
		if(body.has("race")) info.setRace(body.get("race").getAsInt());
		if(body.has("sex")) info.setSex(body.get("sex").getAsInt());
		if(body.has("face")) info.setFace(body.get("face").getAsInt());
		if(body.has("hairStyle")) info.setHairStyle(body.get("hairStyle").getAsInt());
		if(body.has("hairColor")) info.setHairColor(body.get("hairColor").getAsInt());
		if(body.has("title")) info.setTitle(body.get("title").getAsString());
		if(body.has("x")) info.setX(body.get("x").getAsInt());
		if(body.has("y")) info.setY(body.get("y").getAsInt());
		if(body.has("z")) info.setZ(body.get("z").getAsInt());

		if(body.has("combatPrefs"))
			info.setCombatPrefsJson(GSON.toJson(body.get("combatPrefs")));
		if(body.has("socialPrefs"))
			info.setSocialPrefsJson(GSON.toJson(body.get("socialPrefs")));
		if(body.has("activityPrefs"))
			info.setActivityPrefsJson(GSON.toJson(body.get("activityPrefs")));
		if(body.has("skillPrefs"))
			info.setSkillPrefsJson(GSON.toJson(body.get("skillPrefs")));

		AutobotsManager.getInstance().saveBotInfo(info);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("objId", info.getObjId());
		result.put("message", "Bot updated successfully");

		sendJson(exchange, 200, result);
	}

	private void handleDeleteBot(HttpExchange exchange, String path) throws IOException
	{
		int objId = extractIdFromPath(path, "/api/autobots/");
		if(objId <= 0)
		{
			sendError(exchange, 400, "Invalid bot ID");
			return;
		}

		AutobotInfo info = AutobotsManager.getInstance().getBotInfo(objId);
		if(info == null)
		{
			sendError(exchange, 404, "Bot not found");
			return;
		}

		AutobotsManager.getInstance().deleteBotInfo(objId);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("objId", objId);
		result.put("message", "Bot deleted successfully");

		sendJson(exchange, 200, result);
	}

	private void handleSpawnBot(HttpExchange exchange, String path) throws IOException
	{
		String idStr = path.replaceAll("/api/autobots/(\\d+)/spawn", "$1");
		int objId;
		try
		{
			objId = Integer.parseInt(idStr);
		}
		catch(NumberFormatException e)
		{
			sendError(exchange, 400, "Invalid bot ID");
			return;
		}

		Player player = AutobotsManager.getInstance().spawnBot(objId);

		Map<String, Object> result = new LinkedHashMap<>();
		if(player != null)
		{
			result.put("objId", objId);
			result.put("name", player.getName());
			result.put("message", "Bot spawned successfully");
			sendJson(exchange, 200, result);
		}
		else
		{
			sendError(exchange, 500, "Failed to spawn bot " + objId);
		}
	}

	private void handleDespawnBot(HttpExchange exchange, String path) throws IOException
	{
		String idStr = path.replaceAll("/api/autobots/(\\d+)/despawn", "$1");
		int objId;
		try
		{
			objId = Integer.parseInt(idStr);
		}
		catch(NumberFormatException e)
		{
			sendError(exchange, 400, "Invalid bot ID");
			return;
		}

		boolean success = AutobotsManager.getInstance().despawnBot(objId);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("objId", objId);
		result.put("success", success);
		result.put("message", success ? "Bot despawned successfully" : "Bot was not active");

		sendJson(exchange, 200, result);
	}

	private void handleSpawnRandom(HttpExchange exchange) throws IOException
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

		int count = body.has("count") ? body.get("count").getAsInt() : 1;
		if(count < 1) count = 1;
		if(count > 500) count = 500;

		AutobotsManager.getInstance().spawnRandom(count);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("message", "Spawning " + count + " random bots (staggered)");
		result.put("count", count);

		sendJson(exchange, 200, result);
	}

	private void handleDespawnAll(HttpExchange exchange) throws IOException
	{
		AutobotsManager.getInstance().despawnAll();

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("message", "All bots despawned");

		sendJson(exchange, 200, result);
	}

	private int extractIdFromPath(String path, String prefix)
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
