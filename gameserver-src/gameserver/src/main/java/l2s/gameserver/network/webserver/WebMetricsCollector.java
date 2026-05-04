package l2s.gameserver.network.webserver;

import com.sun.management.OperatingSystemMXBean;
import java.lang.management.ManagementFactory;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.commons.lang.StatsUtils;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.model.World;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Ring buffer of dashboard samples (players online, heap, process CPU, threads).
 * Filled on a fixed interval while the web server is enabled.
 */
public class WebMetricsCollector
{
	private static final Logger _log = LoggerFactory.getLogger(WebMetricsCollector.class);
	private static final WebMetricsCollector INSTANCE = new WebMetricsCollector();

	/** ~1 hour of history at 10 s step */
	private static final int MAX_SAMPLES = 360;
	private static final long SAMPLE_PERIOD_MS = 10000L;
	private static final long FIRST_SAMPLE_DELAY_MS = 3000L;

	private final ArrayList<Sample> _samples = new ArrayList<>();
	private volatile boolean _started;

	public static WebMetricsCollector getInstance()
	{
		return INSTANCE;
	}

	public static final class Sample
	{
		public final long timestampMs;
		/** Active characters (not offline-trade), same basis as telnet status */
		public final int playersOnline;
		public final int heapUsedMb;
		/** -1 if unavailable */
		public final double cpuPercent;
		public final int threadCount;

		public Sample(long timestampMs, int playersOnline, int heapUsedMb, double cpuPercent, int threadCount)
		{
			this.timestampMs = timestampMs;
			this.playersOnline = playersOnline;
			this.heapUsedMb = heapUsedMb;
			this.cpuPercent = cpuPercent;
			this.threadCount = threadCount;
		}
	}

	private WebMetricsCollector()
	{
	}

	public void start()
	{
		if(_started || !Config.WEB_SERVER_ENABLED)
			return;
		_started = true;
		ThreadPoolManager.getInstance().scheduleAtFixedRate(this::tickSafe, FIRST_SAMPLE_DELAY_MS, SAMPLE_PERIOD_MS);
	}

	private void tickSafe()
	{
		try
		{
			tick();
		}
		catch(Exception e)
		{
			_log.debug("WebMetricsCollector tick: " + e.getMessage());
		}
	}

	private void tick()
	{
		int[] st = World.getStats();
		int online = Math.max(0, st[12] - st[13]);
		int heapMb = (int)(StatsUtils.getMemUsed() / 0x100000L);
		double cpu = readProcessCpuPercent();
		int threads = ManagementFactory.getThreadMXBean().getThreadCount();
		long t = System.currentTimeMillis();
		synchronized(_samples)
		{
			_samples.add(new Sample(t, online, heapMb, cpu, threads));
			while(_samples.size() > MAX_SAMPLES)
				_samples.remove(0);
		}
	}

	private static double readProcessCpuPercent()
	{
		try
		{
			OperatingSystemMXBean os = (OperatingSystemMXBean) ManagementFactory.getOperatingSystemMXBean();
			double v = os.getProcessCpuLoad();
			if(v < 0D || Double.isNaN(v))
				return -1D;
			return v * 100D;
		}
		catch(Throwable t)
		{
			return -1D;
		}
	}

	public List<Sample> getSamplesSnapshot()
	{
		synchronized(_samples)
		{
			return Collections.unmodifiableList(new ArrayList<>(_samples));
		}
	}
}
