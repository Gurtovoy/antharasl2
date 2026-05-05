package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.HttpExchange;
import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardOpenOption;
import java.util.LinkedHashMap;
import java.util.Map;
import l2s.gameserver.Config;

/**
 * Read / write gameserver property files used by the web panel (server.properties,
 * server_stages.properties, altsettings.properties). Paths match {@link Config#load(String)} (working directory relative).
 */
public class ServerConfigFilesApiHandler extends ApiHandler
{
	private static final String PREFIX = "/api/server/config-files";

	private static final String KEY_SERVER = "server";
	private static final String KEY_STAGES = "stages";
	private static final String KEY_ALT = "altsettings";

	private static String resolveRelativePath(String key)
	{
		switch(key)
		{
			case KEY_SERVER:
				return Config.CONFIGURATION_FILE;
			case KEY_STAGES:
				return "config/server_stages.properties";
			case KEY_ALT:
				return Config.ALT_SETTINGS_FILE;
			default:
				return null;
		}
	}

	private static File resolveFile(String key)
	{
		String rel = resolveRelativePath(key);
		if(rel == null)
			return null;
		return new File(rel).getAbsoluteFile();
	}

	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		String method = exchange.getRequestMethod();
		String path = exchange.getRequestURI().getPath();

		if(!path.startsWith(PREFIX))
		{
			sendError(exchange, 404, "Not found");
			return;
		}

		String sub = path.length() > PREFIX.length() ? path.substring(PREFIX.length()) : "";
		if(sub.startsWith("/"))
			sub = sub.substring(1);
		if(sub.endsWith("/"))
			sub = sub.substring(0, sub.length() - 1);

		if("GET".equals(method) && sub.isEmpty())
		{
			handleGetAll(exchange);
			return;
		}

		if("GET".equals(method) && !sub.isEmpty())
		{
			handleGetOne(exchange, sub);
			return;
		}

		if("PUT".equals(method) && !sub.isEmpty())
		{
			handlePutOne(exchange, sub);
			return;
		}

		sendError(exchange, 404, "Not found: " + method + " " + path);
	}

	private void handleGetAll(HttpExchange exchange) throws IOException
	{
		Map<String, Object> out = new LinkedHashMap<>();
		for(String key : new String[] { KEY_SERVER, KEY_STAGES, KEY_ALT })
		{
			out.put(key, buildEntry(key));
		}
		sendJson(exchange, 200, out);
	}

	private Map<String, Object> buildEntry(String key) throws IOException
	{
		String rel = resolveRelativePath(key);
		File f = resolveFile(key);
		Map<String, Object> m = new LinkedHashMap<>();
		m.put("relativePath", rel);
		m.put("content", readUtf8(f));
		return m;
	}

	private void handleGetOne(HttpExchange exchange, String key) throws IOException
	{
		if(resolveRelativePath(key) == null)
		{
			sendError(exchange, 400, "Unknown config key: " + key);
			return;
		}
		sendJson(exchange, 200, buildEntry(key));
	}

	private void handlePutOne(HttpExchange exchange, String key) throws IOException
	{
		if(resolveRelativePath(key) == null)
		{
			sendError(exchange, 400, "Unknown config key: " + key);
			return;
		}
		ConfigFilePayload body = parseJson(exchange, ConfigFilePayload.class);
		if(body == null)
		{
			sendError(exchange, 400, "Expected JSON: { \"content\": \"...\" }");
			return;
		}
		if(body.content == null)
		{
			sendError(exchange, 400, "Missing \"content\"");
			return;
		}

		File f = resolveFile(key);
		File parent = f.getParentFile();
		if(parent != null && !parent.exists() && !parent.mkdirs())
		{
			sendError(exchange, 500, "Cannot create directory: " + parent.getAbsolutePath());
			return;
		}

		Files.write(f.toPath(), body.content.getBytes(StandardCharsets.UTF_8), StandardOpenOption.CREATE, StandardOpenOption.TRUNCATE_EXISTING, StandardOpenOption.WRITE);
		_log.info("WebServer: saved config file " + f.getAbsolutePath());

		Map<String, Object> ok = new LinkedHashMap<>();
		ok.put("ok", true);
		ok.put("relativePath", resolveRelativePath(key));
		sendJson(exchange, 200, ok);
	}

	private static String readUtf8(File f) throws IOException
	{
		if(!f.exists())
			return "";
		return new String(Files.readAllBytes(f.toPath()), StandardCharsets.UTF_8);
	}

	private static class ConfigFilePayload
	{
		String content;
	}
}
