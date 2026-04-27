package l2s.gameserver.network.webserver;

import com.google.gson.JsonArray;
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
import l2s.gameserver.dao.TradeBotsDAO;
import l2s.gameserver.instancemanager.AutobotsManager;
import l2s.gameserver.model.autobot.AutobotInfo;
import l2s.gameserver.model.autobot.TradeZoneInfo;
import l2s.gameserver.model.autobot.TraderInfo;
import l2s.gameserver.model.autobot.TraderInfo.TradeItemConfig;

public class TradeApiHandler extends ApiHandler
{
	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		String method = exchange.getRequestMethod();
		String path = exchange.getRequestURI().getPath();

		// === Zone endpoints ===

		// POST /api/trade/zones/{id}/activate-all
		if("POST".equals(method) && path.matches("/api/trade/zones/\\d+/activate-all"))
		{
			handleActivateZone(exchange, path);
			return;
		}

		// POST /api/trade/zones/{id}/deactivate-all
		if("POST".equals(method) && path.matches("/api/trade/zones/\\d+/deactivate-all"))
		{
			handleDeactivateZone(exchange, path);
			return;
		}

		// GET /api/trade/zones
		if("GET".equals(method) && path.equals("/api/trade/zones"))
		{
			handleListZones(exchange);
			return;
		}

		// POST /api/trade/zones
		if("POST".equals(method) && path.equals("/api/trade/zones"))
		{
			handleCreateZone(exchange);
			return;
		}

		// PUT /api/trade/zones/{id}
		if("PUT".equals(method) && path.matches("/api/trade/zones/\\d+"))
		{
			handleUpdateZone(exchange, path);
			return;
		}

		// DELETE /api/trade/zones/{id}
		if("DELETE".equals(method) && path.matches("/api/trade/zones/\\d+"))
		{
			handleDeleteZone(exchange, path);
			return;
		}

		// === Trader endpoints ===

		// POST /api/trade/traders/{id}/activate
		if("POST".equals(method) && path.matches("/api/trade/traders/\\d+/activate"))
		{
			handleActivateTrader(exchange, path);
			return;
		}

		// POST /api/trade/traders/{id}/deactivate
		if("POST".equals(method) && path.matches("/api/trade/traders/\\d+/deactivate"))
		{
			handleDeactivateTrader(exchange, path);
			return;
		}

		// GET /api/trade/traders
		if("GET".equals(method) && path.equals("/api/trade/traders"))
		{
			handleListTraders(exchange);
			return;
		}

		// POST /api/trade/traders
		if("POST".equals(method) && path.equals("/api/trade/traders"))
		{
			handleCreateTrader(exchange);
			return;
		}

		// PUT /api/trade/traders/{id}
		if("PUT".equals(method) && path.matches("/api/trade/traders/\\d+"))
		{
			handleUpdateTrader(exchange, path);
			return;
		}

		// DELETE /api/trade/traders/{id}
		if("DELETE".equals(method) && path.matches("/api/trade/traders/\\d+"))
		{
			handleDeleteTrader(exchange, path);
			return;
		}

