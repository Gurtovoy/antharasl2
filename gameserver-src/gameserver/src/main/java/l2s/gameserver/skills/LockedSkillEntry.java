/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills;

import l2s.gameserver.model.Skill;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;

public class LockedSkillEntry
extends SkillEntry {
    private final Skill _lockedSkill;

    protected LockedSkillEntry(SkillEntryType key, Skill value, Skill locked) {
        super(key, value);
        this._lockedSkill = locked;
    }

    @Override
    public Skill getLockedSkill() {
        return this._lockedSkill;
    }
}

