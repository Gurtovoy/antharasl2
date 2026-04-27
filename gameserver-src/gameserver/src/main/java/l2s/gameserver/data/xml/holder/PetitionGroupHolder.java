/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.data.xml.AbstractHolder
 *  org.napile.primitive.maps.IntObjectMap
 *  org.napile.primitive.maps.impl.HashIntObjectMap
 */
package l2s.gameserver.data.xml.holder;

import java.util.Collection;
import l2s.commons.data.xml.AbstractHolder;
import l2s.gameserver.model.petition.PetitionMainGroup;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public class PetitionGroupHolder
extends AbstractHolder {
    private static PetitionGroupHolder _instance = new PetitionGroupHolder();
    private IntObjectMap<PetitionMainGroup> _petitionGroups = new HashIntObjectMap();

    public static PetitionGroupHolder getInstance() {
        return _instance;
    }

    private PetitionGroupHolder() {
    }

    public void addPetitionGroup(PetitionMainGroup g) {
        this._petitionGroups.put(g.getId(), g);
    }

    public PetitionMainGroup getPetitionGroup(int val) {
        return (PetitionMainGroup)this._petitionGroups.get(val);
    }

    public Collection<PetitionMainGroup> getPetitionGroups() {
        return this._petitionGroups.valueCollection();
    }

    public int size() {
        return this._petitionGroups.size();
    }

    public void clear() {
        this._petitionGroups.clear();
    }
}

