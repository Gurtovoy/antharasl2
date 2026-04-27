package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.HashMap;
import java.util.Map;
import l2s.gameserver.Config;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class StaticFileHandler implements HttpHandler
{
	private static final Logger _log = LoggerFactory.getLogger(StaticFileHandler.class);

	private static final Map<String, String> MIME_TYPES = new HashMap<>();
	static
	{
		MIME_TYPES.put(".html", "text/html; charset=UTF-8");
		MIME_TYPES.put(".htm", "text/html; charset=UTF-8");
		MIME_TYPES.put(".js", "application/javascript; charset=UTF-8");
		MIME_TYPES.put(".css", "text/css; charset=UTF-8");
		MIME_TYPES.put(".json", "application/json; charset=UTF-8");
		MIME_TYPES.put(".png", "image/png");
		MIME_TYPES.put(".jpg", "image/jpeg");
		MIME_TYPES.put(".jpeg", "image/jpeg");
		MIME_TYPES.put(".gif", "image/gif");
		MIME_TYPES.put(".ico", "image/x-icon");
		MIME_TYPES.put(".svg", "image/svg+xml");
		MIME_TYPES.put(".woff", "font/woff");
		MIME_TYPES.put(".woff2", "font/woff2");
		MIME_TYPES.put(".ttf", "font/ttf");
	}

	@Override
	public void handle(HttpExchange exchange) throws IOException
	{
		exchange.getResponseHeaders().set("Access-Control-Allow-Origin", "*");

		if(!"GET".equals(exchange.getRequestMethod()))
		{
			exchange.sendResponseHeaders(405, -1);
			return;
		}

		String path = exchange.getRequestURI().getPath();

		// Default to index.html for root
		if("/".equals(path) || path.isEmpty())
		{
			path = "/index.html";
		}

		// Security: prevent path traversal
		if(path.contains("..") || path.contains("\\"))
		{
			exchange.sendResponseHeaders(403, -1);
			return;
		}

		File webRoot = new File(Config.DATAPACK_ROOT, "data/webserver");
		File file = new File(webRoot, path);

		// Verify the file is within the webserver directory
		try
		{
			if(!file.getCanonicalPath().startsWith(webRoot.getCanonicalPath()))
			{
				exchange.sendResponseHeaders(403, -1);
				return;
			}
		}
		catch(IOException e)
		{
			exchange.sendResponseHeaders(403, -1);
			return;
		}

		if(!file.exists() || !file.isFile())
		{
			// For SPA: serve index.html for non-file paths
			File indexFile = new File(webRoot, "index.html");
			if(indexFile.exists() && !path.startsWith("/api/"))
			{
				file = indexFile;
			}
			else
			{
				String notFound = "404 Not Found";
				byte[] bytes = notFound.getBytes();
				exchange.sendResponseHeaders(404, bytes.length);
				try(OutputStream os = exchange.getResponseBody())
				{
					os.write(bytes);
				}
				return;
			}
		}

		String contentType = getContentType(file.getName());
		exchange.getResponseHeaders().set("Content-Type", contentType);
		exchange.sendResponseHeaders(200, file.length());

		try(FileInputStream fis = new FileInputStream(file); OutputStream os = exchange.getResponseBody())
		{
			byte[] buffer = new byte[8192];
			int bytesRead;
			while((bytesRead = fis.read(buffer)) != -1)
			{
				os.write(buffer, 0, bytesRead);
			}
		}
		catch(Exception e)
		{
			_log.error("StaticFileHandler error serving " + path + ": " + e.getMessage(), e);
		}
	}

	private String getContentType(String fileName)
	{
		int dotIndex = fileName.lastIndexOf('.');
		if(dotIndex >= 0)
		{
			String ext = fileName.substring(dotIndex).toLowerCase();
			String type = MIME_TYPES.get(ext);
			if(type != null)
				return type;
		}
		return "application/octet-stream";
	}
}
