package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;

public interface SpawnableObject {
    public void spawnObject(Event var1, Reflection var2);

    public void despawnObject(Event var1, Reflection var2);

    public void respawnObject(Event var1, Reflection var2);

    public void refreshObject(Event var1, Reflection var2);
}

