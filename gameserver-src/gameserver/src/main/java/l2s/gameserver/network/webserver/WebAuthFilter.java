package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.Filter;
import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import l2s.gameserver.Config;

public class WebAuthFilter extends Filter
{
	@Override
	public void doFilter(HttpExchange exchange, Chain chain) throws IOException
	{
		String path = exchange.getRequestURI().getPath();

		// Skip auth for OPTIONS (CORS preflight)
		if("OPTIONS".equalsIgnoreCase(exchange.getRequestMethod()))
		{
			chain.doFilter(exchange);
			return;
		}

		// Skip auth for static files
		if(!path.startsWith("/api/"))
		{
			chain.doFilter(exchange);
			return;
		}

		// Check API key from header or query param
		String apiKey = exchange.getRequestHeaders().getFirst("X-Api-Key");
		if(apiKey == null || apiKey.isEmpty())
		{
			apiKey = getQueryParam(exchange, "apiKey");
		}

		if(apiKey == null || !apiKey.equals(Config.WEB_SERVER_API_KEY))
		{
			String json = "{\"error\":\"Unauthorized\",\"status\":401}";
			byte[] bytes = json.getBytes(StandardCharsets.UTF_8);
			exchange.getResponseHeaders().set("Content-Type", "application/json; charset=UTF-8");
			exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");
			exchange.sendResponseHeaders(401, bytes.length);
			try(OutputStream os = exchange.getResponseBody())
			{
				os.write(bytes);
			}
			return;
		}

		chain.doFilter(exchange);
	}

	@Override
	public String description()
	{
		return "API Key Authentication Filter";
	}

	private String getQueryParam(HttpExchange exchange, String name)
	{
		String query = exchange.getRequestURI().getRawQuery();
		if(query == null)
			return null;
		for(String param : query.split("&"))
		{
			String[] pair = param.split("=", 2);
			if(pair.length == 2 && pair[0].equals(name))
				return pair[1];
		}
		return null;
	}
}
