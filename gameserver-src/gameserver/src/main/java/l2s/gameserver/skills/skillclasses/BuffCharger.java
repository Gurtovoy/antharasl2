/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.templates.StatsSet;

public class BuffCharger
extends Skill {
    private int _target;

    public BuffCharger(StatsSet set) {
        super(set);
        this._target = set.getInteger("targetBuff", 0);
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        Skill next;
        int level = 0;
        for (Abnormal effect : target.getAbnormalList()) {
            if (effect.getSkill().getId() != this._target) continue;
            level = effect.getSkill().getLevel();
            break;
        }
        if ((next = SkillHolder.getInstance().getSkill(this._target, level + 1)) != null) {
            next.getEffects(activeChar, target);
        } else {
            next = SkillHolder.getInstance().getSkill(this._target, level);
            if (next != null) {
                next.getEffects(activeChar, target);
            }
        }
    }
}

