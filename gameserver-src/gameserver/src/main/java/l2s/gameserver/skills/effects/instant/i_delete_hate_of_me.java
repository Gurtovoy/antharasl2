/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.instances.MonsterInstance;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class i_delete_hate_of_me
extends i_abstract_effect {
    public i_delete_hate_of_me(EffectTemplate template) {
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
        MonsterInstance monster = (MonsterInstance)effected;
        monster.getAggroList().remove(effector, true);
        monster.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
    }
}

