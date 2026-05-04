package l2s.gameserver.tables;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.LineNumberReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.GameServer;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.dao.CharacterDAO;
import l2s.gameserver.data.xml.holder.FakePlayersHolder;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.base.ClassId;
import l2s.gameserver.model.base.ClassLevel;
import l2s.gameserver.model.base.Sex;
import l2s.gameserver.network.l2.c2s.CharacterCreate;
import l2s.gameserver.network.l2.c2s.EnterWorld;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FakePlayersTable {
    private static final int CLIENTS_HASHCODE;
    private static final Map<String, Integer> CLIENTS;
    private static final Logger _log;
    private static final List<String> _fakePlayerNames;
    private static final List<String> _activeFakePlayers;
    private static final FakePlayersTable _instance;
    private static ScheduledFuture<?> spawnFakePlayersTask;

    public static FakePlayersTable getInstance() {
        return _instance;
    }

    private FakePlayersTable() {
        FakePlayersTable.parseData();
    }

    public void init() {
        if (!Config.ALLOW_FAKE_PLAYERS && Config.FAKE_PLAYERS_COUNT <= 0) {
            return;
        }
        if (Config.FAKE_PLAYERS_COUNT <= 0) {
            ThreadPoolManager.getInstance().scheduleAtFixedRate(new Task(), 180000L, 1000L);
        } else {
            int fakePlayersCount = Math.min(Config.FAKE_PLAYERS_COUNT, FakePlayersTable.getFakePlayersLimit());
            if (fakePlayersCount <= 0) {
                if (Config.ALLOW_FAKE_PLAYERS) {
                    ThreadPoolManager.getInstance().scheduleAtFixedRate(new Task(), 180000L, 1000L);
                }
                return;
            }
            ThreadPoolManager.getInstance().scheduleAtFixedRate(new SpawnFakePlayersTask(), TimeUnit.SECONDS.toMillis(Config.FAKE_PLAYERS_SPAWN_TASK_DELAY), TimeUnit.SECONDS.toMillis(Config.FAKE_PLAYERS_SPAWN_TASK_DELAY));
        }
    }

    private static void stopSpawnFakePlayersTask() {
        if (spawnFakePlayersTask != null) {
            spawnFakePlayersTask.cancel(false);
            spawnFakePlayersTask = null;
        }
    }

    public static boolean spawnFakePlayer(String name, ClassId classId, Sex sex) {
        Player player = Player.create(classId.getId(), sex.ordinal(), "#fake_account", name, Rnd.get((int)3), Rnd.get((int)3), Rnd.get((int)3));
        if (player == null) {
            return false;
        }
        CharacterCreate.initNewChar(player);
        player = Player.restore(player.getObjectId(), true);
        if (player == null) {
            return false;
        }
        EnterWorld.onEnterWorld(player);
        return true;
    }

    private static void parseData() {
        if (!Config.ALLOW_FAKE_PLAYERS && Config.FAKE_PLAYERS_COUNT <= 0) {
            return;
        }
        BufferedReader lnr = null;
        try {
            String line;
            File doorData = new File("config/fake_players.list");
            lnr = new LineNumberReader(new BufferedReader(new FileReader(doorData)));
            while ((line = ((LineNumberReader)lnr).readLine()) != null) {
                if (line.trim().length() == 0 || line.startsWith("#")) continue;
                _fakePlayerNames.add(line);
            }
            _log.info("FakePlayersTable: Loaded " + _fakePlayerNames.size() + " fake player names.");
        }
        catch (Exception e) {
            _log.warn("FakePlayersTable: Lists could not be initialized.");
            e.printStackTrace();
        }
        finally {
            try {
                if (lnr != null) {
                    lnr.close();
                }
            }
            catch (Exception exception) {}
        }
    }

    public static List<String> getFakePlayerNames() {
        return _fakePlayerNames;
    }

    public static int getActiveFakePlayersCount() {
        return _activeFakePlayers.size();
    }

    public static List<String> getActiveFakePlayers() {
        return _activeFakePlayers;
    }

    public static int getFakePlayersLimit() {
        if (!GameServer.DEVELOP) {
            Integer fakesLimit = CLIENTS.get(GameServer.getInstance().getLicenseHost());
            if (CLIENTS_HASHCODE == CLIENTS.hashCode() && fakesLimit != null && fakesLimit != 0) {
                return fakesLimit == -1 ? 5000 : fakesLimit;
            }
            return 10;
        }
        return 5000;
    }

    static {
        CLIENTS = new HashMap<String, Integer>();
        CLIENTS.put(new String(new byte[]{49, 48, 57, 46, 56, 54, 46, 49, 48, 54, 46, 49, 53, 51}), -1);
        CLIENTS.put(new String(new byte[]{57, 52, 46, 49, 57, 56, 46, 49, 48, 57, 46, 49, 54, 54}), -1);
        CLIENTS.put(new String(new byte[]{53, 52, 46, 51, 56, 46, 49, 48, 51, 46, 49, 54, 53}), -1);
        CLIENTS.put(new String(new byte[]{53, 52, 46, 51, 56, 46, 49, 48, 51, 46, 49, 54, 55}), -1);
        CLIENTS.put(new String(new byte[]{57, 51, 46, 55, 56, 46, 50, 48, 56, 46, 50, 48, 53}), -1);
        CLIENTS.put(new String(new byte[]{49, 52, 53, 46, 50, 51, 57, 46, 49, 51, 48, 46, 50, 51}), -1);
        CLIENTS_HASHCODE = CLIENTS.hashCode();
        _log = LoggerFactory.getLogger(FakePlayersTable.class);
        _fakePlayerNames = new ArrayList<String>();
        _activeFakePlayers = new ArrayList<String>();
        _instance = new FakePlayersTable();
        spawnFakePlayersTask = null;
    }

    private static class SpawnFakePlayersTask
    implements Runnable {
        private int waitDelay = 0;

        private SpawnFakePlayersTask() {
        }

        @Override
        public void run() {
            Player player;
            Integer objectId;
            boolean canSpawnNew;
            --this.waitDelay;
            if (this.waitDelay > 0) {
                return;
            }
            int fakePlayersCount = Math.min(Config.FAKE_PLAYERS_COUNT, FakePlayersTable.getFakePlayersLimit());
            if (GameObjectsStorage.getFakePlayers().size() >= fakePlayersCount) {
                return;
            }
            List<Integer> restoredPlayers = CharacterDAO.getInstance().getPlayersIdByAccount("#fake_account");
            restoredPlayers = restoredPlayers.stream().filter(id -> GameObjectsStorage.getPlayer(id) == null).collect(Collectors.toList());
            ArrayList<ClassId> classes = new ArrayList<ClassId>();
            ArrayList<String> names = new ArrayList<String>(FakePlayersTable.getFakePlayerNames());
            for (ClassId c : ClassId.VALUES) {
                if (!c.isOfLevel(ClassLevel.NONE) || FakePlayersHolder.getInstance().getAITemplate(c.getRace(), c.getType()) == null) continue;
                classes.add(c);
            }
            boolean canRestore = !restoredPlayers.isEmpty();
            boolean bl = canSpawnNew = !classes.isEmpty() && !names.isEmpty();
            if (canRestore && (!canSpawnNew || Rnd.chance((int)70)) && (objectId = (Integer)Rnd.get(restoredPlayers)) != null && restoredPlayers.remove(objectId) && (player = GameObjectsStorage.getPlayer(objectId)) == null && (player = Player.restore(objectId, true)) != null) {
                EnterWorld.onEnterWorld(player);
                this.waitDelay = Rnd.get((int)1, (int)3);
                return;
            }
            if (canSpawnNew) {
                String name = (String)Rnd.get(names);
                while (CharacterDAO.getInstance().getObjectIdByName(name) > 0) {
                    names.remove(name);
                    if (names.isEmpty()) {
                        return;
                    }
                    name = (String)Rnd.get(names);
                }
                names.remove(name);
                ClassId classId = (ClassId)((Object)Rnd.get(classes));
                if (classId == null) {
                    return;
                }
                Sex sex = (Sex)((Object)Rnd.get((Object[])Sex.VALUES));
                if (sex == null) {
                    return;
                }
                if (FakePlayersTable.spawnFakePlayer(name, classId, sex)) {
                    this.waitDelay = Rnd.get((int)3, (int)9);
                }
            }
        }
    }

    public static class Task
    implements Runnable {
        @Override
        public void run() {
            try {
                if (_activeFakePlayers.size() < GameObjectsStorage.getPlayers(true, false).size() * Config.FAKE_PLAYERS_PERCENT / 100 && _activeFakePlayers.size() < _fakePlayerNames.size()) {
                    String player;
                    if (Rnd.chance((int)10) && (player = (String)Rnd.get((List)_fakePlayerNames)) != null && !_activeFakePlayers.contains(player)) {
                        _activeFakePlayers.add(player);
                    }
                } else if (_activeFakePlayers.size() > 0) {
                    _activeFakePlayers.remove(Rnd.get((int)_activeFakePlayers.size()));
                }
            }
            catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

