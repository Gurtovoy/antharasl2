/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_unsummon_agathion
extends i_abstract_effect {
    public i_unsummon_agathion(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        if (!effected.isPlayer()) {
            return false;
        }
        Player player = effected.getPlayer();
        return player.getAgathion() != null;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        Player player = effected.getPlayer();
        if (player == null) {
            return;
        }
        player.deleteAgathion();
    }
}

