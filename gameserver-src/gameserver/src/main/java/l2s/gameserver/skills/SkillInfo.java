/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills;

import l2s.gameserver.model.Skill;

public interface SkillInfo {
    public int getId();

    public int getDisplayId();

    public int getLevel();

    public int getDisplayLevel();

    public Skill getTemplate();
}

