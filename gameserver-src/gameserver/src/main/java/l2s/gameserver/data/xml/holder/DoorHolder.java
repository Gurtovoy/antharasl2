/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.HashIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.templates.DoorTemplate;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public final class DoorHolder
extends AbstractHolder {
    private static final DoorHolder _instance = new DoorHolder();
    private IntObjectMap<DoorTemplate> _doors = new HashIntObjectMap();

    public static DoorHolder getInstance() {
        return _instance;
    }

    public void addTemplate(DoorTemplate door) {
        this._doors.put(door.getId(), door);
    }

    public DoorTemplate getTemplate(int doorId) {
        return (DoorTemplate)this._doors.get(doorId);
    }

    public IntObjectMap<DoorTemplate> getDoors() {
        return this._doors;
    }

    public int size() {
        return this._doors.size();
    }

    public void clear() {
        this._doors.clear();
    }
}

