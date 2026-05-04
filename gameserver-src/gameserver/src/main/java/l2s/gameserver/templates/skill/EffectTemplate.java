package l2s.gameserver.templates.skill;

import l2s.gameserver.handler.effects.EffectHandler;
import l2s.gameserver.handler.effects.EffectHandlerHolder;
import l2s.gameserver.model.Skill;
import l2s.gameserver.skills.EffectTargetType;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.stats.StatTemplate;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.templates.StatsSet;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class EffectTemplate
extends StatTemplate {
    public static final EffectTemplate[] EMPTY_ARRAY = new EffectTemplate[0];
    private static final Logger _log = LoggerFactory.getLogger(EffectTemplate.class);
    private final Skill _skill;
    private final StatsSet _paramSet;
    private final String _name;
    private final EffectUseType _useType;
    private final EffectTargetType _targetType;
    private final double _value;
    private final int _interval;
    private final int _chance;
    private EffectHandler _handler = null;
    private Condition _attachCond = null;

    public EffectTemplate(Skill skill, StatsSet set, EffectUseType useType, EffectTargetType targetType) {
        this._skill = skill;
        this._paramSet = set;
        this._name = set.getString("name", "");
        boolean instant = this.getParams().getBool("instant", this._name.startsWith("i_"));
        if (instant) {
            switch (useType) {
                case SELF: {
                    useType = EffectUseType.SELF_INSTANT;
                    break;
                }
                case NORMAL: {
                    useType = EffectUseType.NORMAL_INSTANT;
                }
            }
        }
        this._useType = useType;
        this._targetType = targetType;
        this._value = set.getDouble("value", 0.0);
        this._interval = set.getInteger("interval", Integer.MAX_VALUE);
        this._chance = set.getInteger("chance", -1);
    }

    public Skill getSkill() {
        return this._skill;
    }

    public StatsSet getParams() {
        return this._paramSet;
    }

    public String getName() {
        return this._name;
    }

    public EffectHandler getHandler() {
        if (this._handler == null) {
            this._handler = EffectHandlerHolder.getInstance().makeHandler(this._name, this);
        }
        return this._handler;
    }

    public boolean isInstant() {
        return this._useType.isInstant();
    }

    public EffectUseType getUseType() {
        return this._useType;
    }

    public EffectTargetType getTargetType() {
        return this._targetType;
    }

    public double getValue() {
        return this._value;
    }

    public int getInterval() {
        return this._interval;
    }

    public int getChance() {
        return this._chance;
    }

    public void attachCond(Condition c) {
        this._attachCond = c;
    }

    public Condition getCondition() {
        return this._attachCond;
    }
}

