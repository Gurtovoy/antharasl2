/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.agathion;

import java.util.ArrayList;
import java.util.List;
import l2s.gameserver.skills.SkillEntry;

public class AgathionEnchantData {
    private final int level;
    private final List<SkillEntry> mainSkills = new ArrayList<SkillEntry>();
    private final List<SkillEntry> subSkills = new ArrayList<SkillEntry>();

    public AgathionEnchantData(int level) {
        this.level = level;
    }

    public int getLevel() {
        return this.level;
    }

    public List<SkillEntry> getMainSkills() {
        return this.mainSkills;
    }

    public List<SkillEntry> getSubSkills() {
        return this.subSkills;
    }
}

