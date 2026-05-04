package l2s.gameserver.model.entity.events.objects;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.gameserver.Config;
import l2s.gameserver.instancemanager.SpawnManager;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.model.instances.NpcInstance;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SpawnExObject
implements SpawnableObject {
    private static final Logger _log = LoggerFactory.getLogger(SpawnExObject.class);
    private final List<Spawner> _spawns;
    private boolean _spawned = false;
    private String _name;

    public SpawnExObject(String name) {
        this._name = name;
        this._spawns = SpawnManager.getInstance().getSpawners(this._name);
        if (this._spawns.isEmpty() && !Config.DONTLOADSPAWN) {
            _log.warn("SpawnExObject: not found spawn group: " + name);
        }
    }

    public SpawnExObject(SpawnExObject source) {
        this._name = source._name;
        this._spawns = new ArrayList<Spawner>(source._spawns.size());
        for (Spawner spawn : source._spawns) {
            this._spawns.add(spawn.clone());
        }
    }

    @Override
    public void spawnObject(Event event, Reflection reflection) {
        if (this._spawned) {
            _log.warn("SpawnExObject: can't spawn twice: " + this._name + "; event: " + (Object)((Object)event), (Throwable)new Exception());
        } else {
            for (Spawner spawn : this._spawns) {
                if (event.isInProgress()) {
                    spawn.addEvent(event);
                } else {
                    spawn.removeEvent(event);
                }
                spawn.setReflection(reflection);
                spawn.init();
            }
            this._spawned = true;
        }
    }

    @Override
    public void respawnObject(Event event, Reflection reflection) {
        if (!this._spawned) {
            _log.warn("SpawnExObject: can't respawn, not spawned: " + this._name + "; event: " + (Object)((Object)event), (Throwable)new Exception());
        } else {
            for (Spawner spawn : this._spawns) {
                spawn.init();
            }
        }
    }

    @Override
    public void despawnObject(Event event, Reflection reflection) {
        if (!this._spawned) {
            return;
        }
        this._spawned = false;
        for (Spawner spawn : this._spawns) {
            spawn.removeEvent(event);
            spawn.deleteAll();
        }
    }

    @Override
    public void refreshObject(Event event, Reflection reflection) {
        for (NpcInstance npc : this.getAllSpawned()) {
            if (event.isInProgress()) {
                npc.addEvent(event);
                continue;
            }
            npc.removeEvent(event);
        }
    }

    public List<Spawner> getSpawns() {
        return this._spawns;
    }

    public List<NpcInstance> getAllSpawned() {
        ArrayList npcs = new ArrayList();
        for (Spawner spawn : this._spawns) {
            npcs.addAll(spawn.getAllSpawned());
        }
        return npcs.isEmpty() ? Collections.emptyList() : npcs;
    }

    public NpcInstance getFirstSpawned() {
        List<NpcInstance> npcs = this.getAllSpawned();
        return npcs.size() > 0 ? npcs.get(0) : null;
    }

    public boolean isSpawned() {
        return this._spawned;
    }
}

