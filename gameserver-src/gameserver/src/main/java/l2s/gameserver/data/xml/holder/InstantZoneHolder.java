/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  l2s.commons.time.cron.SchedulingPattern
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.HashIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import l2s.commons.data.xml.AbstractHolder;
import l2s.commons.time.cron.SchedulingPattern;
import l2s.gameserver.model.Player;
import l2s.gameserver.templates.InstantZone;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public class InstantZoneHolder
extends AbstractHolder {
    private static final InstantZoneHolder _instance = new InstantZoneHolder();
    private IntObjectMap<InstantZone> _zones = new HashIntObjectMap();

    public static InstantZoneHolder getInstance() {
        return _instance;
    }

    public void addInstantZone(InstantZone zone) {
        this._zones.put(zone.getId(), zone);
    }

    public InstantZone getInstantZone(int id) {
        return (InstantZone)this._zones.get(id);
    }

    private SchedulingPattern getResetReuseById(int id) {
        InstantZone zone = this.getInstantZone(id);
        return zone == null ? null : zone.getResetReuse();
    }

    public int getMinutesToNextEntrance(int id, Player player) {
        SchedulingPattern resetReuse = this.getResetReuseById(id);
        if (resetReuse == null) {
            return 0;
        }
        Long time = null;
        if (this.getSharedReuseInstanceIds(id) != null && !this.getSharedReuseInstanceIds(id).isEmpty()) {
            ArrayList<Long> reuses = new ArrayList<Long>();
            for (int i : this.getSharedReuseInstanceIds(id)) {
                if (player.getInstanceReuse(i) == null) continue;
                reuses.add(player.getInstanceReuse(i));
            }
            if (!reuses.isEmpty()) {
                Collections.sort(reuses);
                time = (Long)reuses.get(reuses.size() - 1);
            }
        } else {
            time = player.getInstanceReuse(id);
        }
        if (time == null) {
            return 0;
        }
        return (int)Math.max((resetReuse.next(time.longValue()) - System.currentTimeMillis()) / 60000L, 0L);
    }

    public List<Integer> getLockedInstancesList(Player player) {
        if (player.getInstanceReuses().isEmpty()) {
            return Collections.emptyList();
        }
        ArrayList<Integer> result = new ArrayList<Integer>();
        for (Map.Entry<Integer, Long> reuse : player.getInstanceReuses().entrySet()) {
            SchedulingPattern resetReuse;
            if (reuse == null || reuse.getKey() == null || reuse.getValue() == null || (resetReuse = this.getResetReuseById(reuse.getKey())) == null || resetReuse.next(reuse.getValue().longValue()) <= System.currentTimeMillis()) continue;
            result.add(reuse.getKey());
        }
        return result;
    }

    public List<Integer> getSharedReuseInstanceIds(int id) {
        if (this.getInstantZone(id).getSharedReuseGroup() < 1) {
            return null;
        }
        ArrayList<Integer> sharedInstanceIds = new ArrayList<Integer>();
        for (InstantZone iz : this._zones.valueCollection()) {
            if (iz.getSharedReuseGroup() <= 0 || this.getInstantZone(id).getSharedReuseGroup() <= 0 || iz.getSharedReuseGroup() != this.getInstantZone(id).getSharedReuseGroup()) continue;
            sharedInstanceIds.add(iz.getId());
        }
        return sharedInstanceIds;
    }

    public List<Integer> getSharedReuseInstanceIdsByGroup(int groupId) {
        if (groupId < 1) {
            return null;
        }
        ArrayList<Integer> sharedInstanceIds = new ArrayList<Integer>();
        for (InstantZone iz : this._zones.valueCollection()) {
            if (iz.getSharedReuseGroup() <= 0 || iz.getSharedReuseGroup() != groupId) continue;
            sharedInstanceIds.add(iz.getId());
        }
        return sharedInstanceIds;
    }

    public int size() {
        return this._zones.size();
    }

    public void clear() {
        this._zones.clear();
    }
}

