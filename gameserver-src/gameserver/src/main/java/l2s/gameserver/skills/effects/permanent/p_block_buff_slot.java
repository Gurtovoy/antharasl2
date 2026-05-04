package l2s.gameserver.skills.effects.permanent;

import gnu.trove.set.TIntSet;
import gnu.trove.set.hash.TIntHashSet;
import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.templates.skill.EffectTemplate;

public class p_block_buff_slot
extends EffectHandler {
    private final TIntSet _blockedAbnormalTypes = new TIntHashSet();

    public p_block_buff_slot(EffectTemplate template) {
        super(template);
        String[] types;
        for (String type : types = this.getParams().getString("abnormal_types", "").split(";")) {
            this._blockedAbnormalTypes.add(AbnormalType.valueOf(type.toUpperCase()).ordinal());
        }
    }

    @Override
    public boolean checkBlockedAbnormalType(Abnormal abnormal, Creature effector, Creature effected, AbnormalType abnormalType) {
        if (this._blockedAbnormalTypes.isEmpty()) {
            return false;
        }
        return this._blockedAbnormalTypes.contains(abnormalType.ordinal());
    }
}

