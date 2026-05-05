package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.GameServer;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.FenceInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.StaticObjectInstance;
import org.apache.commons.lang3.ArrayUtils;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.CHashIntObjectMap;

public class GameObjectsStorage {
    private static IntObjectMap<GameObject> _objects = new CHashIntObjectMap((int)(60000.0 * Config.maxMobSpawnMultiplierForStorage() + (double)GameServer.getInstance().getOnlineLimit() + (double)Config.FAKE_PLAYERS_COUNT + 1000.0));
    private static IntObjectMap<StaticObjectInstance> _staticObjects = new CHashIntObjectMap(1000);
    private static IntObjectMap<NpcInstance> _npcs = new CHashIntObjectMap((int)(60000.0 * Config.maxMobSpawnMultiplierForStorage()));
    private static IntObjectMap<Player> _players = new CHashIntObjectMap(GameServer.getInstance().getOnlineLimit());
    private static IntObjectMap<Player> _offlinePlayers = new CHashIntObjectMap(1000);
    private static IntObjectMap<FenceInstance> _fences = new CHashIntObjectMap(1000);
    private static IntObjectMap<Player> _fakePlayers = new CHashIntObjectMap(Config.FAKE_PLAYERS_COUNT);

    public static GameObject findObject(int objId) {
        return (GameObject)_objects.get(objId);
    }

    public static Collection<GameObject> getObjects() {
        return _objects.valueCollection();
    }

    public static Collection<StaticObjectInstance> getStaticObjects() {
        return _staticObjects.valueCollection();
    }

    public static StaticObjectInstance getStaticObject(int id) {
        for (StaticObjectInstance object : _staticObjects.valueCollection()) {
            if (object.getUId() != id) continue;
            return object;
        }
        return null;
    }

    public static Collection<FenceInstance> getFences() {
        return _fences.valueCollection();
    }

    public static FenceInstance getFence(int objectId) {
        for (FenceInstance fence : _fences.valueCollection()) {
            if (fence.getObjectId() != objectId) continue;
            return fence;
        }
        return null;
    }

    public static Player getPlayer(String name) {
        for (Player player : _players.valueCollection()) {
            if (!player.getName().equalsIgnoreCase(name)) continue;
            return player;
        }
        for (Player player : _fakePlayers.valueCollection()) {
            if (!player.getName().equalsIgnoreCase(name)) continue;
            return player;
        }
        for (Player player : _offlinePlayers.valueCollection()) {
            if (!player.getName().equalsIgnoreCase(name)) continue;
            return player;
        }
        return null;
    }

    public static Player getPlayer(int objId) {
        Player player = (Player)_players.get(objId);
        if (player != null) {
            return player;
        }
        player = (Player)_fakePlayers.get(objId);
        if (player != null) {
            return player;
        }
        return (Player)_offlinePlayers.get(objId);
    }

    public static Collection<Player> getPlayers(boolean withFake, boolean withOffline) {
        if (withFake || withOffline) {
            ArrayList<Player> players = new ArrayList<Player>(_players.size() + _fakePlayers.size() + _offlinePlayers.size());
            players.addAll(_players.valueCollection());
            if (withFake) {
                players.addAll(_fakePlayers.valueCollection());
            }
            if (withOffline) {
                players.addAll(_offlinePlayers.valueCollection());
            }
            return players;
        }
        return _players.valueCollection();
    }

    public static Collection<Player> getFakePlayers() {
        return _fakePlayers.valueCollection();
    }

    public static Collection<Player> getOfflinePlayers() {
        return _offlinePlayers.valueCollection();
    }

    public static NpcInstance getNpc(int objId) {
        return (NpcInstance)_npcs.get(objId);
    }

    public static Collection<NpcInstance> getNpcs() {
        return _npcs.valueCollection();
    }

    public static List<NpcInstance> getNpcs(boolean onlyAlive, int ... npcIds) {
        return GameObjectsStorage.getNpcs(onlyAlive, onlyAlive, npcIds);
    }

    public static List<NpcInstance> getNpcs(boolean onlyAlive, boolean onlySpawned, int ... npcIds) {
        ArrayList<NpcInstance> result = new ArrayList<NpcInstance>();
        for (NpcInstance npc : GameObjectsStorage.getNpcs()) {
            if (npcIds.length != 0 && !ArrayUtils.contains((int[])npcIds, (int)npc.getNpcId()) || onlyAlive && npc.isDead() || onlySpawned && !npc.isVisible()) continue;
            result.add(npc);
        }
        return result;
    }

    public static List<NpcInstance> getNpcs(boolean onlyAlive, String npcName) {
        return GameObjectsStorage.getNpcs(onlyAlive, onlyAlive, npcName);
    }

    public static List<NpcInstance> getNpcs(boolean onlyAlive, boolean onlySpawned, String npcName) {
        ArrayList<NpcInstance> result = new ArrayList<NpcInstance>();
        for (NpcInstance npc : GameObjectsStorage.getNpcs()) {
            if (!npc.getName().equalsIgnoreCase(npcName) || onlyAlive && npc.isDead() || onlySpawned && !npc.isVisible()) continue;
            result.add(npc);
        }
        return result;
    }

    public static <T extends GameObject> void put(T o) {
        if (o.isObservePoint()) {
            return;
        }
        IntObjectMap<T> map = GameObjectsStorage.getMapForObject(o);
        if (map != null) {
            map.put(o.getObjectId(), o);
        }
        _objects.put(o.getObjectId(), o);
    }

    public static <T extends GameObject> void remove(T o) {
        if (o.isObservePoint()) {
            return;
        }
        IntObjectMap<T> map = GameObjectsStorage.getMapForObject(o);
        if (map != null) {
            map.remove(o.getObjectId());
        }
        _objects.remove(o.getObjectId());
    }

    @SuppressWarnings("unchecked")
    private static <T extends GameObject> IntObjectMap<T> getMapForObject(T o) {
        if (o.isFence()) {
            return (IntObjectMap<T>)_fences;
        }
        if (o.isStaticObject()) {
            return (IntObjectMap<T>)_staticObjects;
        }
        if (o.isNpc()) {
            return (IntObjectMap<T>)_npcs;
        }
        if (o.isFakePlayer()) {
            return (IntObjectMap<T>)_fakePlayers;
        }
        if (o.isPlayer()) {
            if (o.getPlayer().isInOfflineMode()) {
                return (IntObjectMap<T>)_offlinePlayers;
            }
            return (IntObjectMap<T>)_players;
        }
        return null;
    }
}