		sendError(exchange, 404, "Not found");
	}

	// ==================== Zone Handlers ====================

	private void handleListZones(HttpExchange exchange) throws IOException
	{
		List<TradeZoneInfo> zones = TradeBotsDAO.getInstance().loadTradeZones();
		List<Map<String, Object>> zoneList = new ArrayList<>();
		for(TradeZoneInfo zone : zones)
		{
			zoneList.add(zoneToMap(zone));
		}
		Map<String, Object> result = new LinkedHashMap<>();
		result.put("zones", zoneList);
		sendJson(exchange, 200, result);
	}

	private void handleCreateZone(HttpExchange exchange) throws IOException
	{
		JsonObject body = parseBody(exchange);
		if(body == null)
		{
			sendError(exchange, 400, "Invalid JSON body");
			return;
		}

		if(!body.has("name"))
		{
			sendError(exchange, 400, "Missing required field: name");
			return;
		}

		TradeZoneInfo zone = new TradeZoneInfo();
		zone.setName(body.get("name").getAsString());
		zone.setX1(getInt(body, "x1", 0));
		zone.setY1(getInt(body, "y1", 0));
		zone.setX2(getInt(body, "x2", 0));
		zone.setY2(getInt(body, "y2", 0));
		zone.setZ(getInt(body, "z", 0));
		zone.setMaxTraders(getInt(body, "maxTraders", 30));

		TradeBotsDAO.getInstance().saveTradeZone(zone);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", zone.getId());
		result.put("message", "Trade zone created successfully");
		sendJson(exchange, 201, result);
	}

	private void handleUpdateZone(HttpExchange exchange, String path) throws IOException
	{
		int id = extractId(path, "/api/trade/zones/");
		if(id <= 0)
		{
			sendError(exchange, 400, "Invalid zone ID");
			return;
		}

		TradeZoneInfo zone = TradeBotsDAO.getInstance().loadTradeZone(id);
		if(zone == null)
		{
			sendError(exchange, 404, "Trade zone not found");
			return;
		}

		JsonObject body = parseBody(exchange);
		if(body == null)
		{
			sendError(exchange, 400, "Invalid JSON body");
			return;
		}

		if(body.has("name")) zone.setName(body.get("name").getAsString());
		if(body.has("x1")) zone.setX1(body.get("x1").getAsInt());
		if(body.has("y1")) zone.setY1(body.get("y1").getAsInt());
		if(body.has("x2")) zone.setX2(body.get("x2").getAsInt());
		if(body.has("y2")) zone.setY2(body.get("y2").getAsInt());
		if(body.has("z")) zone.setZ(body.get("z").getAsInt());
		if(body.has("maxTraders")) zone.setMaxTraders(body.get("maxTraders").getAsInt());

		TradeBotsDAO.getInstance().saveTradeZone(zone);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", zone.getId());
		result.put("message", "Trade zone updated successfully");
		sendJson(exchange, 200, result);
	}

	private void handleDeleteZone(HttpExchange exchange, String path) throws IOException
	{
		int id = extractId(path, "/api/trade/zones/");
		if(id <= 0)
		{
			sendError(exchange, 400, "Invalid zone ID");
			return;
		}

		TradeZoneInfo zone = TradeBotsDAO.getInstance().loadTradeZone(id);
		if(zone == null)
		{
			sendError(exchange, 404, "Trade zone not found");
			return;
		}

		// Deactivate all traders in zone first
		AutobotsManager.getInstance().deactivateZone(id);

		TradeBotsDAO.getInstance().deleteTradeZone(id);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", id);
		result.put("message", "Trade zone deleted successfully");
		sendJson(exchange, 200, result);
	}

	private void handleActivateZone(HttpExchange exchange, String path) throws IOException
	{
		int id = extractZoneIdFromAction(path, "activate-all");
		if(id <= 0)
		{
			sendError(exchange, 400, "Invalid zone ID");
			return;
		}

		TradeZoneInfo zone = TradeBotsDAO.getInstance().loadTradeZone(id);
		if(zone == null)
		{
			sendError(exchange, 404, "Trade zone not found");
			return;
		}

		// Run zone activation asynchronously to avoid blocking the HTTP handler thread
		AutobotsManager.getInstance().activateZoneAsync(id);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("zoneId", id);
		result.put("message", "Zone activation started in background for zone " + zone.getName());
		sendJson(exchange, 200, result);
	}

	private void handleDeactivateZone(HttpExchange exchange, String path) throws IOException
	{
		int id = extractZoneIdFromAction(path, "deactivate-all");
		if(id <= 0)
		{
			sendError(exchange, 400, "Invalid zone ID");
			return;
		}

		TradeZoneInfo zone = TradeBotsDAO.getInstance().loadTradeZone(id);
		if(zone == null)
		{
			sendError(exchange, 404, "Trade zone not found");
			return;
		}

		int deactivated = AutobotsManager.getInstance().deactivateZone(id);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("zoneId", id);
		result.put("deactivated", deactivated);
		result.put("message", "Deactivated " + deactivated + " traders in zone " + zone.getName());
		sendJson(exchange, 200, result);
	}

	// ==================== Trader Handlers ====================

	private void handleListTraders(HttpExchange exchange) throws IOException
	{
		String zoneIdParam = getQueryParam(exchange, "zoneId");
		List<TraderInfo> traders;
		if(zoneIdParam != null)
		{
			try
			{
				int zoneId = Integer.parseInt(zoneIdParam);
				traders = TradeBotsDAO.getInstance().loadTradersByZone(zoneId);
			}
			catch(NumberFormatException e)
			{
				sendError(exchange, 400, "Invalid zoneId parameter");
				return;
			}
		}
		else
		{
			traders = TradeBotsDAO.getInstance().loadTraders();
		}

		List<Map<String, Object>> traderList = new ArrayList<>();
		for(TraderInfo trader : traders)
		{
			traderList.add(traderToMap(trader));
		}
		Map<String, Object> result = new LinkedHashMap<>();
		result.put("traders", traderList);
		sendJson(exchange, 200, result);
	}

	private void handleCreateTrader(HttpExchange exchange) throws IOException
	{
		JsonObject body = parseBody(exchange);
		if(body == null)
		{
			sendError(exchange, 400, "Invalid JSON body");
			return;
		}

		if(!body.has("botId") || !body.has("zoneId"))
		{
			sendError(exchange, 400, "Missing required fields: botId, zoneId");
			return;
		}

		TraderInfo trader = new TraderInfo();
		trader.setBotId(body.get("botId").getAsInt());
		trader.setZoneId(body.get("zoneId").getAsInt());
		trader.setTradeType(body.has("tradeType") ? body.get("tradeType").getAsString() : "sell");
		trader.setStoreName(body.has("storeName") ? body.get("storeName").getAsString() : "Trade Bot");
		trader.setSlotIndex(getInt(body, "slotIndex", -1));

		if(body.has("items"))
		{
			List<TradeItemConfig> items = parseItems(body.getAsJsonArray("items"));
			trader.setItems(items);
		}
		else
		{
			trader.setItemsJson("[]");
		}

		// Validate bot exists
		AutobotInfo botInfo = AutobotsDAO.getInstance().loadById(trader.getBotId());
		if(botInfo == null)
		{
			sendError(exchange, 404, "Bot " + trader.getBotId() + " not found");
			return;
		}

		// Validate zone exists
		TradeZoneInfo zone = TradeBotsDAO.getInstance().loadTradeZone(trader.getZoneId());
		if(zone == null)
		{
			sendError(exchange, 404, "Trade zone " + trader.getZoneId() + " not found");
			return;
		}

		TradeBotsDAO.getInstance().saveTrader(trader);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", trader.getId());
		result.put("message", "Trader created successfully");
		sendJson(exchange, 201, result);
	}

	private void handleUpdateTrader(HttpExchange exchange, String path) throws IOException
	{
		int id = extractId(path, "/api/trade/traders/");
		if(id <= 0)
		{
			sendError(exchange, 400, "Invalid trader ID");
			return;
		}

		TraderInfo trader = TradeBotsDAO.getInstance().loadTrader(id);
		if(trader == null)
		{
			sendError(exchange, 404, "Trader not found");
			return;
		}

		JsonObject body = parseBody(exchange);
		if(body == null)
		{
			sendError(exchange, 400, "Invalid JSON body");
			return;
		}

		if(body.has("botId")) trader.setBotId(body.get("botId").getAsInt());
		if(body.has("zoneId")) trader.setZoneId(body.get("zoneId").getAsInt());
		if(body.has("tradeType")) trader.setTradeType(body.get("tradeType").getAsString());
		if(body.has("storeName")) trader.setStoreName(body.get("storeName").getAsString());
		if(body.has("slotIndex")) trader.setSlotIndex(body.get("slotIndex").getAsInt());

		if(body.has("items"))
		{
			List<TradeItemConfig> items = parseItems(body.getAsJsonArray("items"));
			trader.setItems(items);
		}

		TradeBotsDAO.getInstance().saveTrader(trader);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", trader.getId());
		result.put("message", "Trader updated successfully");
		sendJson(exchange, 200, result);
	}

	private void handleDeleteTrader(HttpExchange exchange, String path) throws IOException
	{
		int id = extractId(path, "/api/trade/traders/");
		if(id <= 0)
		{
			sendError(exchange, 400, "Invalid trader ID");
			return;
		}

		TraderInfo trader = TradeBotsDAO.getInstance().loadTrader(id);
		if(trader == null)
		{
			sendError(exchange, 404, "Trader not found");
			return;
		}

		// Deactivate if active
		if(AutobotsManager.getInstance().isTraderActive(id))
		{
			AutobotsManager.getInstance().despawnTrader(id);
		}

		TradeBotsDAO.getInstance().deleteTrader(id);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", id);
		result.put("message", "Trader deleted successfully");
		sendJson(exchange, 200, result);
	}

	private void handleActivateTrader(HttpExchange exchange, String path) throws IOException
	{
		int id = extractTraderIdFromAction(path, "activate");
		if(id <= 0)
		{
			sendError(exchange, 400, "Invalid trader ID");
			return;
		}

		// Run spawn asynchronously to avoid blocking the HTTP handler thread
		AutobotsManager.getInstance().spawnTraderAsync(id);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", id);
		result.put("success", true);
		result.put("message", "Trader activation started (processing in background)");
		sendJson(exchange, 200, result);
	}

	private void handleDeactivateTrader(HttpExchange exchange, String path) throws IOException
	{
		int id = extractTraderIdFromAction(path, "deactivate");
		if(id <= 0)
		{
			sendError(exchange, 400, "Invalid trader ID");
			return;
		}

		boolean success = AutobotsManager.getInstance().despawnTrader(id);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("id", id);
		result.put("success", success);
		result.put("message", success ? "Trader deactivated successfully" : "Trader was not active");
		sendJson(exchange, 200, result);
	}

	// ==================== Helpers ====================

	private Map<String, Object> zoneToMap(TradeZoneInfo zone)
	{
		Map<String, Object> m = new LinkedHashMap<>();
		m.put("id", zone.getId());
		m.put("name", zone.getName());
		m.put("x1", zone.getX1());
		m.put("y1", zone.getY1());
		m.put("x2", zone.getX2());
		m.put("y2", zone.getY2());
		m.put("z", zone.getZ());
		m.put("maxTraders", zone.getMaxTraders());
		m.put("activeTraders", AutobotsManager.getInstance().getActiveTraderCountInZone(zone.getId()));
		return m;
	}

	private Map<String, Object> traderToMap(TraderInfo trader)
	{
		Map<String, Object> m = new LinkedHashMap<>();
		m.put("id", trader.getId());
		m.put("botId", trader.getBotId());

		// Resolve bot name
		AutobotInfo botInfo = AutobotsDAO.getInstance().loadById(trader.getBotId());
		m.put("botName", botInfo != null ? botInfo.getName() : "Unknown");

		m.put("zoneId", trader.getZoneId());

		// Resolve zone name
		TradeZoneInfo zone = TradeBotsDAO.getInstance().loadTradeZone(trader.getZoneId());
		m.put("zoneName", zone != null ? zone.getName() : "Unknown");

		m.put("slotIndex", trader.getSlotIndex());
		m.put("tradeType", trader.getTradeType());
		m.put("storeName", trader.getStoreName());
		m.put("items", trader.getItems());
		m.put("isActive", AutobotsManager.getInstance().isTraderActive(trader.getId()));
		return m;
	}

	private List<TradeItemConfig> parseItems(JsonArray arr)
	{
		List<TradeItemConfig> items = new ArrayList<>();
		if(arr == null) return items;
		for(JsonElement elem : arr)
		{
			JsonObject obj = elem.getAsJsonObject();
			TradeItemConfig cfg = new TradeItemConfig();
			cfg.setItemId(obj.get("itemId").getAsInt());
			cfg.setCount(obj.get("count").getAsLong());
			cfg.setPrice(obj.get("price").getAsLong());
			items.add(cfg);
		}
		return items;
	}

	private JsonObject parseBody(HttpExchange exchange) throws IOException
	{
		try(InputStreamReader reader = new InputStreamReader(exchange.getRequestBody(), StandardCharsets.UTF_8))
		{
			return new JsonParser().parse(reader).getAsJsonObject();
		}
		catch(Exception e)
		{
			return null;
		}
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

	private int extractZoneIdFromAction(String path, String action)
	{
		// /api/trade/zones/{id}/action
		try
		{
			String stripped = path.replace("/api/trade/zones/", "").replace("/" + action, "");
			return Integer.parseInt(stripped);
		}
		catch(Exception e)
		{
			return -1;
		}
	}

	private int extractTraderIdFromAction(String path, String action)
	{
		// /api/trade/traders/{id}/action
		try
		{
			String stripped = path.replace("/api/trade/traders/", "").replace("/" + action, "");
			return Integer.parseInt(stripped);
		}
		catch(Exception e)
		{
			return -1;
		}
	}

	private int getInt(JsonObject obj, String key, int def)
	{
		return obj.has(key) ? obj.get(key).getAsInt() : def;
	}
}
