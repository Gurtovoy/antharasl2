/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.templates.npc.NpcTemplate;

public class SpecialMonsterInstance
extends MonsterInstance {
    public SpecialMonsterInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    public boolean canChampion() {
        return false;
    }
}

