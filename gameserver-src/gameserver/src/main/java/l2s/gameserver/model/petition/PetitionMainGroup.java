/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.petition;

import java.util.Collection;
import l2s.gameserver.model.petition.PetitionGroup;
import l2s.gameserver.model.petition.PetitionSubGroup;
import org.napile.primitive.maps.IntObjectMap;
import org.napile.primitive.maps.impl.HashIntObjectMap;

public class PetitionMainGroup
extends PetitionGroup {
    private final IntObjectMap<PetitionSubGroup> _subGroups = new HashIntObjectMap();

    public PetitionMainGroup(int id) {
        super(id);
    }

    public void addSubGroup(PetitionSubGroup subGroup) {
        this._subGroups.put(subGroup.getId(), subGroup);
    }

    public PetitionSubGroup getSubGroup(int val) {
        return (PetitionSubGroup)this._subGroups.get(val);
    }

    public Collection<PetitionSubGroup> getSubGroups() {
        return this._subGroups.valueCollection();
    }
}

