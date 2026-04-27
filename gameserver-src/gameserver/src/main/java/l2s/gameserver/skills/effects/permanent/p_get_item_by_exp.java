/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.listener.actor.player.OnExpReceiveListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.skill.EffectTemplate;
import l2s.gameserver.utils.ItemFunctions;

public final class p_get_item_by_exp
extends EffectHandler {
    private final long _exp = this.getTemplate().getParams().getLong("exp");
    private final int _itemId = this.getTemplate().getParams().getInteger("item_id");
    private final long _itemCount = this.getTemplate().getParams().getLong("item_count");

    public p_get_item_by_exp(EffectTemplate template) {
        super(template);
    }

    @Override
    public EffectHandler getImpl() {
        return new p_get_item_by_exp_impl(this.getTemplate());
    }

    private class p_get_item_by_exp_impl
    extends EffectHandler {
        private final Listener _listener;
        private long _receivedExp;

        public p_get_item_by_exp_impl(EffectTemplate template) {
            super(template);
            this._listener = new Listener();
            this._receivedExp = 0L;
        }

        @Override
        protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
            return effected.isPlayer();
        }

        @Override
        public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
            effected.addListener(this._listener);
        }

        @Override
        public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
            effected.removeListener(this._listener);
        }

        private class Listener
        implements OnExpReceiveListener {
            private Listener() {
            }

            @Override
            public void onExpReceive(Player player, long value, boolean hunting) {
                if (hunting) {
                    p_get_item_by_exp_impl.this._receivedExp = p_get_item_by_exp_impl.this._receivedExp + value;
                    if (p_get_item_by_exp_impl.this._receivedExp >= p_get_item_by_exp.this._exp) {
                        p_get_item_by_exp_impl.this._receivedExp = 0L;
                        ItemFunctions.addItem(player, p_get_item_by_exp.this._itemId, p_get_item_by_exp.this._itemCount, true);
                    }
                }
            }
        }
    }
}

