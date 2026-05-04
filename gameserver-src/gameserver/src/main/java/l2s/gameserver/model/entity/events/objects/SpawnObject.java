package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.instancemanager.SpawnManager;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;

public class SpawnObject
implements SpawnableObject {
    private final String _name;

    public SpawnObject(String name) {
        this._name = name;
    }

    @Override
    public void spawnObject(Event event, Reflection reflection) {
        SpawnManager.getInstance().spawn(this._name, false);
    }

    @Override
    public void respawnObject(Event event, Reflection reflection) {
        SpawnManager.getInstance().despawn(this._name);
        SpawnManager.getInstance().spawn(this._name, false);
    }

    @Override
    public void despawnObject(Event event, Reflection reflection) {
        SpawnManager.getInstance().despawn(this._name);
    }

    @Override
    public void refreshObject(Event event, Reflection reflection) {
    }
}

