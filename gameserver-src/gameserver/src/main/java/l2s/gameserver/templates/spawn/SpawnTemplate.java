package l2s.gameserver.templates.spawn;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.geometry.Territory;
import l2s.gameserver.templates.spawn.PeriodOfDay;
import l2s.gameserver.templates.spawn.SpawnNpcInfo;
import l2s.gameserver.templates.spawn.SpawnPoint;
import org.apache.commons.lang3.StringUtils;

public class SpawnTemplate {
    private String _name;
    private final PeriodOfDay _periodOfDay;
    private final int _count;
    private final int _respawn;
    private final int _respawnRandom;
    private final SchedulingPattern _respawnPattern;
    private final List<SpawnNpcInfo> _npcList = new ArrayList<SpawnNpcInfo>(1);
    private List<SpawnPoint> _spawnPointList = Collections.emptyList();
    private List<Territory> _territoryList = Collections.emptyList();

    public SpawnTemplate(String name, PeriodOfDay periodOfDay, int count, int respawn, int respawnRandom, String respawnPattern) {
        this._name = name;
        this._periodOfDay = periodOfDay;
        this._count = count;
        this._respawn = respawn;
        this._respawnRandom = respawnRandom;
        this._respawnPattern = respawnPattern == null || respawnPattern.isEmpty() ? null : new SchedulingPattern(respawnPattern);
    }

    public void addSpawnPoint(SpawnPoint loc) {
        if (this._spawnPointList.isEmpty()) {
            this._spawnPointList = new ArrayList<SpawnPoint>(1);
            if (StringUtils.isEmpty((CharSequence)this._name)) {
                this._name = "point: " + loc.getLoc().toXYZString();
            }
        }
        this._spawnPointList.add(loc);
    }

    public SpawnPoint getSpawnPoint(int index) {
        return this._spawnPointList.get(index);
    }

    public void addNpc(SpawnNpcInfo info) {
        this._npcList.add(info);
    }

    public SpawnNpcInfo getNpcId(int index) {
        return this._npcList.get(index);
    }

    public void addTerritory(String name, Territory territory) {
        if (this._territoryList.isEmpty()) {
            this._territoryList = new ArrayList<Territory>(1);
            if (StringUtils.isEmpty((CharSequence)this._name)) {
                this._name = name;
            }
        }
        this._territoryList.add(territory);
    }

    public Territory getTerritory(int index) {
        return this._territoryList.get(index);
    }

    public List<SpawnNpcInfo> getNpcList() {
        return this._npcList;
    }

    public List<SpawnPoint> getSpawnPointList() {
        return this._spawnPointList;
    }

    public List<Territory> getTerritoryList() {
        return this._territoryList;
    }

    public String getName() {
        return this._name;
    }

    public int getCount() {
        return this._count;
    }

    public int getRespawn() {
        return this._respawn;
    }

    public int getRespawnRandom() {
        return this._respawnRandom;
    }

    public SchedulingPattern getRespawnPattern() {
        return this._respawnPattern;
    }

    public PeriodOfDay getPeriodOfDay() {
        return this._periodOfDay;
    }
}

