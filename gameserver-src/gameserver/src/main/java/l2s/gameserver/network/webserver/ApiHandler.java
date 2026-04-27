package l2s.gameserver.network.webserver;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class ApiHandler implements HttpHandler
{
	protected static final Logger _log = LoggerFactory.getLogger(ApiHandler.class);
	protected static final Gson GSON = new Gson();

	@Override
	public void handle(HttpExchange exchange) throws IOException
	{
		// Add CORS headers
		exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
		exchange.getResponseHeaders().set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
		exchange.getResponseHeaders().set("Access-Control-Allow-Headers", "Content-Type, X-Api-Key");

		if("OPTIONS".equalsIgnoreCase(exchange.getRequestMethod()))
		{
			exchange.sendResponseHeaders(204, -1);
			return;
		}

		try
		{
			handleRequest(exchange);
		}
		catch(Exception e)
		{
			_log.error("WebServer API error: " + e.getMessage(), e);
			sendError(exchange, 500, "Internal server error: " + e.getMessage());
		}
	}

	protected abstract void handleRequest(HttpExchange exchange) throws IOException;

	protected <T> T parseJson(HttpExchange exchange, Class<T> clazz) throws IOException
	{
		try(InputStreamReader reader = new InputStreamReader(exchange.getRequestBody(), StandardCharsets.UTF_8))
		{
			return GSON.fromJson(reader, clazz);
		}
		catch(JsonSyntaxException e)
		{
			return null;
		}
	}

	protected void sendJson(HttpExchange exchange, int statusCode, Object data) throws IOException
	{
		String json = GSON.toJson(data);
		byte[] bytes = json.getBytes(StandardCharsets.UTF_8);
		exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
		exchange.sendResponseHeaders(statusCode, bytes.length);
		try(OutputStream os = exchange.getResponseBody())
		{
			os.write(bytes);
		}
	}

	protected void sendError(HttpExchange exchange, int statusCode, String message) throws IOException
	{
		Map<String, Object> error = new LinkedHashMap<>();
		error.put("error", message);
		error.put("status", statusCode);
		sendJson(exchange, statusCode, error);
	}

	protected String getPathParam(HttpExchange exchange, String prefix)
	{
		String path = exchange.getRequestURI().getPath();
		if(path.startsWith(prefix))
		{
			String param = path.substring(prefix.length());
			// Remove trailing slash if present
			if(param.endsWith("/"))
				param = param.substring(0, param.length() - 1);
			return param;
		}
		return null;
	}

	protected String getQueryParam(HttpExchange exchange, String name)
	{
		String query = exchange.getRequestURI().getRawQuery();
		if(query == null || query.isEmpty())
			return null;

		for(String param : query.split("&"))
		{
			String[] pair = param.split("=", 2);
			if(pair.length == 2 && pair[0].equals(name))
			{
				try
				{
					return URLDecoder.decode(pair[1], "UTF-8");
				}
				catch(Exception e)
				{
					return pair[1];
				}
			}
		}
		return null;
	}

	protected int getIntQueryParam(HttpExchange exchange, String name, int defaultValue)
	{
		String val = getQueryParam(exchange, name);
		if(val == null)
			return defaultValue;
		try
		{
			return Integer.parseInt(val);
		}
		catch(NumberFormatException e)
		{
			return defaultValue;
		}
	}
}
