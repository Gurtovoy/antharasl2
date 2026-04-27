/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.TreeIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Zone;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.entity.residence.Residence;
import l2s.gameserver.model.entity.residence.ResidenceType;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.TreeIntObjectMap;

public final class ResidenceHolder
extends AbstractHolder {
    private static ResidenceHolder _instance = new ResidenceHolder();
    private IntObjectMap<Residence> _residences = new TreeIntObjectMap();

    public static ResidenceHolder getInstance() {
        return _instance;
    }

    private ResidenceHolder() {
    }

    public void addResidence(Residence r) {
        this._residences.put(r.getId(), r);
    }

    public <R extends Residence> R getResidence(int id) {
        return (R)((Residence)this._residences.get(id));
    }

    public <R extends Residence> R getResidence(Class<R> type, int id) {
        R r = this.getResidence(id);
        if (r == null || r.getClass() != type && !type.isAssignableFrom(r.getClass())) {
            return null;
        }
        return r;
    }

    @SuppressWarnings("unchecked")
    public <R extends Residence> List<R> getResidenceList(Class<R> t) {
        ArrayList<Residence> residences = new ArrayList<Residence>();
        for (Residence r : this._residences.valueCollection()) {
            if (r.getClass() != t && !t.isAssignableFrom(r.getClass())) continue;
            residences.add(r);
        }
        return (List<R>)(List<?>)residences;
    }

    public Collection<Residence> getResidences() {
        return this._residences.valueCollection();
    }

    public <R extends Residence> R getResidenceByObject(Class<? extends Residence> type, GameObject object) {
        return (R)this.getResidenceByCoord(type, object.getX(), object.getY(), object.getZ(), object.getReflection());
    }

    @SuppressWarnings("unchecked")
    public <R extends Residence> R getResidenceByCoord(Class<R> type, int x, int y, int z, Reflection ref) {
        Collection<? extends Residence> residences = type == null ? this.getResidences() : this.getResidenceList(type);
        for (Residence residence : residences) {
            if (!residence.checkIfInZone(x, y, z, ref)) continue;
            return (R)residence;
        }
        return null;
    }

    @SuppressWarnings("unchecked")
    public <R extends Residence> R findNearestResidence(Class<R> clazz, int x, int y, int z, Reflection ref, int offset) {
        R residence = this.getResidenceByCoord(clazz, x, y, z, ref);
        if (residence == null) {
            double closestDistance = offset;
            for (Residence r : this.getResidenceList(clazz)) {
                double distance;
                Zone zone = r.getZone();
                if (zone == null || !(closestDistance > (distance = zone.findDistanceToZone(x, y, z, false)))) continue;
                closestDistance = distance;
                residence = (R) r;
            }
        }
        return residence;
    }

    public void callInit() {
        for (Residence r : this.getResidences()) {
            r.init();
        }
    }

    public void log() {
        this.info("total size: " + this._residences.size());
        for (ResidenceType type : ResidenceType.VALUES) {
            int count = 0;
            for (Residence r : this.getResidences()) {
                if (r.getType() != type) continue;
                ++count;
            }
            this.info(" - load " + count + " " + String.valueOf((Object)type).toLowerCase() + "(s).");
        }
    }

    public int size() {
        return this._residences.size();
    }

    public void clear() {
        this._residences.clear();
    }
}

