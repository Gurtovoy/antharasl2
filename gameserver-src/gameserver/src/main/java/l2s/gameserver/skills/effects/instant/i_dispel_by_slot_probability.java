package l2s.gameserver.skills.effects.instant;

import java.util.ArrayList;
import java.util.Collections;
import l2s.commons.util.Rnd;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;
import l2s.gameserver.utils.AbnormalsComparator;

public class i_dispel_by_slot_probability
extends i_abstract_effect {
    private final AbnormalType _abnormalType = AbnormalType.valueOf(this.getParams().getString("abnormal_type", AbnormalType.NONE.toString()).toUpperCase());
    private final int _dispelChance = this._abnormalType == AbnormalType.NONE ? 0 : this.getParams().getInteger("dispel_chance", 100);

    public i_dispel_by_slot_probability(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return this._dispelChance != 0;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        ArrayList<Abnormal> abnormals = new ArrayList<Abnormal>(effected.getAbnormalList().values());
        Collections.sort(abnormals, AbnormalsComparator.getInstance());
        Collections.reverse(abnormals);
        for (Abnormal abnormal : abnormals) {
            Skill skill;
            if (!abnormal.isCancelable() || (skill = abnormal.getSkill()) == null || skill.isToggle() || skill.isPassive() || abnormal.getAbnormalType() != this._abnormalType || !Rnd.chance((int)this._dispelChance)) continue;
            abnormal.exit();
            if (abnormal.isHidden()) continue;
            effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(skill));
        }
    }
}

