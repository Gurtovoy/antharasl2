/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class i_set_skill
extends i_abstract_effect {
    private final SkillEntry _skill;

    public i_set_skill(EffectTemplate template) {
        super(template);
        int[] skill = this.getParams().getIntegerArray("skill", "-");
        this._skill = SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill[0], skill.length >= 2 ? skill[1] : 1);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return this._skill != null;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        Player player = effected.getPlayer();
        player.addSkill(this._skill, true);
        player.updateStats();
        player.sendSkillList();
        player.updateSkillShortcuts(this._skill.getId(), this._skill.getLevel());
    }
}

