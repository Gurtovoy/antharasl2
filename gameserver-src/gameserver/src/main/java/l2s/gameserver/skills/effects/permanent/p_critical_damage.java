/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.skills.effects.permanent.p_abstract_stat_effect;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class p_critical_damage
extends p_abstract_stat_effect {
    public p_critical_damage(EffectTemplate template) {
        super(template, Stats.CRITICAL_DAMAGE);
    }
}

