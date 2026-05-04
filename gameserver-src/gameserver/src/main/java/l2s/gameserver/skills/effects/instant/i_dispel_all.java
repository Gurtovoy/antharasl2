package l2s.gameserver.skills.effects.instant;

import java.util.ArrayList;
import java.util.Collections;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;
import l2s.gameserver.utils.AbnormalsComparator;

public class i_dispel_all
extends i_abstract_effect {
    public i_dispel_all(EffectTemplate template) {
        super(template);
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        ArrayList<Abnormal> abnormals = new ArrayList<Abnormal>(effected.getAbnormalList().values());
        Collections.sort(abnormals, AbnormalsComparator.getInstance());
        Collections.reverse(abnormals);
        for (Abnormal abnormal : abnormals) {
            Skill effectSkill;
            if (!abnormal.isCancelable() || (effectSkill = abnormal.getSkill()) == null || effectSkill.isToggle() || effectSkill.isPassive() || effected.isSpecialAbnormal(effectSkill)) continue;
            abnormal.exit();
            if (abnormal.isHidden()) continue;
            effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(effectSkill));
        }
    }
}

