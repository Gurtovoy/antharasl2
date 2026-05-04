package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_spirit_shot
extends i_abstract_effect {
    private final double _power = this.getParams().getDouble("power", 100.0);
    private final int _unk = this.getParams().getInteger("unk_spiritshot_parameter", 40);
    private final double _healBonus = this.getParams().getDouble("heal_bonus", 1.0);

    public i_spirit_shot(EffectTemplate template) {
        super(template);
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        effected.sendPacket((IBroadcastPacket)SystemMsg.YOUR_SPIRITSHOT_HAS_BEEN_ENABLED);
        effected.setChargedSpiritshotPower(this._power, this._unk, this._healBonus);
    }
}

