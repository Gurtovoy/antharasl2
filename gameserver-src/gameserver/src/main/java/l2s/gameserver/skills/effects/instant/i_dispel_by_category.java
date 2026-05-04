/*
 * This file was originally decompiled from L2S rev.[31495].
 */
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
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.templates.skill.EffectTemplate;
import l2s.gameserver.utils.AbnormalsComparator;

public class i_dispel_by_category
extends i_abstract_effect {
    private final AbnormalCategory _abnormalCategory = (AbnormalCategory)this.getParams().getEnum("abnormal_category", AbnormalCategory.class);
    private final int _dispelChance = this.getParams().getInteger("dispel_chance", 100);
    private final int _maxCount = this.getParams().getInteger("max_count", 0);

    public i_dispel_by_category(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return this._dispelChance != 0 && this._maxCount != 0;
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        block4: {
            ArrayList<Abnormal> effects;
            block5: {
                effects = new ArrayList<Abnormal>(effected.getAbnormalList().values());
                Collections.sort(effects, AbnormalsComparator.getInstance());
                Collections.reverse(effects);
                if (this._abnormalCategory != AbnormalCategory.slot_debuff) break block5;
                int dispelled = 0;
                for (Abnormal abnormal : effects) {
                    Skill effectSkill;
                    if (!abnormal.isCancelable() || (effectSkill = abnormal.getSkill()) == null || !abnormal.isOffensive() || effectSkill.isToggle() || effectSkill.isPassive() || effected.isSpecialAbnormal(effectSkill) || effectSkill.getMagicLevel() <= 0 || !Rnd.chance((int)this._dispelChance)) continue;
                    abnormal.exit();
                    if (!abnormal.isHidden()) {
                        effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(effectSkill));
                    }
                    if (this._maxCount <= 0 || ++dispelled < this._maxCount) continue;
                    break block4;
                }
                break block4;
            }
            if (this._abnormalCategory != AbnormalCategory.slot_buff) break block4;
            int dispelled = 0;
            for (Abnormal abnormal : effects) {
                Skill effectSkill;
                if (!abnormal.isCancelable() || (effectSkill = abnormal.getSkill()) == null || abnormal.isOffensive() || effectSkill.isToggle() || effectSkill.isPassive() || effected.isSpecialAbnormal(effectSkill) || effectSkill.getMagicLevel() <= 0 || !Formulas.calcCancelSuccess(effector, effected, this._dispelChance, this.getSkill(), abnormal)) continue;
                abnormal.exit();
                if (!abnormal.isHidden()) {
                    effected.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.THE_EFFECT_OF_S1_HAS_BEEN_REMOVED).addSkillName(effectSkill));
                }
                if (this._maxCount <= 0 || ++dispelled < this._maxCount) continue;
                break;
            }
        }
    }

    private static enum AbnormalCategory {
        slot_buff,
        slot_debuff;

    }
}

