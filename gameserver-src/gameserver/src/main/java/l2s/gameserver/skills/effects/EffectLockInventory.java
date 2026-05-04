package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.items.LockType;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectLockInventory
extends EffectHandler {
    private LockType _lockType = (LockType)this.getParams().getEnum("lockType", LockType.class);
    private int[] _lockItems = this.getParams().getIntegerArray("lockItems");

    public EffectLockInventory(EffectTemplate template) {
        super(template);
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        Player player = effector.getPlayer();
        player.getInventory().lockItems(this._lockType, this._lockItems);
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        Player player = effector.getPlayer();
        player.getInventory().unlock();
    }
}

