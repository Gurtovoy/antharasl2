/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.stats.conditions;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.player.Mount;
import l2s.gameserver.model.instances.PetInstance;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;

public class ConditionTargetPetFeed
extends Condition {
    private final int _itemId;

    public ConditionTargetPetFeed(int itemId) {
        this._itemId = itemId;
    }

    @Override
    protected boolean testImpl(Env env) {
        Creature target = env.character;
        if (target.isPet()) {
            PetInstance pet = (PetInstance)target;
            return pet.isMyFeed(this._itemId);
        }
        if (target.isPlayer() && target.getPlayer().isMounted()) {
            Mount mount = target.getPlayer().getMount();
            return mount.isMyFeed(this._itemId);
        }
        return false;
    }
}

