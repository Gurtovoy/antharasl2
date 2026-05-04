/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectAddSkills
extends EffectHandler {
    public EffectAddSkills(EffectTemplate template) {
        super(template);
    }

    @Override
    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
        for (Skill.AddedSkill as : this.getSkill().getAddedSkills()) {
            SkillEntry skillEntry = as.getSkill();
            if (skillEntry == null) continue;
            effected.addSkill(skillEntry);
        }
    }

    @Override
    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
        for (Skill.AddedSkill as : this.getSkill().getAddedSkills()) {
            SkillEntry skillEntry = as.getSkill();
            if (skillEntry == null) continue;
            effected.removeSkill(skillEntry);
        }
    }
}

