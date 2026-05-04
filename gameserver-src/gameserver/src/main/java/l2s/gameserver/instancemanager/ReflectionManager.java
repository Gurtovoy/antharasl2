/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.instancemanager;

import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import l2s.gameserver.data.xml.holder.DoorHolder;
import l2s.gameserver.data.xml.holder.ZoneHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.entity.Reflection;

public class ReflectionManager {
    public static final Reflection MAIN = Reflection.createReflection(0);
    public static final Reflection PARNASSUS = Reflection.createReflection(-1);
    public static final Reflection GIRAN_HARBOR = Reflection.createReflection(-2);
    public static final Reflection JAIL = Reflection.createReflection(-3);
    private static final ReflectionManager _instance = new ReflectionManager();
    private final TIntObjectHashMap<Reflection> _reflections = new TIntObjectHashMap();
    private final ReadWriteLock lock = new ReentrantReadWriteLock();
    private final Lock readLock = this.lock.readLock();
    private final Lock writeLock = this.lock.writeLock();

    public static ReflectionManager getInstance() {
        return _instance;
    }

    private ReflectionManager() {
    }

    public void init() {
        this.add(MAIN);
        this.add(PARNASSUS);
        this.add(GIRAN_HARBOR);
        this.add(JAIL);
        MAIN.init(DoorHolder.getInstance().getDoors(), ZoneHolder.getInstance().getZones());
        JAIL.setCoreLoc(new Location(-114648, -249384, -2984));
    }

    public Reflection get(int id) {
        this.readLock.lock();
        try {
            Reflection reflection = (Reflection)this._reflections.get(id);
            return reflection;
        }
        finally {
            this.readLock.unlock();
        }
    }

    public Reflection add(Reflection ref) {
        this.writeLock.lock();
        try {
            Reflection reflection = (Reflection)this._reflections.put(ref.getId(), ref);
            return reflection;
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public Reflection remove(Reflection ref) {
        this.writeLock.lock();
        try {
            Reflection reflection = (Reflection)this._reflections.remove(ref.getId());
            return reflection;
        }
        finally {
            this.writeLock.unlock();
        }
    }

    public Reflection[] getAll() {
        this.readLock.lock();
        try {
            Reflection[] reflectionArray = (Reflection[])this._reflections.values(new Reflection[this._reflections.size()]);
            return reflectionArray;
        }
        finally {
            this.readLock.unlock();
        }
    }

    
    public List<Reflection> getAllByIzId(int izId) {
        ArrayList<Reflection> reflections = new ArrayList<Reflection>();
        this.readLock.lock();
        try {
            for (Reflection r : this.getAll()) {
                if (r.getInstancedZoneId() != izId) continue;
                reflections.add(r);
            }
        }
        finally {
            this.readLock.unlock();
        }
        return reflections;
    }

    
    public int getCountByIzId(int izId) {
        this.readLock.lock();
        try {
            int i = 0;
            for (Reflection r : this.getAll()) {
                if (r.getInstancedZoneId() != izId) continue;
                ++i;
            }
            int n = i;
            return n;
        }
        finally {
            this.readLock.unlock();
        }
    }

    public int size() {
        return this._reflections.size();
    }
}

