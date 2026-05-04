/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_add_hate
extends i_abstract_effect {
    private final boolean _affectSummoner = this.getParams().getBool("affect_summoner", false);

    public i_add_hate(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        if (effected.isRaid()) {
            return false;
        }
        return effected.isMonster();
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        Player owner;
        Creature target = effector;
        if (this._affectSummoner && (owner = target.getPlayer()) != null) {
            target = owner;
        }
        if (this.getValue() > 0.0) {
            ((MonsterInstance)effected).getAggroList().addDamageHate(target, 0, (int)this.getValue());
        } else if (this.getValue() < 0.0) {
            ((MonsterInstance)effected).getAggroList().reduceHate(target, (int)(-this.getValue()));
        }
    }
}

