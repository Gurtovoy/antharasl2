/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.StatTemplate;

public class OptionDataTemplate
extends StatTemplate {
    private final List<SkillEntry> _skills = new ArrayList<SkillEntry>(0);
    private final int _id;

    public OptionDataTemplate(int id) {
        this._id = id;
    }

    public void addSkill(SkillEntry skill) {
        this._skills.add(skill);
    }

    public List<SkillEntry> getSkills() {
        return this._skills;
    }

    public int getId() {
        return this._id;
    }
}

