package l2s.gameserver.skills.effects.instant;

import java.util.Set;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_call_skill
extends i_abstract_effect {
    private final SkillEntry _skillEntry;
    private final int _maxIncreaseLevel;

    public i_call_skill(EffectTemplate template) {
        super(template);
        int[] skill = this.getParams().getIntegerArray("skill", "-");
        this._skillEntry = SkillEntry.makeSkillEntry(SkillEntryType.NONE, skill[0], skill.length >= 2 ? skill[1] : 1);
        this._maxIncreaseLevel = this.getParams().getInteger("max_increase_level", 0);
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        if (this._skillEntry == null) {
            return;
        }
        SkillEntry tempSkillEntry = this._skillEntry;
        Skill skill = tempSkillEntry.getTemplate();
        Creature aimTarget = skill.getAimingTarget(effector, effected);
        if (aimTarget != null && this._maxIncreaseLevel > 0) {
            Skill hasSkill = null;
            for (Abnormal effect : aimTarget.getAbnormalList()) {
                if (effect.getSkill().getId() != skill.getId()) continue;
                hasSkill = effect.getSkill();
                break;
            }
            if (hasSkill == null) {
                block1: for (Servitor servitor : aimTarget.getServitors()) {
                    for (Abnormal effect : servitor.getAbnormalList()) {
                        if (effect.getSkill().getId() != skill.getId()) continue;
                        hasSkill = effect.getSkill();
                        break block1;
                    }
                }
            }
            if (hasSkill != null) {
                Skill newSkill = SkillHolder.getInstance().getSkill(skill.getId(), Math.min(this._maxIncreaseLevel, hasSkill.getLevel() + 1));
                skill = newSkill != null ? newSkill : hasSkill;
                tempSkillEntry = SkillEntry.makeSkillEntry(this._skillEntry.getEntryType(), skill);
            }
        }
        if (skill.getReuseDelay() > 0 && effector.isSkillDisabled(skill)) {
            return;
        }
        if (tempSkillEntry.checkCondition(effector, aimTarget, true, true, true, false, true)) {
            Set<Creature> targets = skill.getTargets(tempSkillEntry, effector, aimTarget, false);
            if (!skill.isNotBroadcastable() && !effector.isCastingNow()) {
                for (Creature cha : targets) {
                    if (cha == null) continue;
                    effector.broadcastPacket(new MagicSkillUse(effector, cha, skill.getDisplayId(), skill.getDisplayLevel(), 0, 0L));
                }
            }
            effector.callSkill(aimTarget, tempSkillEntry, targets, false, true);
            effector.disableSkill(skill, skill.getReuseDelay());
        }
    }
}

