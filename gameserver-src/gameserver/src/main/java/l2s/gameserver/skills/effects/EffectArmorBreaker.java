package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectArmorBreaker
extends EffectHandler {
    public EffectArmorBreaker(EffectTemplate template) {
        super(template);
    }

    @Override
    public EffectHandler getImpl() {
        return new EffectArmorBreakerImpl(this.getTemplate());
    }

    private class EffectArmorBreakerImpl
    extends EffectHandler {
        private ItemInstance _item;

        public EffectArmorBreakerImpl(EffectTemplate template) {
            super(template);
        }

        @Override
        protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
            if (!effected.isPlayer()) {
                return false;
            }
            return effected.getPlayer().getInventory().getPaperdollItem(10) != null;
        }

        @Override
        public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
            this._item = effected.getPlayer().getInventory().getPaperdollItem(10);
            effected.getPlayer().getInventory().unEquipItem(this._item);
        }

        @Override
        public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
            effected.getPlayer().getInventory().equipItem(this._item);
        }
    }
}

