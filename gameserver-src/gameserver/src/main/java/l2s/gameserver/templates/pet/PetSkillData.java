/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.templates.pet;

import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Skill;

public class PetSkillData {
    private final int _id;
    private final int _level;
    private final int _petMinLevel;

    public PetSkillData(int id, int level, int petMinLevel) {
        this._id = id;
        this._level = level;
        this._petMinLevel = petMinLevel;
    }

    public int getId() {
        return this._id;
    }

    public int getLevel(int petLevel) {
        if (this._level <= 0) {
            Skill skill;
            int level = 0;
            if (petLevel < 70) {
                level = petLevel / 10;
                if (level <= 0) {
                    level = 1;
                }
            } else {
                level = 7 + (petLevel - 70) / 5;
            }
            if ((skill = SkillHolder.getInstance().getSkill(this.getId(), 1)) == null) {
                return 0;
            }
            return Math.min(level, skill.getMaxLevel());
        }
        return this._level;
    }

    public int getLevel() {
        return this._level;
    }

    public int getPetMinLevel() {
        return this._petMinLevel;
    }
}

