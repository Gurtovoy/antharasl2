package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import l2s.gameserver.Config;
import l2s.gameserver.instancemanager.StarterPackManager;

public class StarterPackApiHandler extends ApiHandler
{
	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		String method = exchange.getRequestMethod();
		String path = exchange.getRequestURI().getPath();

		// GET /api/starterpack/status
		if("GET".equals(method) && path.equals("/api/starterpack/status"))
		{
			handleStatus(exchange);
			return;
		}

		// POST /api/starterpack/start
		if("POST".equals(method) && path.equals("/api/starterpack/start"))
		{
			handleStart(exchange);
			return;
		}

		// POST /api/starterpack/stop
		if("POST".equals(method) && path.equals("/api/starterpack/stop"))
		{
			handleStop(exchange);
			return;
		}

		sendError(exchange, 404, "Not found: " + method + " " + path);
	}

	private void handleStatus(HttpExchange exchange) throws IOException
	{
		StarterPackManager mgr = StarterPackManager.getInstance();
		Map<String, Integer> counts = mgr.getStatusCounts();

		Map<String, Object> response = new LinkedHashMap<>();
		response.put("total", counts.get("total"));
		response.put("farming", counts.get("farming"));
		response.put("walking", counts.get("walking"));
		response.put("inTown", counts.get("inTown"));
		response.put("maxBots", Config.STARTER_PACK_MAX_BOTS);
		response.put("enabled", Config.STARTER_PACK_ENABLED);

		sendJson(exchange, 200, response);
	}

	private void handleStart(HttpExchange exchange) throws IOException
	{
		if(!Config.STARTER_PACK_ENABLED)
		{
			Map<String, Object> resp = new LinkedHashMap<>();
			resp.put("success", false);
			resp.put("message", "Starter pack is disabled in config");
			sendJson(exchange, 400, resp);
			return;
		}

		Map<?, ?> body = parseJson(exchange, Map.class);
		int count = 50; // default
		if(body != null && body.containsKey("count"))
		{
			Object val = body.get("count");
			if(val instanceof Number)
			{
				count = ((Number) val).intValue();
			}
		}

		if(count <= 0)
		{
			Map<String, Object> resp = new LinkedHashMap<>();
			resp.put("success", false);
			resp.put("message", "Count must be positive");
			sendJson(exchange, 400, resp);
			return;
		}

		StarterPackManager.getInstance().spawnStarterBots(count);

		Map<String, Object> resp = new LinkedHashMap<>();
		resp.put("success", true);
		resp.put("message", "Spawning " + count + " starter bots");
		sendJson(exchange, 200, resp);
	}

	private void handleStop(HttpExchange exchange) throws IOException
	{
		StarterPackManager.getInstance().despawnAllBots();

		Map<String, Object> resp = new LinkedHashMap<>();
		resp.put("success", true);
		resp.put("message", "All starter bots despawned");
		sendJson(exchange, 200, resp);
	}
}
