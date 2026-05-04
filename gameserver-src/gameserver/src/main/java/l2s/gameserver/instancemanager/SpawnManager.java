package l2s.gameserver.instancemanager;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import l2s.gameserver.Config;
import l2s.gameserver.GameTimeController;
import l2s.gameserver.dao.SpawnsDAO;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.data.xml.holder.SpawnHolder;
import l2s.gameserver.instancemanager.RaidBossSpawnManager;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.game.OnDayNightChangeListener;
import l2s.gameserver.model.HardSpawner;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.model.instances.SaveableMonsterInstance;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.spawn.PeriodOfDay;
import l2s.gameserver.templates.spawn.SpawnTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SpawnManager {
    private static final Logger _log = LoggerFactory.getLogger(SpawnManager.class);
    private static SpawnManager _instance = new SpawnManager();
    private Map<String, List<Spawner>> _spawns = new ConcurrentHashMap<String, List<Spawner>>();
    private Listeners _listeners = new Listeners();

    public static SpawnManager getInstance() {
        return _instance;
    }

    private SpawnManager() {
        for (Map.Entry<String, List<SpawnTemplate>> entry : SpawnHolder.getInstance().getSpawns().entrySet()) {
            this.fillSpawn(entry.getKey(), entry.getValue());
        }
        this.fillSpawn("NONE", SpawnsDAO.getInstance().restore());
        GameTimeController.getInstance().addListener(this._listeners);
    }

    public List<Spawner> fillSpawn(String group, List<SpawnTemplate> templateList) {
        if (Config.DONTLOADSPAWN) {
            return Collections.emptyList();
        }
        List<Spawner> spawnerList = this._spawns.get(group);
        if (spawnerList == null) {
            spawnerList = new ArrayList<Spawner>(templateList.size());
            this._spawns.put(group, spawnerList);
        }
        for (SpawnTemplate template : templateList) {
            HardSpawner spawner = new HardSpawner(template);
            spawnerList.add(spawner);
            NpcTemplate npcTemplate = NpcHolder.getInstance().getTemplate(spawner.getMainNpcId());
            boolean saveable = npcTemplate.isRaid || npcTemplate.isInstanceOf(SaveableMonsterInstance.class);
            int count = template.getCount();
            if (Config.RATE_MOB_SPAWN > 0.0 && npcTemplate.isInstanceOf(MonsterInstance.class) && !saveable && npcTemplate.level >= Config.RATE_MOB_SPAWN_MIN_LEVEL && npcTemplate.level <= Config.RATE_MOB_SPAWN_MAX_LEVEL) {
                count = (int)Math.max(1.0, (double)count * Config.RATE_MOB_SPAWN);
            }
            spawner.setAmount(count);
            spawner.setRespawnDelay(template.getRespawn(), template.getRespawnRandom());
            spawner.setRespawnPattern(template.getRespawnPattern());
            spawner.setReflection(ReflectionManager.MAIN);
            spawner.setRespawnTime(0);
            if (!saveable || !group.equals(PeriodOfDay.NONE.name())) continue;
            RaidBossSpawnManager.getInstance().addNewSpawn(npcTemplate.getId(), spawner);
        }
        return spawnerList;
    }

    public void spawnAll() {
        this.spawn(PeriodOfDay.NONE.name());
        if (Config.ALLOW_EVENT_GATEKEEPER) {
            this.spawn("event_gatekeeper");
        }
        if (Config.SPAWN_VITAMIN_MANAGER) {
            this.spawn("vitamin_manager");
        }
        if (!Config.ALLOW_CLASS_MASTERS_LIST.isEmpty()) {
            this.spawn("class_master");
        }
        if (Config.ENABLE_OLYMPIAD) {
            this.spawn("olympiad");
        }
        if (Config.TRAINING_CAMP_ENABLE) {
            this.spawn("training_camp");
        }
    }

    public void despawnAll() {
        RaidBossSpawnManager.getInstance().cleanUp();
        for (List<Spawner> spawnerList : this._spawns.values()) {
            for (Spawner spawner : spawnerList) {
                spawner.deleteAll();
            }
        }
    }

    public List<Spawner> spawn(String group, boolean logging) {
        List<Spawner> spawnerList = this._spawns.get(group);
        if (spawnerList == null) {
            return Collections.emptyList();
        }
        int npcSpawnCount = 0;
        for (Spawner spawner : spawnerList) {
            if (!logging || (npcSpawnCount += spawner.init()) % 1000 != 0 || npcSpawnCount == 0) continue;
            _log.info("SpawnManager: spawned " + npcSpawnCount + " npc for group: " + group);
        }
        if (logging) {
            _log.info("SpawnManager: spawned " + npcSpawnCount + " npc; spawns: " + spawnerList.size() + "; group: " + group);
        }
        return spawnerList;
    }

    public List<Spawner> spawn(String group) {
        return this.spawn(group, true);
    }

    public void despawn(String group) {
        List<Spawner> spawnerList = this._spawns.get(group);
        if (spawnerList == null) {
            return;
        }
        for (Spawner spawner : spawnerList) {
            spawner.deleteAll();
        }
    }

    public List<Spawner> getSpawners(String group) {
        List<Spawner> list = this._spawns.get(group);
        return list == null ? Collections.emptyList() : list;
    }

    public void reloadAll() {
        this.despawnAll();
        RaidBossSpawnManager.getInstance().reloadBosses();
        this.spawnAll();
        if (GameTimeController.getInstance().isNowNight()) {
            this._listeners.onNight(false);
        } else {
            this._listeners.onDay(false);
        }
    }

    private class Listeners
    implements OnDayNightChangeListener {
        private Listeners() {
        }

        @Override
        public void onDay(boolean onStart) {
            SpawnManager.this.despawn(PeriodOfDay.NIGHT.name());
            SpawnManager.this.spawn(PeriodOfDay.DAY.name());
        }

        @Override
        public void onNight(boolean onStart) {
            SpawnManager.this.despawn(PeriodOfDay.DAY.name());
            SpawnManager.this.spawn(PeriodOfDay.NIGHT.name());
        }
    }
}

