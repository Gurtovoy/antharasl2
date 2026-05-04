package l2s.gameserver.model.autobot;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.model.base.Race;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

/**
 * Dynamic starter-pack progression loaded from XML files under {@code data/fake_players/farm/race}.
 */
public final class StarterPackFarmProgression
{
	public static final class RaceFarmStage
	{
		public final int stageIndex;
		public final int minLevel;
		public final int maxLevel;
		public final int farmRadius;
		public final int farmHeight;
		public final String sourceFile;
		public final String farmName;
		private final List<int[]> spawnPoints;

		public RaceFarmStage(int stageIndex, int minLevel, int maxLevel, int farmRadius, int farmHeight, String sourceFile, String farmName, List<int[]> spawnPoints)
		{
			this.stageIndex = stageIndex;
			this.minLevel = minLevel;
			this.maxLevel = maxLevel;
			this.farmRadius = farmRadius;
			this.farmHeight = farmHeight;
			this.sourceFile = sourceFile;
			this.farmName = farmName;
			this.spawnPoints = spawnPoints;
		}

		public int[] getRandomSpawn()
		{
			if(spawnPoints == null || spawnPoints.isEmpty())
				return null;
			return spawnPoints.get(Rnd.get(spawnPoints.size()));
		}

		public int getSpawnCount()
		{
			return spawnPoints == null ? 0 : spawnPoints.size();
		}
	}

	private static final int DEFAULT_RADIUS = 1200;
	private static final int DEFAULT_HEIGHT = 320;
	private static final Pattern STAGE_INDEX_PATTERN = Pattern.compile("\\[(\\d+)\\]");
	private static final Map<Race, List<RaceFarmStage>> STAGES_BY_RACE = new HashMap<>();

	static
	{
		loadFromXml();
	}

	private static void loadFromXml()
	{
		STAGES_BY_RACE.clear();
		try
		{
			File root = new File(Config.DATAPACK_ROOT, "data/fake_players/farm/race");
			loadRace(root, "human", Race.HUMAN);
			loadRace(root, "elf", Race.ELF);
			loadRace(root, "darkelf", Race.DARKELF);
			loadRace(root, "orc", Race.ORC);
			loadRace(root, "dwarven", Race.DWARF);
		}
		catch(Exception ignored)
		{
		}
	}

	private static void loadRace(File root, String folder, Race race) throws Exception
	{
		File dir = new File(root, folder);
		File[] files = dir.listFiles((d, name) -> name.toLowerCase().endsWith(".xml"));
		if(files == null || files.length == 0)
			return;

		List<RaceFarmStage> stages = new ArrayList<>();
		SAXReader reader = new SAXReader();
		reader.setValidation(false);

		for(File file : files)
		{
			Document doc = reader.read(file);
			Element rootElement = doc.getRootElement();
			if(rootElement == null || !"farm".equalsIgnoreCase(rootElement.getName()))
				continue;

			int min = parseInt(rootElement.attributeValue("min_level"), 1);
			int max = parseInt(rootElement.attributeValue("max_level"), 1);
			String farmName = rootElement.attributeValue("name");
			Element spawnElement = rootElement.element("zones") != null ? rootElement.element("zones").element("spawn_points") : null;
			if(spawnElement == null)
				continue;

			List<int[]> spawns = new ArrayList<>();
			for(Object o : spawnElement.elements("coords"))
			{
				Element coords = (Element) o;
				int[] loc = parseLoc(coords.attributeValue("loc"));
				if(loc != null)
					spawns.add(loc);
			}
			if(spawns.isEmpty())
				continue;

			int stageIndex = parseStageIndex(file.getName(), min);
			stages.add(new RaceFarmStage(stageIndex, min, max, DEFAULT_RADIUS, DEFAULT_HEIGHT, file.getName(), farmName, spawns));
		}

		stages.sort((a, b) -> Integer.compare(a.stageIndex, b.stageIndex));
		STAGES_BY_RACE.put(race, stages);
	}

	private static int parseInt(String value, int def)
	{
		try
		{
			return Integer.parseInt(value);
		}
		catch(Exception e)
		{
			return def;
		}
	}

	private static int parseStageIndex(String fileName, int fallback)
	{
		Matcher m = STAGE_INDEX_PATTERN.matcher(fileName);
		if(m.find())
			return parseInt(m.group(1), fallback);
		return fallback;
	}

	private static int[] parseLoc(String loc)
	{
		if(loc == null)
			return null;
		String[] parts = loc.trim().split("\\s+");
		if(parts.length < 3)
			return null;
		try
		{
			return new int[] {Integer.parseInt(parts[0]), Integer.parseInt(parts[1]), Integer.parseInt(parts[2])};
		}
		catch(Exception e)
		{
			return null;
		}
	}

	public static RaceFarmStage getNextStage(Race race, int currentStage, int level)
	{
		List<RaceFarmStage> stages = STAGES_BY_RACE.get(race);
		if(stages == null || stages.isEmpty())
			return null;

		RaceFarmStage candidate = null;
		for(RaceFarmStage stage : stages)
		{
			if(stage.stageIndex <= currentStage)
				continue;
			if(level <= stage.maxLevel)
				return stage;
			candidate = stage;
		}
		return candidate;
	}

	public static RaceFarmStage getCurrentStage(Race race, int stageIndex)
	{
		List<RaceFarmStage> stages = STAGES_BY_RACE.get(race);
		if(stages == null)
			return null;
		for(RaceFarmStage stage : stages)
		{
			if(stage.stageIndex == stageIndex)
				return stage;
		}
		return null;
	}
}
