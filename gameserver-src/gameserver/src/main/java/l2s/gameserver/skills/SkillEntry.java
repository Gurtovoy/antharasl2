/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.skills;

import java.util.Set;
import l2s.gameserver.data.xml.holder.SkillHolder;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.skills.SkillInfo;
import l2s.gameserver.stats.funcs.Func;

public class SkillEntry
implements SkillInfo {
    public static final SkillEntry[] EMPTY_ARRAY = new SkillEntry[0];
    private final SkillEntryType _entryType;
    private final Skill _skill;
    private boolean _disabled;

    protected SkillEntry(SkillEntryType key, Skill value) {
        this._entryType = key;
        this._skill = value;
    }

    public boolean isDisabled() {
        return this._disabled;
    }

    public void setDisabled(boolean disabled) {
        this._disabled = disabled;
    }

    public SkillEntryType getEntryType() {
        return this._entryType;
    }

    @Override
    public Skill getTemplate() {
        return this._skill;
    }

    @Override
    public int getId() {
        return this._skill.getId();
    }

    @Override
    public int getDisplayId() {
        return this._skill.getDisplayId();
    }

    @Override
    public int getLevel() {
        return this._skill.getLevel();
    }

    @Override
    public int getDisplayLevel() {
        return this._skill.getDisplayLevel();
    }

    public Skill.SkillType getSkillType() {
        return this._skill.getSkillType();
    }

    public String getName() {
        return this._skill.getName();
    }

    public String getName(Player player) {
        return this._skill.getName(player);
    }

    public final boolean checkCondition(Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first) {
        return this._skill.checkCondition(this, activeChar, target, forceUse, dontMove, first);
    }

    public final boolean checkCondition(Creature activeChar, Creature target, boolean forceUse, boolean dontMove, boolean first, boolean sendMsg, boolean trigger) {
        return this._skill.checkCondition(this, activeChar, target, forceUse, dontMove, first, sendMsg, trigger);
    }

    public final SystemMsg checkTarget(Creature activeChar, Creature target, Creature aimingTarget, boolean forceUse, boolean first) {
        return this._skill.checkTarget(this, activeChar, target, aimingTarget, forceUse, first);
    }

    public final SystemMsg checkTarget(Creature activeChar, Creature target, Creature aimingTarget, boolean forceUse, boolean first, boolean trigger) {
        return this._skill.checkTarget(this, activeChar, target, aimingTarget, forceUse, first, trigger);
    }

    public final boolean getEffects(Creature effector, Creature effected) {
        return this._skill.getEffects(effector, effected);
    }

    public final boolean getEffects(Creature effector, Creature effected, int timeConst, double timeMult) {
        return this._skill.getEffects(effector, effected, timeConst, timeMult);
    }

    public final void onEndCast(Creature activeChar, Set<Creature> targets) {
        this._skill.onEndCast(activeChar, targets);
    }

    public boolean isAltUse() {
        return this._skill.isAltUse(this.getEntryType());
    }

    public SkillEntry copyTo(SkillEntryType entryType) {
        return SkillEntry.makeSkillEntry(entryType, this._skill);
    }

    public Func[] getStatFuncs() {
        return this._skill.getStatFuncs();
    }

    public Skill getLockedSkill() {
        return null;
    }

    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (this.getClass() != obj.getClass()) {
            return false;
        }
        return this.hashCode() == obj.hashCode();
    }

    public int hashCode() {
        return this._skill.hashCode();
    }

    public String toString() {
        return this._skill.toString();
    }

    public static SkillEntry makeSkillEntry(SkillEntryType entryType, Skill skill) {
        if (skill == null) {
            return null;
        }
        return new SkillEntry(entryType, skill);
    }

    public static SkillEntry makeSkillEntry(SkillEntryType entryType, int skillId, int skillLevel) {
        return SkillEntry.makeSkillEntry(entryType, SkillHolder.getInstance().getSkill(skillId, skillLevel));
    }
}

