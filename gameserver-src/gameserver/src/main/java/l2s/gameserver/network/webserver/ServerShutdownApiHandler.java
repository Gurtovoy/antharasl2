package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import l2s.gameserver.Shutdown;

/**
 * Schedule or cancel server shutdown / restart (same timers as GM/telnet {@link Shutdown}).
 */
public class ServerShutdownApiHandler extends ApiHandler
{
	private static final int MAX_DELAY_SECONDS = 86400 * 7;

	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		String path = exchange.getRequestURI().getPath();
		if(path.endsWith("/cancel"))
		{
			if("POST".equals(exchange.getRequestMethod()))
				handleCancel(exchange);
			else
				sendError(exchange, 405, "Method not allowed");
			return;
		}

		if("GET".equals(exchange.getRequestMethod()))
		{
			handleGet(exchange);
			return;
		}
		if("POST".equals(exchange.getRequestMethod()))
		{
			handleSchedule(exchange);
			return;
		}
		sendError(exchange, 405, "Method not allowed");
	}

	private void handleGet(HttpExchange exchange) throws IOException
	{
		Shutdown sd = Shutdown.getInstance();
		int mode = sd.getMode();
		int sec = sd.getSeconds();

		Map<String, Object> result = new LinkedHashMap<>();
		if(mode == Shutdown.NONE || sec < 0)
		{
			result.put("active", Boolean.FALSE);
			result.put("mode", "none");
			result.put("secondsRemaining", -1);
		}
		else
		{
			result.put("active", Boolean.TRUE);
			result.put("mode", mode == Shutdown.SHUTDOWN ? "shutdown" : "restart");
			result.put("secondsRemaining", sec);
		}
		sendJson(exchange, 200, result);
	}

	private void handleSchedule(HttpExchange exchange) throws IOException
	{
		Map<?, ?> body = parseJson(exchange, Map.class);
		if(body == null)
		{
			sendError(exchange, 400, "Invalid JSON body");
			return;
		}

		Object secObj = body.get("seconds");
		Object modeObj = body.get("mode");
		if(secObj == null || modeObj == null)
		{
			sendError(exchange, 400, "Required: seconds (number), mode (shutdown|restart)");
			return;
		}

		int seconds;
		try
		{
			if(secObj instanceof Number)
				seconds = ((Number) secObj).intValue();
			else
				seconds = Integer.parseInt(String.valueOf(secObj).trim());
		}
		catch(NumberFormatException e)
		{
			sendError(exchange, 400, "Invalid seconds");
			return;
		}

		if(seconds < 0 || seconds > MAX_DELAY_SECONDS)
		{
			sendError(exchange, 400, "seconds must be between 0 and " + MAX_DELAY_SECONDS);
			return;
		}

		String modeStr = String.valueOf(modeObj).trim().toLowerCase();
		int shutdownMode;
		if("shutdown".equals(modeStr))
			shutdownMode = Shutdown.SHUTDOWN;
		else if("restart".equals(modeStr))
			shutdownMode = Shutdown.RESTART;
		else
		{
			sendError(exchange, 400, "mode must be shutdown or restart");
			return;
		}

		Shutdown.getInstance().schedule(seconds, shutdownMode);

		Map<String, Object> result = new LinkedHashMap<>();
		result.put("ok", Boolean.TRUE);
		result.put("seconds", seconds);
		result.put("mode", modeStr);
		sendJson(exchange, 200, result);
	}

	private void handleCancel(HttpExchange exchange) throws IOException
	{
		Shutdown.getInstance().cancel();
		Map<String, Object> result = new LinkedHashMap<>();
		result.put("ok", Boolean.TRUE);
		result.put("cancelled", Boolean.TRUE);
		sendJson(exchange, 200, result);
	}
}
