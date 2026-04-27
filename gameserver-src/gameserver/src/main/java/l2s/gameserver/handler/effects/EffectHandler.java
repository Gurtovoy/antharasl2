/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.handler.effects;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.skills.AbnormalType;
import l2s.gameserver.stats.Env;
import l2s.gameserver.stats.conditions.Condition;
import l2s.gameserver.stats.funcs.Func;
import l2s.gameserver.stats.funcs.FuncOwner;
import l2s.gameserver.templates.StatsSet;
import l2s.gameserver.templates.skill.EffectTemplate;

public class EffectHandler
implements FuncOwner {
    private final String _name = EffectHandler.getName(this.getClass());
    private final EffectTemplate _template;

    public static String getName(Class<? extends EffectHandler> cls) {
        return cls.getSimpleName().replaceAll("^(Effect)?(.*?)(EffectHandler)?$", "$2").toLowerCase();
    }

    public EffectHandler(EffectTemplate template) {
        this._template = template;
    }

    @Override
    public final boolean isFuncEnabled() {
        return true;
    }

    @Override
    public final boolean overrideLimits() {
        return false;
    }

    public final String getName() {
        return this._name;
    }

    public final EffectTemplate getTemplate() {
        return this._template;
    }

    public final Skill getSkill() {
        return this._template.getSkill();
    }

    public final StatsSet getParams() {
        return this._template.getParams();
    }

    public final double getValue() {
        return this._template.getValue();
    }

    public int getInterval() {
        return this._template.getInterval();
    }

    public Func[] getStatFuncs() {
        return this._template.getStatFuncs(this);
    }

    public Condition getCondition() {
        return this._template.getCondition();
    }

    public boolean checkBlockedAbnormalType(Abnormal abnormal, Creature effector, Creature effected, AbnormalType abnormalType) {
        return false;
    }

    public boolean checkDebuffImmunity(Abnormal abnormal, Creature effector, Creature effected) {
        return false;
    }

    public boolean isHidden() {
        return false;
    }

    public boolean isSaveable() {
        return true;
    }

    private final boolean testCondition(Creature effector, Creature effected) {
        Condition cond = this.getCondition();
        return cond == null || cond.test(new Env(effector, effected, this.getSkill()));
    }

    public final boolean checkConditionImpl(Abnormal abnormal, Creature effector, Creature effected) {
        if (!this.checkCondition(abnormal, effector, effected)) {
            return false;
        }
        return this.testCondition(effector, effected);
    }

    protected boolean checkCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return true;
    }

    public final boolean checkActingConditionImpl(Abnormal abnormal, Creature effector, Creature effected) {
        if (!this.checkActingCondition(abnormal, effector, effected)) {
            return false;
        }
        return this.testCondition(effector, effected);
    }

    protected boolean checkActingCondition(Abnormal abnormal, Creature effector, Creature effected) {
        return true;
    }

    public void onStart(Abnormal abnormal, Creature effector, Creature effected) {
    }

    public void onApplied(Abnormal abnormal, Creature effector, Creature effected) {
    }

    public boolean onActionTime(Abnormal abnormal, Creature effector, Creature effected) {
        return true;
    }

    public void onExit(Abnormal abnormal, Creature effector, Creature effected) {
    }

    public final boolean checkConditionImpl(Creature effector, Creature effected) {
        if (!this.checkCondition(effector, effected)) {
            return false;
        }
        return this.testCondition(effector, effected);
    }

    protected boolean checkCondition(Creature effector, Creature effected) {
        return this.checkCondition(null, effector, effected);
    }

    public void instantUse(Creature effector, Creature effected, boolean reflected) {
        this.onStart(null, effector, effected);
        this.onActionTime(null, effector, effected);
        this.onExit(null, effector, effected);
    }

    public EffectHandler getImpl() {
        return this;
    }
}

