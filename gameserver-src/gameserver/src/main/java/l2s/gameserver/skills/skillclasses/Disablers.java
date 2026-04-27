/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.skillclasses;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.StatsSet;

public class Disablers
extends Skill {
    private final boolean _skillInterrupt;

    public Disablers(StatsSet set) {
        super(set);
        this._skillInterrupt = set.getBool("skillInterrupt", false);
    }

    @Override
    protected void useSkill(Creature activeChar, Creature target, boolean reflected) {
        Creature realTarget;
        Creature creature = realTarget = reflected ? activeChar : target;
        if (this._skillInterrupt && !realTarget.isRaid()) {
            SkillEntry skillEntry = realTarget.getSkillCast(SkillCastingType.NORMAL).getSkillEntry();
            if (skillEntry != null && !skillEntry.getTemplate().isMagic()) {
                realTarget.abortCast(false, true, true, false);
            }
            if ((skillEntry = realTarget.getSkillCast(SkillCastingType.NORMAL_SECOND).getSkillEntry()) != null && !skillEntry.getTemplate().isMagic()) {
                realTarget.abortCast(false, true, false, true);
            }
            realTarget.abortAttack(true, true);
        }
    }
}

