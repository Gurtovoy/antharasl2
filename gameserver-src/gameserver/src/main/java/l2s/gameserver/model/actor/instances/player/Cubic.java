/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.util.Rnd
 */
package l2s.gameserver.model.actor.instances.player;

import java.util.HashSet;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.util.Rnd;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.skills.SkillEntryType;
import l2s.gameserver.skills.TimeStamp;
import l2s.gameserver.templates.cubic.CubicSkillInfo;
import l2s.gameserver.templates.cubic.CubicTargetType;
import l2s.gameserver.templates.cubic.CubicTemplate;
import l2s.gameserver.utils.TimeUtils;

public class Cubic
implements Runnable {
    protected final Player _owner;
    protected final CubicTemplate _template;
    protected final Skill _skill;
    protected ScheduledFuture<?> _task;
    protected ScheduledFuture<?> _castTask;
    private int _delay;
    private int _lifeTime = 0;
    private int _count;
    private long _reuse = 0L;

    public Cubic(Player owner, CubicTemplate template, Skill skill) {
        this._owner = owner;
        this._template = template;
        this._skill = skill;
        this._delay = this._template.getDelay();
        this._count = this._template.getMaxCount();
    }

    public int getId() {
        return this._template.getId();
    }

    public int getSlot() {
        return this._template.getSlot();
    }

    public Player getOwner() {
        return this._owner;
    }

    public CubicTemplate getTemplate() {
        return this._template;
    }

    public Skill getSkill() {
        return this._skill;
    }

    public void init() {
        this._owner.addCubic(this);
        if (this._task == null) {
            this._task = ThreadPoolManager.getInstance().scheduleAtFixedRate(this, 1000L, 1000L);
        }
    }

    public void delete() {
        if (this._task != null) {
            this._task.cancel(true);
            this._task = null;
        }
        if (this._castTask != null) {
            this._castTask.cancel(true);
            this._castTask = null;
        }
        this._owner.removeCubic(this.getSlot());
    }

    @Override
    public void run() {
        ++this._lifeTime;
        if (this._template.getDuration() > 0 && this._lifeTime >= this._template.getDuration()) {
            this.delete();
            return;
        }
        if (this._castTask != null) {
            return;
        }
        CubicSkillInfo skill = this._template.getTimeSkill(this._lifeTime);
        if (skill != null && this.doCastSkill(skill)) {
            return;
        }
        if (this._reuse > System.currentTimeMillis()) {
            return;
        }
        boolean success = false;
        skill = this._template.getRandomSkill();
        if (skill != null) {
            success = this.doCastSkill(skill);
        }
        if (success) {
            --this._count;
        }
        if (this._count <= 0) {
            switch (this._template.getUseUp()) {
                case INCREASE_DELAY: {
                    this._count = this._template.getMaxCount();
                    this._delay *= 5;
                    break;
                }
                case DISPELL: {
                    this.delete();
                }
            }
        }
        if (success && this._delay > 0) {
            this._reuse = System.currentTimeMillis() + (long)this._delay * 1000L;
        }
    }

    private boolean doCastSkill(CubicSkillInfo skillInfo) {
        int chance;
        if (this.getOwner().isAlikeDead()) {
            return false;
        }
        if (this.getOwner().isAfraid()) {
            return false;
        }
        if (this.isSkillDisabled(skillInfo)) {
            return false;
        }
        CubicTargetType targetType = this.getTargetType(skillInfo);
        Creature target = targetType.getTarget(this, skillInfo);
        if (target == null) {
            return false;
        }
        switch (targetType) {
            case HEAL: {
                chance = skillInfo.getChance((int)target.getCurrentHpPercents());
                break;
            }
            case MANA_HEAL: {
                chance = skillInfo.getChance((int)target.getCurrentMpPercents());
                break;
            }
            default: {
                chance = skillInfo.getChance();
            }
        }
        if (chance < 100 && !Rnd.chance((int)chance)) {
            return false;
        }
        Skill skill = skillInfo.getSkill();
        if (!skill.isHandler() && skill.getItemConsumeId() > 0 && skill.getItemConsume() > 0L && !this._owner.consumeItem(skill.getItemConsumeId(), skill.getItemConsume(), false)) {
            return false;
        }
        this.disableSkill(skillInfo);
        Creature aimTarget = target;
        HashSet<Creature> targets = new HashSet<Creature>(1);
        targets.add(aimTarget);
        int hitTime = Math.max(this.isAgathion() ? 0 : 2000, skill.getHitTime());
        if (!skill.isNotBroadcastable()) {
            this._owner.broadcastPacket(new MagicSkillUse(this._owner, target, skill.getDisplayId(), skill.getDisplayLevel(), hitTime, 0L));
        }
        this._castTask = ThreadPoolManager.getInstance().schedule(() -> {
            this._owner.callSkill(aimTarget, SkillEntry.makeSkillEntry(SkillEntryType.CUBIC, skill), targets, false, false);
            if (skill.isDebuff() && aimTarget.isNpc()) {
                if (aimTarget.paralizeOnAttack(this._owner)) {
                    if (Config.PARALIZE_ON_RAID_DIFF) {
                        this._owner.paralizeMe(aimTarget);
                    }
                } else if (skill.getEffectPoint() < 0) {
                    aimTarget.getAI().notifyEvent(CtrlEvent.EVT_ATTACKED, this._owner, skill, skill.getEffectPoint());
                }
            }
            this._castTask = null;
        }, hitTime);
        return true;
    }

    private CubicTargetType getTargetType(CubicSkillInfo info) {
        switch (this._template.getTargetType()) {
            case BY_SKILL: {
                return info.getTargetType();
            }
        }
        return this._template.getTargetType();
    }

    public boolean canCastSkill(Creature target, Skill skill, boolean party) {
        if (this._owner == target) {
            return true;
        }
        if (skill.getCastRange() == -2) {
            return true;
        }
        if (!GeoEngine.canSeeTarget(this._owner, target)) {
            return false;
        }
        if (skill.getCastRange() == -1) {
            return this._owner.isInRangeZ(target, party ? Config.ALT_PARTY_DISTRIBUTION_RANGE : 1500);
        }
        int range = Math.max(10, skill.getCastRange()) + (int)this._owner.getMinDistance(target);
        return this._owner.isInRangeZ(target, range += 40);
    }

    public boolean isSkillDisabled(CubicSkillInfo info) {
        switch (info.getReuseType()) {
            case DEFAULT: {
                return this._owner.isSkillDisabled(info.getSkill());
            }
            case DAILY: {
                return this._owner.isSharedGroupDisabled(info.getSkill().getReuseHash());
            }
        }
        return false;
    }

    public void disableSkill(CubicSkillInfo info) {
        switch (info.getReuseType()) {
            case DEFAULT: {
                int reuse = info.getSkill().getReuseDelay();
                if (reuse <= 0) break;
                this._owner.disableSkill(info.getSkill(), info.getSkill().getReuseDelay());
                break;
            }
            case DAILY: {
                this._owner.addSharedGroupReuse(info.getSkill().getReuseHash(), new TimeStamp(info.getSkill().getReuseHash(), TimeUtils.DAILY_DATE_PATTERN.next(System.currentTimeMillis()), 0L));
            }
        }
    }

    public boolean isCubic() {
        return true;
    }

    public boolean isAgathion() {
        return false;
    }
}

