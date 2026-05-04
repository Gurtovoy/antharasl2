/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.commons.util.Rnd;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.spawn.SpawnNpcInfo;
import l2s.gameserver.templates.spawn.SpawnPoint;
import l2s.gameserver.templates.spawn.SpawnRange;
import l2s.gameserver.templates.spawn.SpawnTemplate;

public class HardSpawner
extends Spawner {
    private final SpawnTemplate _template;
    private final List<NpcInstance> _reSpawned = new CopyOnWriteArrayList<NpcInstance>();

    public HardSpawner(SpawnTemplate template) {
        this._template = template;
        this._spawned = new CopyOnWriteArrayList();
    }

    @Override
    public String getName() {
        return this._template.getName();
    }

    @Override
    public void decreaseCount(NpcInstance oldNpc) {
        oldNpc.setSpawn(null);
        oldNpc.deleteMe();
        if (!this._spawned.remove(oldNpc)) {
            return;
        }
        if (!this.hasRespawn()) {
            this.decreaseCount0(null, null, oldNpc.getDeathTime());
            return;
        }
        SpawnNpcInfo npcInfo = this.getRandomNpcInfo();
        NpcInstance npc = npcInfo.getTemplate().getNewInstance(npcInfo.getParameters());
        npc.setSpawn(this);
        List<MinionData> minionsData = npcInfo.getMinionData();
        if (!minionsData.isEmpty()) {
            for (MinionData minionData : minionsData) {
                npc.getMinionList().addMinion(minionData);
            }
        }
        this._reSpawned.add(npc);
        this.decreaseCount0(npcInfo.getTemplate(), npc, oldNpc.getDeathTime());
    }

    @Override
    public NpcInstance doSpawn(boolean spawn) {
        SpawnNpcInfo npcInfo = this.getRandomNpcInfo();
        return this.doSpawn0(npcInfo.getTemplate(), spawn, npcInfo.getParameters(), npcInfo.getMinionData());
    }

    @Override
    protected NpcInstance initNpc(NpcInstance mob, boolean spawn) {
        this._reSpawned.remove(mob);
        SpawnRange range = this.getRandomSpawnRange();
        mob.setSpawnRange(range);
        return this.initNpc0(mob, range.getRandomLoc(this.getReflection().getGeoIndex(), mob.isFlying()), spawn);
    }

    @Override
    public int getMainNpcId() {
        return this._template.getNpcId(0).getTemplate().getId();
    }

    @Override
    public void respawnNpc(NpcInstance oldNpc) {
        this.initNpc(oldNpc, true);
    }

    @Override
    public void deleteAll() {
        super.deleteAll();
        for (NpcInstance npc : this._reSpawned) {
            npc.setSpawn(null);
            npc.deleteMe();
        }
        this._reSpawned.clear();
    }

    private SpawnNpcInfo getRandomNpcInfo() {
        return (SpawnNpcInfo)Rnd.get(this._template.getNpcList());
    }

    @Override
    public SpawnRange getRandomSpawnRange() {
        List<SpawnPoint> spawnPoints = this._template.getSpawnPointList();
        if (!spawnPoints.isEmpty()) {
            return (SpawnRange)Rnd.get(spawnPoints);
        }
        return (SpawnRange)Rnd.get(this._template.getTerritoryList());
    }

    @Override
    public SpawnTemplate getTemplate() {
        return this._template;
    }

    @Override
    public HardSpawner clone() {
        HardSpawner spawnDat = new HardSpawner(this._template);
        spawnDat.setAmount(this._maximumCount);
        spawnDat.setRespawnDelay(this.getRespawnDelay(), this.getRespawnDelayRandom());
        spawnDat.setRespawnPattern(this.getRespawnPattern());
        spawnDat.setRespawnTime(0);
        return spawnDat;
    }
}

