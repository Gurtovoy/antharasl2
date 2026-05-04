package l2s.gameserver.model;

import java.util.Collections;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.NpcHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.model.Spawner;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.templates.npc.MinionData;
import l2s.gameserver.templates.npc.NpcTemplate;
import l2s.gameserver.templates.spawn.SpawnRange;

public class MinionSpawner
extends Spawner {
    private final MinionData _minionData;
    private final NpcInstance _master;
    private final List<NpcInstance> _reSpawned = new CopyOnWriteArrayList<NpcInstance>();
    private Location _spawnLoc = null;

    public MinionSpawner(MinionData minionData, NpcInstance master) {
        int respawnTime;
        this._minionData = minionData;
        this._master = master;
        this._spawned = new CopyOnWriteArrayList();
        this._referenceCount = minionData.getAmount();
        this._maximumCount = minionData.getAmount();
        this._respawnDelay = respawnTime = minionData.getRespawnTime() == -1 ? (master.isRaid() ? Config.DEFAULT_RAID_MINIONS_RESPAWN_DELAY : 0) : minionData.getRespawnTime();
        this._respawnDelayRandom = 0;
        this._respawnPattern = null;
    }

    public void setLoc(Location loc) {
        this._spawnLoc = loc;
    }

    @Override
    public boolean isDoRespawn() {
        return super.isDoRespawn() && this._master.isVisible() && !this._master.isDead();
    }

    @Override
    public Reflection getReflection() {
        return this._master.getReflection();
    }

    @Override
    public String getName() {
        return "Privates of " + this._master.getName();
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
        NpcTemplate template = NpcHolder.getInstance().getTemplate(this._minionData.getMinionId());
        if (template == null) {
            this.decreaseCount0(null, null, oldNpc.getDeathTime());
            return;
        }
        NpcInstance npc = template.getNewInstance(this._minionData.getParameters());
        npc.setSpawn(this);
        this._reSpawned.add(npc);
        this.decreaseCount0(template, npc, oldNpc.getDeathTime());
    }

    @Override
    public NpcInstance doSpawn(boolean spawn) {
        NpcTemplate template = NpcHolder.getInstance().getTemplate(this._minionData.getMinionId());
        if (template == null) {
            return null;
        }
        return this.doSpawn0(template, spawn, this._minionData.getParameters(), Collections.emptyList());
    }

    @Override
    protected NpcInstance initNpc(NpcInstance mob, boolean spawn) {
        this._reSpawned.remove(mob);
        SpawnRange range = this.getRandomSpawnRange();
        mob.setSpawnRange(range);
        mob.setSpawnLeaderDepends(range != this._spawnLoc && !(range instanceof Territory));
        mob.setLeader(this._master);
        mob.setHeading(this._master.getHeading());
        mob.setRandomWalk(false);
        return this.initNpc0(mob, range.getRandomLoc(this.getReflection().getGeoIndex(), mob.isFlying()), spawn);
    }

    @Override
    public int getMainNpcId() {
        return this._minionData.getMinionId();
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

    @Override
    public SpawnRange getRandomSpawnRange() {
        if (this._spawnLoc != null) {
            return this._spawnLoc;
        }
        return this._master.getMinionList().getMinionSpawnRange(this._minionData);
    }

    @Override
    public void setAmount(int amount) {
    }

    @Override
    public void setRespawnDelay(int respawnDelay, int respawnDelayRandom) {
    }

    @Override
    public void setRespawnDelay(int respawnDelay) {
    }

    @Override
    public void setRespawnPattern(SchedulingPattern pattern) {
    }

    @Override
    public void setRespawnTime(int respawnTime) {
    }

    @Override
    public MinionSpawner clone() {
        return new MinionSpawner(this._minionData, this._master);
    }
}

