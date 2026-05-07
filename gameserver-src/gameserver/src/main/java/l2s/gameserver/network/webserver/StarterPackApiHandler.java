package l2s.gameserver.network.webserver;

import com.sun.net.httpserver.HttpExchange;
import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.Map;
import l2s.gameserver.Config;
import l2s.gameserver.instancemanager.StarterPackManager;
import l2s.gameserver.model.autobot.StarterPackFarmProgression;
import l2s.gameserver.model.autobot.StarterBotState;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.Race;

public class StarterPackApiHandler extends ApiHandler
{
	@Override
	protected void handleRequest(HttpExchange exchange) throws IOException
	{
		String method = exchange.getRequestMethod();
		String path = exchange.getRequestURI().getPath();

		// GET /api/starterpack/status
		if("GET".equals(method) && path.equals("/api/starterpack/status"))
		{
			handleStatus(exchange);
			return;
		}

		// POST /api/starterpack/start
		if("POST".equals(method) && path.equals("/api/starterpack/start"))
		{
			handleStart(exchange);
			return;
		}

		// POST /api/starterpack/stop
		if("POST".equals(method) && path.equals("/api/starterpack/stop"))
		{
			handleStop(exchange);
			return;
		}

		sendError(exchange, 404, "Not found: " + method + " " + path);
	}

	private void handleStatus(HttpExchange exchange) throws IOException
	{
		StarterPackManager mgr = StarterPackManager.getInstance();
		Map<String, Integer> counts = mgr.getStatusCounts();
		Map<String, Integer> raceCounts = new LinkedHashMap<>();
		Map<String, Integer> stageCounts = new LinkedHashMap<>();
		Map<String, Integer> raceStageCounts = new LinkedHashMap<>();
		Map<String, Integer> raceStateCounts = new LinkedHashMap<>();
		Map<String, Integer> modeCounts = new LinkedHashMap<>();
		Map<String, Integer> questStageCounts = new LinkedHashMap<>();
		Map<String, Integer> questStageStateCounts = new LinkedHashMap<>();
		Map<String, Object> raceStageDetails = new LinkedHashMap<>();

		for(StarterBotState state : mgr.getActiveBots().values())
		{
			String raceKey = "unknown";
			if(state.getClassId() >= 0 && state.getClassId() < ClassId.VALUES.length && ClassId.VALUES[state.getClassId()] != null)
				raceKey = ClassId.VALUES[state.getClassId()].getRace().toString().toLowerCase();

			String stageKey = toStageKey(state.getFarmStage());
			String stateKey = state.getCurrentState().toString().toLowerCase();
			String modeKey = state.getMode() != null ? state.getMode().toString().toLowerCase() : "unknown";

			inc(raceCounts, raceKey);
			inc(stageCounts, stageKey);
			inc(raceStageCounts, raceKey + ":" + stageKey);
			inc(raceStateCounts, raceKey + ":" + stateKey);
			inc(modeCounts, modeKey);
			raceStageDetails.put(raceKey + ":" + stageKey, buildStageDetails(raceKey, state.getFarmStage()));

			if(state.getMode() == StarterBotState.Mode.QUEST_HUMAN_FIGHTER)
			{
				String questStageKey = state.getQuestStageKey();
				if(questStageKey == null || questStageKey.isEmpty())
					questStageKey = "unknown";
				inc(questStageCounts, questStageKey);
				inc(questStageStateCounts, questStageKey + ":" + stateKey);
			}
		}

		Map<String, Object> response = new LinkedHashMap<>();
		response.put("total", counts.get("total"));
		response.put("farming", counts.get("farming"));
		response.put("walking", counts.get("walking"));
		response.put("inTown", counts.get("inTown"));
		response.put("byRace", raceCounts);
		response.put("byFarmStage", stageCounts);
		response.put("byRaceAndStage", raceStageCounts);
		response.put("byRaceAndStageDetails", raceStageDetails);
		response.put("byRaceAndState", raceStateCounts);
		response.put("byMode", modeCounts);
		response.put("byQuestStage", questStageCounts);
		response.put("byQuestStageAndState", questStageStateCounts);
		response.put("maxBots", Config.STARTER_PACK_MAX_BOTS);
		response.put("enabled", Config.STARTER_PACK_ENABLED);

		sendJson(exchange, 200, response);
	}

	private static String toStageKey(int farmStage)
	{
		switch(farmStage)
		{
			case 0:
				return "starter";
			case 1:
				return "outskirts";
			default:
				return "stage_" + farmStage;
		}
	}

	private static void inc(Map<String, Integer> map, String key)
	{
		map.put(key, map.getOrDefault(key, 0) + 1);
	}

	private static Map<String, Object> buildStageDetails(String raceKey, int farmStage)
	{
		Map<String, Object> details = new LinkedHashMap<>();
		details.put("stage", farmStage);
		details.put("stageKey", toStageKey(farmStage));

		Race race = parseRace(raceKey);
		if(race == null)
			return details;

		StarterPackFarmProgression.RaceFarmStage stage;
		if(farmStage <= 0)
		{
			// For starter stage show next xml progression step (usually [1]) instead of empty placeholders.
			stage = StarterPackFarmProgression.getNextStage(race, 0, 1);
			details.put("source", "next_after_starter");
		}
		else
		{
			stage = StarterPackFarmProgression.getCurrentStage(race, farmStage);
			details.put("source", "current_stage");
		}
		if(stage == null)
			return details;

		details.put("minLevel", stage.minLevel);
		details.put("maxLevel", stage.maxLevel);
		details.put("farmName", stage.farmName);
		details.put("xmlFile", stage.sourceFile);
		details.put("spawnPoints", stage.getSpawnCount());
		return details;
	}

	private static Race parseRace(String raceKey)
	{
		try
		{
			return Race.valueOf(raceKey.toUpperCase());
		}
		catch(Exception e)
		{
			return null;
		}
	}

	private void handleStart(HttpExchange exchange) throws IOException
	{
		if(!Config.STARTER_PACK_ENABLED)
		{
			Map<String, Object> resp = new LinkedHashMap<>();
			resp.put("success", false);
			resp.put("message", "Starter pack is disabled in config");
			sendJson(exchange, 400, resp);
			return;
		}

		Map<?, ?> body = parseJson(exchange, Map.class);
		int count = 50; // default
		String type = "starter_pack";
		if(body != null && body.containsKey("count"))
		{
			Object val = body.get("count");
			if(val instanceof Number)
			{
				count = ((Number) val).intValue();
			}
		}
		if(body != null && body.containsKey("type"))
		{
			Object val = body.get("type");
			if(val != null)
				type = String.valueOf(val);
		}

		if(count <= 0)
		{
			Map<String, Object> resp = new LinkedHashMap<>();
			resp.put("success", false);
			resp.put("message", "Count must be positive");
			sendJson(exchange, 400, resp);
			return;
		}

		if("quest_human_fighter".equalsIgnoreCase(type))
		{
			StarterPackManager.getInstance().spawnHumanFighterQuestBots(count);
		}
		else
		{
			StarterPackManager.getInstance().spawnStarterBots(count);
		}

		Map<String, Object> resp = new LinkedHashMap<>();
		resp.put("success", true);
		resp.put("message", "Spawning " + count + " bots, type=" + type);
		sendJson(exchange, 200, resp);
	}

	private void handleStop(HttpExchange exchange) throws IOException
	{
		StarterPackManager.getInstance().despawnAllBots();

		Map<String, Object> resp = new LinkedHashMap<>();
		resp.put("success", true);
		resp.put("message", "All starter bots despawned");
		sendJson(exchange, 200, resp);
	}
}
