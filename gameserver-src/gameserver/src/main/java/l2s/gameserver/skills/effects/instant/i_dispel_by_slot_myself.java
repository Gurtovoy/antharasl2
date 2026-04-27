/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.skills.effects.instant.i_dispel_by_slot;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_dispel_by_slot_myself
extends i_dispel_by_slot {
    public i_dispel_by_slot_myself(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean isSelf() {
        return true;
    }
}

