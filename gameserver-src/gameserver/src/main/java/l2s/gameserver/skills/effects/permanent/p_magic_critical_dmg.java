/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.skills.effects.permanent.p_abstract_stat_effect;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class p_magic_critical_dmg
extends p_abstract_stat_effect {
    public p_magic_critical_dmg(EffectTemplate template) {
        super(template, Stats.MAGIC_CRITICAL_DMG);
    }
}

