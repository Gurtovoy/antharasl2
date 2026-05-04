/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.data.xml.holder.StaticObjectHolder;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.model.instances.StaticObjectInstance;

public class StaticObjectObject
implements SpawnableObject {
    private int _uid;
    private StaticObjectInstance _instance;

    public StaticObjectObject(int id) {
        this._uid = id;
    }

    @Override
    public void spawnObject(Event event, Reflection reflection) {
        this._instance = StaticObjectHolder.getInstance().getObject(this._uid);
    }

    @Override
    public void despawnObject(Event event, Reflection reflection) {
    }

    @Override
    public void respawnObject(Event event, Reflection reflection) {
    }

    @Override
    public void refreshObject(Event event, Reflection reflection) {
        if (!event.isInProgress()) {
            this._instance.removeEvent(event);
        } else {
            this._instance.addEvent(event);
        }
    }

    public void setMeshIndex(int id) {
        this._instance.setMeshIndex(id);
        this._instance.broadcastInfo(false);
    }

    public int getUId() {
        return this._uid;
    }
}

