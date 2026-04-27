/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills.effects.instant;

import java.util.ArrayList;
import java.util.Collections;
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

public class i_dispel_by_slot
extends i_abstract_effect {
    private final AbnormalType _abnormalType = AbnormalType.valueOf(this.getParams().getString("abnormal_type", AbnormalType.NONE.toString()).toUpperCase());
    private final int _maxAbnormalLvl = this._abnormalType == AbnormalType.NONE ? 0 : this.getParams().getInteger("max_abnormal_level", 0);

    public i_dispel_by_slot(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return this._maxAbnormalLvl != 0;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        Creature target = this.isSelf() ? effector : effected;
        ArrayList<Abnormal> abnormals = new ArrayList<Abnormal>(target.getAbnormalList().values());
        Collections.sort(abnormals, AbnormalsComparator.getInstance());
        Collections.reverse(abnormals);
        for (Abnormal abnormal : abnormals) {
            Skill effectSkill = abnormal.getSkill();
            if (effectSkill == null || effectSkill.isToggle() || effectSkill.isPassive() || target.isSpecialAbnormal(effectSkill) || abnormal.getAbnormalType() != this._abnormalType || this._maxAbnormalLvl != -1 && abnormal.getAbnormalLvl() > this._maxAbnormalLvl) continue;
            abnormal.exit();
            if (abnormal.isHidden()) continue;
            target.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(effectSkill));
        }
    }

    protected boolean isSelf() {
        return false;
    }
}

