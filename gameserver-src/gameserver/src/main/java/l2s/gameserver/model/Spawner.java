/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.collections.MultiValueSet
 *  l2s.commons.time.cron.SchedulingPattern
 *  l2s.commons.util.Rnd
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.List;
import l2s.commons.collections.MultiValueSet;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.events.Event;
import l2s.gameserver.model.entity.events.EventOwner;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.taskmanager.SpawnTaskManager;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.templates.spawn.SpawnTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class Spawner
extends EventOwner
implements Cloneable {
    protected static final Logger _log = LoggerFactory.getLogger(Spawner.class);
    protected static final int MIN_RESPAWN_DELAY = 20;
    protected int _maximumCount;
    protected int _referenceCount;
    protected int _currentCount;
    protected int _scheduledCount;
    protected int _respawnDelay;
    protected int _respawnDelayRandom;
    protected SchedulingPattern _respawnPattern;
    protected int _respawnTime;
    protected boolean _doRespawn;
    protected NpcInstance _lastSpawn;
    protected List<NpcInstance> _spawned;
    protected Reflection _reflection = ReflectionManager.MAIN;

    public String getName() {
        return "";
    }

    public void decreaseScheduledCount() {
        if (this._scheduledCount > 0) {
            --this._scheduledCount;
        }
    }

    public boolean isDoRespawn() {
        return this._doRespawn;
    }

    public Reflection getReflection() {
        return this._reflection;
    }

    public void setReflection(Reflection reflection) {
        this._reflection = reflection;
        for (NpcInstance npc : this._spawned) {
            npc.setReflection(reflection);
        }
    }

    public int getRespawnDelay() {
        return this._respawnDelay;
    }

    public int getRespawnDelayRandom() {
        return this._respawnDelayRandom;
    }

    public int getRespawnDelayWithRnd() {
        return this._respawnDelayRandom == 0 ? this._respawnDelay : Rnd.get((int)(this._respawnDelay - this._respawnDelayRandom), (int)this._respawnDelay);
    }

    public SchedulingPattern getRespawnPattern() {
        return this._respawnPattern;
    }

    public boolean hasRespawn() {
        return this.getRespawnDelay() != 0 || this.getRespawnDelayRandom() != 0 || this.getRespawnPattern() != null;
    }

    public int getRespawnTime() {
        return this._respawnTime;
    }

    public NpcInstance getLastSpawn() {
        return this._lastSpawn;
    }

    public void setAmount(int amount) {
        if (this._referenceCount == 0) {
            this._referenceCount = amount;
        }
        this._maximumCount = amount;
    }

    public void deleteAll() {
        this.stopRespawn();
        for (NpcInstance npc : this._spawned) {
            npc.deleteMe();
        }
        this._spawned.clear();
        this._respawnTime = 0;
        this._scheduledCount = 0;
        this._currentCount = 0;
    }

    public abstract void decreaseCount(NpcInstance var1);

    public abstract NpcInstance doSpawn(boolean var1);

    public abstract void respawnNpc(NpcInstance var1);

    protected abstract NpcInstance initNpc(NpcInstance var1, boolean var2);

    public abstract int getMainNpcId();

    public abstract SpawnRange getRandomSpawnRange();

    public abstract Spawner clone();

    public int init() {
        while (this._currentCount + this._scheduledCount < this._maximumCount) {
            this.doSpawn(false);
        }
        this._doRespawn = true;
        return this._currentCount;
    }

    public NpcInstance spawnOne() {
        return this.doSpawn(false);
    }

    public void stopRespawn() {
        this._doRespawn = false;
    }

    public void startRespawn() {
        this._doRespawn = true;
    }

    public List<NpcInstance> getAllSpawned() {
        return this._spawned;
    }

    public NpcInstance getFirstSpawned() {
        List<NpcInstance> npcs = this.getAllSpawned();
        return npcs.size() > 0 ? npcs.get(0) : null;
    }

    public void setRespawnDelay(int respawnDelay, int respawnDelayRandom) {
        if (respawnDelay < 0) {
            _log.warn("respawn delay is negative");
        }
        this._respawnDelay = respawnDelay;
        this._respawnDelayRandom = respawnDelayRandom;
    }

    public void setRespawnDelay(int respawnDelay) {
        this.setRespawnDelay(respawnDelay, 0);
    }

    public void setRespawnPattern(SchedulingPattern pattern) {
        this._respawnPattern = pattern;
    }

    public void setRespawnTime(int respawnTime) {
        this._respawnTime = respawnTime;
    }

    protected NpcInstance doSpawn0(NpcTemplate template, boolean spawn, MultiValueSet<String> set, List<MinionData> minions) {
        if (template.isInstanceOf(PetInstance.class)) {
            ++this._currentCount;
            return null;
        }
        NpcInstance tmp = template.getNewInstance(set);
        if (tmp == null) {
            return null;
        }
        if (!minions.isEmpty()) {
            for (MinionData minionData : minions) {
                tmp.getMinionList().addMinion(minionData);
            }
        }
        if (!spawn) {
            spawn = (long)this._respawnTime <= System.currentTimeMillis() / 1000L + 20L;
        }
        return this.initNpc(tmp, spawn);
    }

    protected NpcInstance initNpc0(NpcInstance mob, Location newLoc, boolean spawn) {
        mob.setCurrentHpMp(mob.getMaxHp(), mob.getMaxMp(), true);
        mob.setSpawn(this);
        mob.setSpawnedLoc(newLoc);
        mob.setUnderground(GeoEngine.getLowerHeight(newLoc, this.getReflection().getGeoIndex()) < GeoEngine.getLowerHeight(newLoc.clone().changeZ(5000), this.getReflection().getGeoIndex()));
        for (Event e : this.getEvents()) {
            mob.addEvent(e);
        }
        if (spawn) {
            mob.setReflection(this.getReflection());
            if (mob.isMonster()) {
                ((MonsterInstance)mob).setChampion();
            }
            mob.spawnMe(newLoc);
            ++this._currentCount;
        } else {
            mob.setLoc(newLoc);
            ++this._scheduledCount;
            SpawnTaskManager.getInstance().addSpawnTask(mob, (long)this._respawnTime * 1000L - System.currentTimeMillis());
        }
        this._spawned.add(mob);
        this._lastSpawn = mob;
        return mob;
    }

    public void decreaseCount0(NpcTemplate template, NpcInstance spawnedNpc, long deathTime) {
        --this._currentCount;
        if (this._currentCount < 0) {
            this._currentCount = 0;
        }
        if (template == null || spawnedNpc == null) {
            return;
        }
        if (!this.hasRespawn()) {
            return;
        }
        if (this.isDoRespawn() && this._scheduledCount + this._currentCount < this._maximumCount) {
            ++this._scheduledCount;
            this._respawnTime = Math.max(this.calcRespawnTime(deathTime, template.isRaid), (int)((System.currentTimeMillis() + 1000L) / 1000L));
            SpawnTaskManager.getInstance().addSpawnTask(spawnedNpc, (long)this._respawnTime * 1000L - System.currentTimeMillis());
        }
    }

    public int calcRespawnTime(long deathTime, boolean isRaid) {
        int respawnTime;
        if (this.getRespawnPattern() != null) {
            respawnTime = (int)(this.getRespawnPattern().next(deathTime) / 1000L);
        } else {
            long delay = (long)(isRaid ? Config.ALT_RAID_RESPAWN_MULTIPLIER : 1.0) * (long)this.getRespawnDelayWithRnd() * 1000L;
            respawnTime = (int)((deathTime + delay) / 1000L);
        }
        return respawnTime;
    }

    public List<NpcInstance> initAndReturn() {
        ArrayList<NpcInstance> spawnedNpcs = new ArrayList<NpcInstance>();
        while (this._currentCount + this._scheduledCount < this._maximumCount) {
            spawnedNpcs.add(this.doSpawn(false));
        }
        this._doRespawn = true;
        return spawnedNpcs;
    }

    public SpawnTemplate getTemplate() {
        return null;
    }
}

