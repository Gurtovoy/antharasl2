package l2s.gameserver.skills.effects.instant;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.skills.effects.instant.i_abstract_effect;
import l2s.gameserver.templates.skill.EffectTemplate;

public class i_get_exp
extends i_abstract_effect {
    private final long _power = this.getParams().getLong("power");
    private final int _percentPower = this.getParams().getInteger("percent_power", 0);
    private final int _percentPowerMaxLvl = this.getParams().getInteger("percent_power_max_lvl", 0);

    public i_get_exp(EffectTemplate template) {
        super(template);
    }

    @Override
    protected boolean checkCondition(Creature effector, Creature effected) {
        return effected.isPlayer();
    }

    @Override
    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        Player player = effected.getPlayer();
        long power = this._power;
        if (this._percentPowerMaxLvl != 0 && player.getLevel() < this._percentPowerMaxLvl) {
            power = (long)((double)player.getExp() / 100.0 * (double)this._percentPower);
        }
        player.addExpAndSp(power, 0L);
    }
}

