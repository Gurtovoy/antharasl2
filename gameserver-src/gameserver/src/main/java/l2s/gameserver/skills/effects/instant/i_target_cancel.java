/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.DefaultAI;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public final class i_target_cancel
extends i_abstract_effect {
    private final boolean _stopTarget = this.getParams().getBool("stop_target", false);

    public i_target_cancel(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return !effected.isRaid();
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        if (effected.getAI() instanceof DefaultAI) {
            ((DefaultAI)effected.getAI()).setGlobalAggro(System.currentTimeMillis() + 3000L);
        }
        effected.setTarget(null);
        if (this._stopTarget) {
            effected.getMovement().stopMove();
        }
        effected.abortAttack(true, true);
        SkillEntry castingSkillEntry = effected.getSkillCast(SkillCastingType.NORMAL).getSkillEntry();
        if (castingSkillEntry == null || castingSkillEntry.getSkillType() != Skill.SkillType.TAKECASTLE) {
            effected.abortCast(true, true, true, false);
        }
        if ((castingSkillEntry = effected.getSkillCast(SkillCastingType.NORMAL_SECOND).getSkillEntry()) == null || castingSkillEntry.getSkillType() != Skill.SkillType.TAKECASTLE) {
            effected.abortCast(true, true, false, true);
        }
        effected.getAI().setIntention(CtrlIntention.AI_INTENTION_ACTIVE, effector);
    }
}

