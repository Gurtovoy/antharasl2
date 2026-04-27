/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.model;

import java.util.ArrayList;
import java.util.Collections;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.spawn.SpawnRange;

public class SimpleSpawner
extends Spawner
implements Cloneable {
    private NpcTemplate _npcTemplate;
    private SpawnRange _spawnRange;

    public SimpleSpawner(NpcTemplate mobTemplate) {
        if (mobTemplate == null) {
            throw new NullPointerException();
        }
        this._npcTemplate = mobTemplate;
        this._spawned = new ArrayList(1);
    }

    public SimpleSpawner(int npcId) {
        NpcTemplate mobTemplate = NpcHolder.getInstance().getTemplate(npcId);
        if (mobTemplate == null) {
            throw new NullPointerException("Not find npc: " + npcId);
        }
        this._npcTemplate = mobTemplate;
        this._spawned = new ArrayList(1);
    }

    public SpawnRange getSpawnRange() {
        return this._spawnRange;
    }

    public void setSpawnRange(SpawnRange spawnRange) {
        this._spawnRange = spawnRange;
    }

    public void restoreAmount() {
        this._maximumCount = this._referenceCount;
    }

    @Override
    public int getMainNpcId() {
        return this._npcTemplate.getId();
    }

    @Override
    public SpawnRange getRandomSpawnRange() {
        return this._spawnRange;
    }

    @Override
    public void decreaseCount(NpcInstance oldNpc) {
        this.decreaseCount0(this._npcTemplate, oldNpc, oldNpc.getDeathTime());
    }

    @Override
    public NpcInstance doSpawn(boolean spawn) {
        return this.doSpawn0(this._npcTemplate, spawn, StatsSet.EMPTY, Collections.emptyList());
    }

    @Override
    protected NpcInstance initNpc(NpcInstance mob, boolean spawn) {
        SpawnRange range = this.getRandomSpawnRange();
        mob.setSpawnRange(range);
        return this.initNpc0(mob, range.getRandomLoc(this.getReflection().getGeoIndex(), mob.isFlying()), spawn);
    }

    @Override
    public void respawnNpc(NpcInstance oldNpc) {
        oldNpc.refreshID();
        this.initNpc(oldNpc, true);
    }

    @Override
    public SimpleSpawner clone() {
        SimpleSpawner spawnDat = new SimpleSpawner(this._npcTemplate);
        spawnDat.setSpawnRange(this._spawnRange);
        spawnDat.setAmount(this._maximumCount);
        spawnDat.setRespawnDelay(this.getRespawnDelay(), this.getRespawnDelayRandom());
        spawnDat.setRespawnPattern(this.getRespawnPattern());
        return spawnDat;
    }
}

