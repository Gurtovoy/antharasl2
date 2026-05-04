package l2s.gameserver.stats.triggers;

import l2s.commons.lang.ArrayUtils;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.stats.triggers.TriggerType;

public class TriggerInfo
extends Skill.AddedSkill {
    private final TriggerType _type;
    private final double _chance;
    private final boolean _increasing;
    private final int _delay;
    private final boolean _cancelEffectsOnRemove;
    private final String _args;
    private Condition[] _conditions = Condition.EMPTY_ARRAY;

    public TriggerInfo(int id, int level, TriggerType type, double chance, boolean increasing, int delay, boolean cancel, String args) {
        super(SkillEntryType.TRIGGER, id, level);
        this._type = type;
        this._chance = chance;
        this._increasing = increasing;
        this._delay = delay;
        this._cancelEffectsOnRemove = cancel;
        this._args = args;
    }

    public final void addCondition(Condition c) {
        this._conditions = (Condition[])ArrayUtils.add((Object[])this._conditions, (Object)c);
    }

    public boolean checkCondition(Creature actor, Creature target, Creature aimTarget, Skill owner, double damage) {
        SkillEntry skillEntry = this.getSkill();
        if (skillEntry == null) {
            return false;
        }
        if (skillEntry.checkTarget(actor, aimTarget, aimTarget, false, false, true) != null) {
            return false;
        }
        Env env = new Env();
        env.character = actor;
        env.skill = owner;
        env.target = target;
        env.value = damage;
        for (Condition c : this._conditions) {
            if (c.test(env)) continue;
            return false;
        }
        return true;
    }

    public TriggerType getType() {
        return this._type;
    }

    public double getChance() {
        return this._chance;
    }

    public boolean isIncreasing() {
        return this._increasing;
    }

    public int getDelay() {
        return this._delay;
    }

    public boolean cancelEffectsOnRemove() {
        return this._cancelEffectsOnRemove;
    }

    public String getArgs() {
        return this._args;
    }
}

