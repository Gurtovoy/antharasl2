package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.instances.ReflectionBossInstance;
import l2s.gameserver.templates.npc.NpcTemplate;

public class ArenaRaidInstance
extends ReflectionBossInstance {
    public ArenaRaidInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    protected boolean clearReflectionOnDeath() {
        return false;
    }

    @Override
    public boolean isArenaRaid() {
        return true;
    }
}

