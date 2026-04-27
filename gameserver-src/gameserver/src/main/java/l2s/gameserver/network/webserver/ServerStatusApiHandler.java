package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import l2s.gameserver.Config;
import l2s.gameserver.GameServer;
import l2s.gameserver.dao.AutobotsDAO;
import l2s.gameserver.instancemanager.AutobotsManager;

public class ServerStatusApiHandler extends ApiHandler
{
	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		if(!"GET".equals(exchange.getRequestMethod()))
		{
			sendError(exchange, 405, "Method not allowed");
			return;
		}

		int totalBots = AutobotsDAO.getInstance().countBots(null);
		int onlineBots = AutobotsManager.getInstance().getActiveBotCount();
		int offlineBots = totalBots - onlineBots;

		long uptimeMs = 0;
		GameServer gs = GameServer.getInstance();
		if(gs != null)
		{
			uptimeMs = System.currentTimeMillis() - gs.getServerStartTime();
		}

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("totalBots", totalBots);
		result.put("onlineBots", onlineBots);
		result.put("offlineBots", offlineBots);
		result.put("webServerPort", Config.WEB_SERVER_PORT);
		result.put("serverUptime", uptimeMs);

		sendJson(exchange, 200, result);
	}
}
