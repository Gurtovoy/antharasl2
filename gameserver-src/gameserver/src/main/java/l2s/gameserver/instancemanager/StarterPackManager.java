package l2s.gameserver.instancemanager;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;

import l2s.commons.dbutils.DbUtils;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.StarterPackAI;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.database.DatabaseFactory;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.autobot.StarterBotState;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.network.l2.c2s.CharacterCreate;
import l2s.gameserver.network.l2.c2s.EnterWorld;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class StarterPackManager
{
	private static final Logger _log = LoggerFactory.getLogger(StarterPackManager.class);
	private static final StarterPackManager _instance = new StarterPackManager();

	// Active starter bots
	private final ConcurrentHashMap<Integer, StarterBotState> _activeBots = new ConcurrentHashMap<>();

	// Available names loaded from file
	private final List<String> _availableNames = new ArrayList<>();
	private final Set<String> _usedNames = ConcurrentHashMap.newKeySet();

	// Starting class configs
	// Fixed class IDs: must match ClassId enum ordinals for base classes (ClassLevel.NONE)
	// 0=HumanFighter, 10=HumanMage, 18=ElfFighter, 25=ElfMage, 31=DarkElfFighter,
	// 38=DarkElfMage, 44=OrcFighter, 49=OrcMage, 53=DwarfFighter
	private static final int[] STARTER_CLASSES = {0, 10, 18, 25, 31, 38, 44, 49, 53};

	// Class ID -> starting location (x, y, z)
	private static final Map<Integer, int[]> START_LOCATIONS = new HashMap<>();
	// Class ID -> nearest town location (x, y, z)
	private static final Map<Integer, int[]> TOWN_LOCATIONS = new HashMap<>();

	static
	{
		// Human Fighter
		START_LOCATIONS.put(0, new int[]{-71400, 258320, -3104});
		TOWN_LOCATIONS.put(0, new int[]{-84318, 244579, -3730});
		// Human Mage
		START_LOCATIONS.put(10, new int[]{-90880, 248090, -3570});
		TOWN_LOCATIONS.put(10, new int[]{-84318, 244579, -3730});
		// Elf Fighter
		START_LOCATIONS.put(18, new int[]{46080, 41190, -3440});
		TOWN_LOCATIONS.put(18, new int[]{46934, 51467, -2977});
		// Elf Mage
		START_LOCATIONS.put(25, new int[]{46080, 41190, -3440});
		TOWN_LOCATIONS.put(25, new int[]{46934, 51467, -2977});
		// Dark Elf Fighter
		START_LOCATIONS.put(31, new int[]{28380, 11020, -4224});
		TOWN_LOCATIONS.put(31, new int[]{12111, 16686, -4584});
		// Dark Elf Mage
		START_LOCATIONS.put(38, new int[]{28380, 11020, -4224});
		TOWN_LOCATIONS.put(38, new int[]{12111, 16686, -4584});
		// Orc Fighter
		START_LOCATIONS.put(44, new int[]{-56715, -113600, -690});
		TOWN_LOCATIONS.put(44, new int[]{-44836, -112524, -235});
		// Orc Mage
		START_LOCATIONS.put(49, new int[]{-56715, -113600, -690});
		TOWN_LOCATIONS.put(49, new int[]{-44836, -112524, -235});
		// Dwarf Fighter
		START_LOCATIONS.put(53, new int[]{108590, -174035, -400});
		TOWN_LOCATIONS.put(53, new int[]{115616, -178016, -900});
	}

	public static StarterPackManager getInstance()
	{
		return _instance;
	}

	private StarterPackManager()
	{
	}

	public void init()
	{
		loadNames();
		_log.info("StarterPackManager: Loaded " + _availableNames.size() + " names.");
	}

	private void loadNames()
	{
		_availableNames.clear();
		Path namesFile = Paths.get(Config.DATAPACK_ROOT.getAbsolutePath(), "data", "starter_pack_names.txt");
		try (BufferedReader reader = new BufferedReader(new FileReader(namesFile.toFile())))
		{
			String line;
			while((line = reader.readLine()) != null)
			{
				line = line.trim();
				if(line.isEmpty())
					continue;

				if(line.contains(","))
				{
					// Comma-separated names
					String[] parts = line.split(",");
					for(String part : parts)
					{
						String name = part.trim();
						if(!name.isEmpty())
							_availableNames.add(name);
					}
				}
				else
				{
					_availableNames.add(line);
				}
			}
		}
		catch(IOException e)
		{
			_log.error("StarterPackManager: Failed to load names from " + namesFile, e);
		}
	}

	public String getNextAvailableName()
	{
		for(String name : _availableNames)
		{
			if(_usedNames.contains(name))
				continue; // already used by active bot
			if(CharacterDAO.getInstance().getObjectIdByName(name) > 0)
				continue; // already taken in DB by a real player or leftover
			_usedNames.add(name);
			return name;
		}
		return null; // all names exhausted
	}

	public void releaseName(String name)
	{
		_usedNames.remove(name);
	}

	public int[] getStartLocation(int classId)
	{
		return START_LOCATIONS.get(classId);
	}

	public int[] getTownLocation(int classId)
	{
		return TOWN_LOCATIONS.get(classId);
	}

	public int getRandomStarterClass()
	{
		return STARTER_CLASSES[ThreadLocalRandom.current().nextInt(STARTER_CLASSES.length)];
	}

	public Map<String, Integer> getStatusCounts()
	{
		int farming = 0;
		int walking = 0;
		int inTown = 0;
		for(StarterBotState state : _activeBots.values())
		{
			switch(state.getCurrentState())
			{
				case FARMING:
					farming++;
					break;
				case WALKING_TO_TOWN:
					walking++;
					break;
				case IN_TOWN:
					inTown++;
					break;
			}
		}
		Map<String, Integer> counts = new HashMap<>();
		counts.put("total", _activeBots.size());
		counts.put("farming", farming);
		counts.put("walking", walking);
		counts.put("inTown", inTown);
		return counts;
	}

	public ConcurrentHashMap<Integer, StarterBotState> getActiveBots()
	{
		return _activeBots;
	}

	public void spawnStarterBots(int count)
	{
		if(!Config.STARTER_PACK_ENABLED)
			return;

		// Clean old starter pack bots from DB before spawning new ones
		cleanStarterPackDB();

		int maxNew = Math.min(count, Config.STARTER_PACK_MAX_BOTS);

		// Use AtomicInteger for round-robin class selection across scheduled tasks
		final AtomicInteger spawnIndex = new AtomicInteger(0);

		for(int i = 0; i < maxNew; i++)
		{
			final int delay = i * 500; // 500ms between spawns
			ThreadPoolManager.getInstance().schedule(() -> {
				try
				{
					int idx = spawnIndex.getAndIncrement();
					int classId = STARTER_CLASSES[idx % STARTER_CLASSES.length];
					spawnSingleBot(classId);
				}
				catch(Exception e)
				{
					_log.error("StarterPackManager: Error spawning bot: " + e.getMessage(), e);
				}
			}, delay);
		}
		_log.info("StarterPackManager: Scheduling spawn of " + maxNew + " starter bots.");
	}

	private void spawnSingleBot(int classId)
	{
		String name = getNextAvailableName();
		if(name == null)
		{
			_log.warn("StarterPack: No more names available");
			return;
		}

		try
		{
			_log.info("StarterPack: Attempting to spawn classId=" + classId + " name=" + name);

			// Pre-validate classId against ClassId enum
			if(classId < 0 || classId >= ClassId.VALUES.length)
			{
				_log.error("StarterPack: classId=" + classId + " is out of ClassId.VALUES range (0-" + (ClassId.VALUES.length - 1) + ")");
				_usedNames.remove(name);
				return;
			}
			ClassId cid = ClassId.VALUES[classId];
			if(cid == null || cid.isDummy())
			{
				_log.error("StarterPack: classId=" + classId + " is DUMMY or null! This is an invalid class ID.");
				_usedNames.remove(name);
				return;
			}
			if(!cid.isOfLevel(ClassLevel.NONE))
			{
				_log.error("StarterPack: classId=" + classId + " (" + cid.name() + ") is NOT a base class (level=" + cid.getClassLevel() + "). Only ClassLevel.NONE allowed!");
				_usedNames.remove(name);
				return;
			}
			_log.info("StarterPack: classId=" + classId + " validated as " + cid.name() + " race=" + cid.getRace());

			int sex = ThreadLocalRandom.current().nextInt(2); // 0 or 1
			int hairStyle = ThreadLocalRandom.current().nextInt(sex == 0 ? 5 : 7); // 0-4 male, 0-6 female
			int hairColor = ThreadLocalRandom.current().nextInt(4); // 0-3
			int face = ThreadLocalRandom.current().nextInt(3); // 0-2

			// Create character
			Player player = Player.create(classId, sex, "#starter_account", name, hairStyle, hairColor, face);
			_log.info("StarterPack: Player.create() returned " + (player != null ? "obj=" + player.getObjectId() : "NULL") + " for classId=" + classId + " name=" + name);
			if(player == null)
			{
				_log.error("StarterPack: Player.create FAILED for classId=" + classId + " name=" + name + " sex=" + sex);
				_usedNames.remove(name);
				return;
			}

			boolean initOk = CharacterCreate.initNewChar(player);
			_log.info("StarterPack: initNewChar completed for " + name + " result=" + initOk);
			if(!initOk)
			{
				_log.error("StarterPack: initNewChar FAILED for " + name + " classId=" + classId);
				_usedNames.remove(name);
				return;
			}
			int objId = player.getObjectId();

			// Restore with fake=false (PlayerAI initially, we replace with StarterPackAI)
			player = Player.restore(objId, false);
			_log.info("StarterPack: Player.restore() returned " + (player != null ? player.getName() : "NULL") + " for objId=" + objId);
			if(player == null)
			{
				_log.error("StarterPack: Player.restore FAILED for " + name + " objId=" + objId);
				_usedNames.remove(name);
				return;
			}

			// Set position to start location BEFORE entering world
			int[] startLoc = getStartLocation(classId);
			if(startLoc == null)
			{
				_log.error("StarterPack: No START_LOCATION configured for classId=" + classId + "! Check START_LOCATIONS map.");
				_usedNames.remove(name);
				return;
			}
			// Add small random offset (±50) to prevent stacking
			int offsetX = ThreadLocalRandom.current().nextInt(-50, 51);
			int offsetY = ThreadLocalRandom.current().nextInt(-50, 51);
			player.setXYZ(startLoc[0] + offsetX, startLoc[1] + offsetY, startLoc[2]);

			// Enter world
			EnterWorld.onEnterWorld(player);
			player.setActive(); // Enable monster aggro targeting
			_log.info("StarterPack: Bot " + name + " entered world at " + player.getX() + "," + player.getY() + "," + player.getZ());

			// Create state
			int[] townLoc = getTownLocation(classId);
			if(townLoc == null)
			{
				_log.error("StarterPack: No TOWN_LOCATION configured for classId=" + classId + "!");
				_usedNames.remove(name);
				return;
			}
			// Pre-randomize town destination (±150 to prevent clustering)
			int townOffX = ThreadLocalRandom.current().nextInt(-150, 151);
			int townOffY = ThreadLocalRandom.current().nextInt(-150, 151);
			int[] randomTownLoc = {townLoc[0] + townOffX, townLoc[1] + townOffY, townLoc[2]};

			StarterBotState state = new StarterBotState();
			state.setObjId(objId);
			state.setName(name);
			state.setClassId(classId);
			state.setSex(sex);
			state.setCurrentState(StarterBotState.State.FARMING);
			state.setSpawnTime(System.currentTimeMillis());
			state.setTownLocation(randomTownLoc);

			// Set custom AI
			Location spawnLoc = new Location(startLoc[0] + offsetX, startLoc[1] + offsetY, startLoc[2]);
			Location townLocation = new Location(townLoc[0], townLoc[1], townLoc[2]);
			StarterPackAI ai = new StarterPackAI(player, state, Config.STARTER_PACK_TARGET_LEVEL, spawnLoc, townLocation);
			player.setAI(ai);
			ai.startThinking(); // setAI does NOT trigger onEvtSpawn, so start think loop explicitly

			_activeBots.put(objId, state);
			_log.info("StarterPack: Spawned bot " + name + " (class=" + classId + "/" + cid.name() + ", race=" + cid.getRace() + ", objId=" + objId + ")");
		}
		catch(Exception e)
		{
			_log.error("StarterPack: FAILED to spawn classId=" + classId + " name=" + name, e);
			_usedNames.remove(name);
		}
	}

	public void despawnAllBots()
	{
		for(StarterBotState state : _activeBots.values())
		{
			try
			{
				Player player = GameObjectsStorage.getPlayer(state.getObjId());
				if(player != null)
				{
					player.logout();
				}
			}
			catch(Exception e)
			{
				_log.error("StarterPackManager: Error despawning " + state.getName(), e);
			}
		}
		_activeBots.clear();
		_usedNames.clear();
		_log.info("StarterPackManager: All starter bots despawned.");
	}

	public void shutdown()
	{
		_log.info("StarterPackManager: Shutting down, despawning " + _activeBots.size() + " starter bots...");
		despawnAllBots();
	}

	private void cleanStarterPackDB()
	{
		// Despawn active bots first
		despawnAllBots();

		Connection con = null;
		PreparedStatement ps = null;
		ResultSet rs = null;
		try
		{
			con = DatabaseFactory.getInstance().getConnection();

			// Get all starter pack character IDs
			List<Integer> objIds = new ArrayList<>();
			ps = con.prepareStatement("SELECT obj_Id FROM characters WHERE account_name='#starter_account'");
			rs = ps.executeQuery();
			while(rs.next())
				objIds.add(rs.getInt(1));
			DbUtils.close(ps, rs);

			if(objIds.isEmpty())
				return;

			String idList = objIds.stream().map(String::valueOf).collect(Collectors.joining(","));

			// Delete from dependent tables — each has its own column name for character id
			// Tables with char_obj_id
			String[] charObjIdTables = {
				"character_subclasses",
				"character_skills",
				"character_skills_save",
				"character_hennas",
				"character_macroses"
			};
			for(String table : charObjIdTables)
			{
				try
				{
					ps = con.prepareStatement("DELETE FROM " + table + " WHERE char_obj_id IN (" + idList + ")");
					ps.execute();
					DbUtils.close(ps);
				}
				catch(Exception e) { /* table might not exist — skip */ }
			}

			// Tables with object_id
			String[] objectIdTables = {
				"character_effects_save",
				"character_group_reuse",
				"character_shortcuts"
			};
			for(String table : objectIdTables)
			{
				try
				{
					ps = con.prepareStatement("DELETE FROM " + table + " WHERE object_id IN (" + idList + ")");
					ps.execute();
					DbUtils.close(ps);
				}
				catch(Exception e) { /* table might not exist — skip */ }
			}

			// Tables with obj_id
			String[] objIdTables = {
				"character_variables",
				"character_instances"
			};
			for(String table : objIdTables)
			{
				try
				{
					ps = con.prepareStatement("DELETE FROM " + table + " WHERE obj_id IN (" + idList + ")");
					ps.execute();
					DbUtils.close(ps);
				}
				catch(Exception e) { /* table might not exist — skip */ }
			}

			// character_bookmarks uses char_Id
			try
			{
				ps = con.prepareStatement("DELETE FROM character_bookmarks WHERE char_Id IN (" + idList + ")");
				ps.execute();
				DbUtils.close(ps);
			}
			catch(Exception e) { /* skip */ }

			// character_quests uses char_id
			try
			{
				ps = con.prepareStatement("DELETE FROM character_quests WHERE char_id IN (" + idList + ")");
				ps.execute();
				DbUtils.close(ps);
			}
			catch(Exception e) { /* skip */ }

			// items uses owner_id
			try
			{
				ps = con.prepareStatement("DELETE FROM items WHERE owner_id IN (" + idList + ")");
				ps.execute();
				DbUtils.close(ps);
			}
			catch(Exception e) { /* skip */ }

			// Delete from characters table last
			ps = con.prepareStatement("DELETE FROM characters WHERE account_name='#starter_account'");
			ps.execute();
			DbUtils.close(ps);

			_log.info("StarterPack: Cleaned " + objIds.size() + " old bot characters from DB");
		}
		catch(Exception e)
		{
			_log.error("StarterPack: Failed to clean DB", e);
		}
		finally
		{
			try { DbUtils.close(ps, rs); } catch(Exception ignored) {}
			try { DbUtils.close(con); } catch(Exception ignored) {}
		}
	}
}
