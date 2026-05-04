package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class DashboardMetricsApiHandler extends ApiHandler
{
	private static final long SAMPLE_PERIOD_MS = 10000L;
	private static final int MAX_SAMPLES = 360;

	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		if(!"GET".equals(exchange.getRequestMethod()))
		{
			sendError(exchange, 405, "Method not allowed");
			return;
		}

		String path = exchange.getRequestURI().getPath();
		if(path.endsWith("/history"))
			handleHistory(exchange);
		else
			sendError(exchange, 404, "Use GET /api/server/metrics/history");
	}

	private void handleHistory(HttpExchange exchange) throws IOException
	{
		List<WebMetricsCollector.Sample> samples = WebMetricsCollector.getInstance().getSamplesSnapshot();
		List<Map<String, Object>> rows = new ArrayList<>();
		for(WebMetricsCollector.Sample s : samples)
		{
			Map<String, Object> row = new LinkedHashMap<>();
			row.put("t", s.timestampMs);
			row.put("online", s.playersOnline);
			row.put("heapMb", s.heapUsedMb);
			row.put("cpuPercent", s.cpuPercent);
			row.put("threads", s.threadCount);
			rows.add(row);
		}

		Map<String, Object> body = new LinkedHashMap<>();
		body.put("intervalMs", SAMPLE_PERIOD_MS);
		body.put("maxSamples", MAX_SAMPLES);
		body.put("samples", rows);

		sendJson(exchange, 200, body);
	}
}
