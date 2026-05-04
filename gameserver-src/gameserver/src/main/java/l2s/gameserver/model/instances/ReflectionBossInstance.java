/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.model.instances;

import l2s.commons.collections.MultiValueSet;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.entity.Reflection;
import l2s.gameserver.model.instances.RaidBossInstance;
import l2s.gameserver.templates.npc.NpcTemplate;

public class ReflectionBossInstance
extends RaidBossInstance {
    private static final int COLLAPSE_AFTER_DEATH_TIME = 5;

    public ReflectionBossInstance(int objectId, NpcTemplate template, MultiValueSet<String> set) {
        super(objectId, template, set);
    }

    @Override
    protected void onDeath(Creature killer) {
        super.onDeath(killer);
        if (this.clearReflectionOnDeath()) {
            this.clearReflection();
        }
    }

    protected boolean clearReflectionOnDeath() {
        return true;
    }

    protected void clearReflection() {
        Reflection reflection = this.getReflection();
        if (!reflection.isDefault()) {
            reflection.startCollapseTimer(5, true);
        }
    }

    @Override
    public boolean isReflectionBoss() {
        return true;
    }
}

