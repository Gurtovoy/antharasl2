package l2s.gameserver.skills.effects.permanent;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.stats.StatModifierType;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.stats.funcs.FuncTemplate;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.skill.EffectTemplate;

public abstract class p_abstract_stat_effect
extends EffectHandler {
    private final StatModifierType _modifierType = (StatModifierType)this.getParams().getEnum("type", StatModifierType.class, StatModifierType.DIFF);

    public p_abstract_stat_effect(EffectTemplate template, Stats stat) {
        super(template);
        StatsSet params = new StatsSet();
        params.set("stat", stat);
        params.set("function", "New");
        params.set("mode", this._modifierType);
        params.set("condition", template.getCondition());
        params.set("value", this.getValue());
        template.attachFunc(FuncTemplate.makeTemplate(params));
    }

    protected final StatModifierType getModifierType() {
        return this._modifierType;
    }

    @Override
    public final Condition getCondition() {
        return null;
    }
}

