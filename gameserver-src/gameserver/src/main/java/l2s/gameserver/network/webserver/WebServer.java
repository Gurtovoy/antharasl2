package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.HttpContext;
import com.sun.net.httpserver.HttpServer;
import java.io.File;
import java.net.InetSocketAddress;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import l2s.gameserver.Config;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class WebServer
{
	private static final Logger _log = LoggerFactory.getLogger(WebServer.class);
	private static final WebServer _instance = new WebServer();

	private HttpServer _server;
	private ExecutorService _executor;

	public static WebServer getInstance()
	{
		return _instance;
	}

	private WebServer()
	{
	}

	public void init()
	{
		ExecutorService newExecutor = null;
		try
		{
			if(_server != null)
			{
				shutdown();
			}

			InetSocketAddress addr = new InetSocketAddress(Config.WEB_SERVER_BIND_ADDRESS, Config.WEB_SERVER_PORT);
			newExecutor = Executors.newFixedThreadPool(4, r -> {
				Thread t = new Thread(r, "WebServer-Worker");
				t.setDaemon(true);
				return t;
			});
			_server = HttpServer.create(addr, 0);
			_server.setExecutor(newExecutor);

			WebAuthFilter authFilter = new WebAuthFilter();

			// API routes — order matters: more specific paths first
			// Schedule API (must be before autobots catch-all)
			HttpContext scheduleCtx = _server.createContext("/api/autobots/schedule", new ScheduleApiHandler());
			scheduleCtx.getFilters().add(authFilter);

			// Autobots API
			HttpContext autobotsCtx = _server.createContext("/api/autobots", new AutobotsApiHandler());
			autobotsCtx.getFilters().add(authFilter);

			// Trade Bots API
			HttpContext tradeCtx = _server.createContext("/api/trade", new TradeApiHandler());
			tradeCtx.getFilters().add(authFilter);

			// Server config files (properties): GET/PUT under /api/server/config-files
			HttpContext configFilesCtx = _server.createContext("/api/server/config-files", new ServerConfigFilesApiHandler());
			configFilesCtx.getFilters().add(authFilter);

			// Server status API
			HttpContext statusCtx = _server.createContext("/api/server/status", new ServerStatusApiHandler());
			statusCtx.getFilters().add(authFilter);

			// Server shutdown / restart (prefix matches /api/server/shutdown/cancel)
			HttpContext shutdownCtx = _server.createContext("/api/server/shutdown", new ServerShutdownApiHandler());
			shutdownCtx.getFilters().add(authFilter);

			// Dashboard metrics: GET /api/server/metrics/history
			HttpContext metricsCtx = _server.createContext("/api/server/metrics", new DashboardMetricsApiHandler());
			metricsCtx.getFilters().add(authFilter);

			// Starter Pack API
			HttpContext starterPackCtx = _server.createContext("/api/starterpack", new StarterPackApiHandler());
			starterPackCtx.getFilters().add(authFilter);

			// Static file serving
			File webRoot = new File(Config.DATAPACK_ROOT, "data/webserver");
			if(!webRoot.exists())
			{
				webRoot.mkdirs();
				_log.info("WebServer: Created webserver directory at " + webRoot.getAbsolutePath());
			}
			_server.createContext("/", new StaticFileHandler());

			_server.start();
			_executor = newExecutor;
			newExecutor = null;
			WebMetricsCollector.getInstance().start();
			_log.info("WebServer: Started on " + Config.WEB_SERVER_BIND_ADDRESS + ":" + Config.WEB_SERVER_PORT);
		}
		catch(Exception e)
		{
			if(_server != null)
			{
				try
				{
					_server.stop(0);
				}
				catch(Exception stopEx)
				{
					_log.debug("WebServer: stop during failed init: " + stopEx.getMessage());
				}
				_server = null;
			}
			if(newExecutor != null)
			{
				newExecutor.shutdownNow();
			}
			_executor = null;
			_log.error("WebServer: Failed to start: " + e.getMessage(), e);
		}
	}

	public void shutdown()
	{
		if(_server != null)
		{
			_server.stop(1);
			_server = null;
		}
		if(_executor != null)
		{
			_executor.shutdown();
			try
			{
				if(!_executor.awaitTermination(30L, TimeUnit.SECONDS))
				{
					_executor.shutdownNow();
					_executor.awaitTermination(10L, TimeUnit.SECONDS);
				}
			}
			catch(InterruptedException e)
			{
				Thread.currentThread().interrupt();
				_executor.shutdownNow();
			}
			finally
			{
				_executor = null;
			}
		}
		_log.info("WebServer: Stopped.");
	}
}
