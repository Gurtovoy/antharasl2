/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model.entity.events.objects;

import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.objects.SpawnableObject;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.utils.NpcUtils;

public class SpawnSimpleObject
implements SpawnableObject {
    protected int _npcId;
    private Location _loc;
    protected NpcInstance _npc = null;

    public SpawnSimpleObject(int npcId, Location loc) {
        this._npcId = npcId;
        this._loc = loc;
    }

    @Override
    public void spawnObject(Event event, Reflection reflection) {
        this._npc = NpcUtils.spawnSingle(this._npcId, (SpawnRange)this._loc, reflection);
        if (this._npc != null) {
            this._npc.addEvent(event);
        }
    }

    @Override
    public void despawnObject(Event event, Reflection reflection) {
        if (this._npc != null) {
            this._npc.removeEvent(event);
            this._npc.deleteMe();
            this._npc = null;
        }
    }

    @Override
    public void respawnObject(Event event, Reflection reflection) {
        if (this._npc != null && !this._npc.isVisible()) {
            this._npc.setCurrentHpMp(this._npc.getMaxHp(), this._npc.getMaxMp(), true);
            this._npc.setHeading(this._loc.h);
            this._npc.setReflection(reflection);
            this._npc.spawnMe(this._npc.getSpawnedLoc());
        }
    }

    @Override
    public void refreshObject(Event event, Reflection reflection) {
    }

    public NpcInstance getNpc() {
        return this._npc;
    }

    public Location getLoc() {
        return this._loc;
    }
}

