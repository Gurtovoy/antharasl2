package l2s.gameserver.model.actor;

import java.util.Set;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.actor.instances.creature.Abnormal;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.FlyToLocationPacket;
import l2s.gameserver.network.l2.s2c.MagicSkillCanceled;
import l2s.gameserver.network.l2.s2c.MagicSkillLaunchedPacket;
import l2s.gameserver.network.l2.s2c.MagicSkillUse;
import l2s.gameserver.network.l2.s2c.MoveToPawnPacket;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.stats.Formulas;
import l2s.gameserver.stats.Stats;
import l2s.gameserver.stats.triggers.TriggerType;
import l2s.gameserver.utils.ItemFunctions;
import l2s.gameserver.utils.PositionUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CreatureSkillCast {
    private static final Logger _log = LoggerFactory.getLogger(CreatureSkillCast.class);
    private final Creature _actor;
    private final SkillCastingType _castingType;
    private final AtomicBoolean _isCastingNow = new AtomicBoolean(false);
    private HardReference<? extends Creature> _target = HardReferences.emptyRef();
    private Set<Creature> _targets = null;
    private boolean _forceUse = false;
    private SkillEntry _skillEntry = null;
    private long _animationEndTime;
    private int _castLeftTime;
    private boolean _isCriticalBlow = false;
    private Future<?> _skillTask = null;
    private Future<?> _skillTickTask = null;
    private Location _flyLoc = null;

    public CreatureSkillCast(Creature actor, SkillCastingType castingType) {
        this._actor = actor;
        this._castingType = castingType;
    }

    public Creature getActor() {
        return this._actor;
    }

    public SkillCastingType getCastingType() {
        return this._castingType;
    }

    public boolean isDual() {
        return this._castingType == SkillCastingType.NORMAL_SECOND;
    }

    public boolean isCastingNow() {
        return this._isCastingNow.get();
    }

    public Creature getTarget() {
        return this._target == null ? null : (Creature)this._target.get();
    }

    public Set<Creature> getTargets() {
        return this._targets;
    }

    public SkillEntry getSkillEntry() {
        return this._skillEntry;
    }

    public long getAnimationEndTime() {
        return this._animationEndTime;
    }

    public int getCastLeftTime() {
        return this._castLeftTime;
    }

    public boolean isCriticalBlow() {
        return this._isCriticalBlow;
    }

    public boolean doCast(SkillEntry skillEntry, Creature target, boolean forceUse) {
        if (!this._isCastingNow.compareAndSet(false, true)) {
            return false;
        }
        if (!this.doCast0(skillEntry, target, forceUse)) {
            this.clearVars();
            return false;
        }
        return true;
    }

    private boolean doCast0(SkillEntry skillEntry, Creature target, boolean forceUse) {
        int hitCancelTime;
        if (skillEntry == null) {
            return false;
        }
        Skill skill = skillEntry.getTemplate();
        if (!(!this.isDual() || this._actor.isDualCastEnable() && skill.isDouble())) {
            return false;
        }
        Creature aimingTarget = target != null ? target : skill.getAimingTarget(this._actor, this.getTarget());
        if (aimingTarget == null) {
            return false;
        }
        this._skillEntry = skillEntry;
        this._target = aimingTarget.getRef();
        this._forceUse = forceUse;
        if (skill.getReferenceItemId() > 0 && !this._actor.consumeItemMp(skill.getReferenceItemId(), skill.getReferenceItemMpConsume())) {
            return false;
        }
        double mpConsume1 = skill.getMpConsume1();
        if (mpConsume1 > 0.0 && this._actor.getCurrentMp() < mpConsume1) {
            this._actor.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_MP);
            return false;
        }
        if (!skill.isHandler() && this._actor.isPlayable() && skill.getItemConsumeId() > 0 && skill.getItemConsume() > 0L) {
            if (skill.isItemConsumeFromMaster()) {
                Player master = this._actor.getPlayer();
                if (master == null) {
                    return false;
                }
                if (ItemFunctions.getItemCount(master, skill.getItemConsumeId()) < skill.getItemConsume()) {
                    master.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NOT_ENOUGH_NECESSARY_ITEMS_TO_USE_THE_SKILL);
                    return false;
                }
            } else if (ItemFunctions.getItemCount((Playable)this._actor, skill.getItemConsumeId()) < skill.getItemConsume()) {
                this._actor.sendPacket((IBroadcastPacket)SystemMsg.THERE_ARE_NOT_ENOUGH_NECESSARY_ITEMS_TO_USE_THE_SKILL);
                return false;
            }
        }
        this._actor.getListeners().onMagicUse(skill, aimingTarget, false);
        Location groundLoc = null;
        if (skill.getTargetType() == Skill.SkillTargetType.TARGET_GROUND) {
            if (this._actor.isPlayer() && (groundLoc = this._actor.getPlayer().getGroundSkillLoc()) != null) {
                this._actor.setHeading(PositionUtils.calculateHeadingFrom(this._actor.getX(), this._actor.getY(), groundLoc.getX(), groundLoc.getY()), true);
            }
        } else if (this._actor != aimingTarget) {
            this._actor.setHeading(PositionUtils.calculateHeadingFrom(this._actor, aimingTarget), true);
            this._actor.sendPacket((IBroadcastPacket)new MoveToPawnPacket(this._actor, aimingTarget, this._actor.getDistance(aimingTarget)));
        }
        int hitTime = skill.isSkillTimePermanent() ? skill.getHitTime() : Formulas.calcSkillCastSpd(this._actor, skill, skill.getHitTime());
        int n = hitCancelTime = skill.isSkillTimePermanent() ? skill.getHitCancelTime() : Formulas.calcSkillCastSpd(this._actor, skill, skill.getHitCancelTime());
        if (skill.isMagic() && !skill.isSkillTimePermanent() && this._actor.getChargedSpiritshotPower() > 0.0) {
            hitTime = (int)(0.7 * (double)hitTime);
            hitCancelTime = (int)(0.7 * (double)hitCancelTime);
        }
        if (!skill.isSkillTimePermanent()) {
            if (skill.isMagic()) {
                int minCastTimeMagical = Math.min(Config.SKILLS_CAST_TIME_MIN_MAGICAL, skill.getHitTime());
                if (hitTime < minCastTimeMagical) {
                    hitTime = minCastTimeMagical;
                    hitCancelTime = 0;
                }
            } else {
                int minCastTimePhysical = Math.min(Config.SKILLS_CAST_TIME_MIN_PHYSICAL, skill.getHitTime());
                if (hitTime < minCastTimePhysical) {
                    hitTime = minCastTimePhysical;
                    hitCancelTime = 0;
                }
            }
        }
        this._animationEndTime = System.currentTimeMillis() + (long)hitTime;
        boolean criticalBlow = skill.calcCriticalBlow(this._actor, aimingTarget);
        long reuseDelay = Math.max(0L, Formulas.calcSkillReuseDelay(this._actor, skill));
        if (reuseDelay > 10L) {
            this._actor.disableSkill(skill, reuseDelay);
        }
        if (!skill.isNotBroadcastable()) {
            Servitor.UsedSkill servitorUsedSkill;
            MagicSkillUse msu = new MagicSkillUse(this._actor, aimingTarget, skill.getDisplayId(), skill.getDisplayLevel(), hitTime, reuseDelay, this._castingType);
            msu.setReuseSkillId(skill.getReuseSkillId());
            msu.setGroundLoc(groundLoc);
            msu.setCriticalBlow(criticalBlow);
            if (this._actor.isServitor() && (servitorUsedSkill = ((Servitor)this._actor).getUsedSkill()) != null && servitorUsedSkill.getSkill() == skill) {
                msu.setServitorSkillInfo(servitorUsedSkill.getActionId());
                ((Servitor)this._actor).setUsedSkill(null);
            }
            this._actor.broadcastPacket(msu);
        }
        if (skill.getTargetType() == Skill.SkillTargetType.TARGET_HOLY) {
            aimingTarget.getAI().notifyEvent(CtrlEvent.EVT_AGGRESSION, this._actor, 1);
        }
        if (this._actor.isPlayer()) {
            if (skill.getSkillType() == Skill.SkillType.PET_SUMMON) {
                this._actor.sendPacket((IBroadcastPacket)SystemMsg.SUMMONING_YOUR_PET);
            } else {
                this._actor.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_USE_S1).addSkillName(skill));
            }
        }
        if (mpConsume1 > 0.0) {
            if (skill.isMagic()) {
                mpConsume1 = this._actor.getStat().calc(Stats.MP_MAGIC_SKILL_CONSUME, mpConsume1, aimingTarget, skill);
            }
            this._actor.reduceCurrentMp(mpConsume1, null);
        }
        if (!skill.isHandler() && this._actor.isPlayable() && skill.getItemConsumeId() > 0 && skill.getItemConsume() > 0L) {
            if (skill.isItemConsumeFromMaster()) {
                Player master = this._actor.getPlayer();
                if (master != null) {
                    master.consumeItem(skill.getItemConsumeId(), skill.getItemConsume(), true);
                }
            } else {
                this._actor.consumeItem(skill.getItemConsumeId(), skill.getItemConsume(), true);
            }
        }
        Location flyLoc = null;
        switch (skill.getFlyType()) {
            case CHARGE: {
                flyLoc = this._actor.getFlyLocation(aimingTarget, skill);
                if (flyLoc == null) break;
                this._actor.broadcastPacket(new FlyToLocationPacket(this._actor, flyLoc, skill.getFlyType(), skill.getFlySpeed(), skill.getFlyDelay(), skill.getFlyAnimationSpeed()));
                break;
            }
            case WARP_BACK: 
            case WARP_FORWARD: {
                flyLoc = this._actor.getFlyLocation(this._actor, skill);
                if (flyLoc == null) break;
                this._actor.broadcastPacket(new FlyToLocationPacket(this._actor, flyLoc, skill.getFlyType(), skill.getFlyRadius() / hitTime * 1000, skill.getFlyDelay(), skill.getFlyAnimationSpeed()));
            }
        }
        if (criticalBlow) {
            this._isCriticalBlow = true;
        }
        if (flyLoc != null) {
            this._flyLoc = flyLoc;
        }
        this._castLeftTime = hitTime - hitCancelTime;
        this._skillTask = ThreadPoolManager.getInstance().schedule(new MagicLaunchedTask(), hitCancelTime);
        if (skill.isChanneling()) {
            this._skillTickTask = ThreadPoolManager.getInstance().schedule(() -> this.onMagicTickTimer(), skill.getChannelingStart());
        }
        skill.onStartCast(skillEntry, this._actor, aimingTarget);
        this._actor.useTriggers(aimingTarget, TriggerType.ON_START_CAST, null, skill, 0.0);
        return true;
    }

    private void onMagicTickTimer() {
        double mpConsumeTick;
        SkillEntry skillEntry = this.getSkillEntry();
        if (skillEntry == null) {
            return;
        }
        Creature aimingTarget = this.getTarget();
        Skill skill = skillEntry.getTemplate();
        Set<Creature> targets = skill.getTargets(skillEntry, this._actor, aimingTarget, this._forceUse);
        this._targets = targets;
        if (!skill.isNotBroadcastable()) {
            this._actor.broadcastPacket(new MagicSkillLaunchedPacket(this._actor.getObjectId(), skillEntry.getDisplayId(), skillEntry.getDisplayLevel(), targets, this._castingType));
        }
        if ((mpConsumeTick = skill.getMpConsumeTick()) > 0.0) {
            if (skill.isMusic()) {
                double inc = mpConsumeTick / 2.0;
                double add = 0.0;
                for (Abnormal e : this._actor.getAbnormalList()) {
                    if (e.getSkill().getId() == skillEntry.getId() || !e.getSkill().isMusic() || e.getTimeLeft() <= 30) continue;
                    add += inc;
                }
                mpConsumeTick += add;
                mpConsumeTick = this._actor.getStat().calc(Stats.MP_DANCE_SKILL_CONSUME, mpConsumeTick, aimingTarget, skill);
            } else {
                mpConsumeTick = skill.isMagic() ? this._actor.getStat().calc(Stats.MP_MAGIC_SKILL_CONSUME, mpConsumeTick, aimingTarget, skill) : this._actor.getStat().calc(Stats.MP_PHYSICAL_SKILL_CONSUME, mpConsumeTick, aimingTarget, skill);
            }
            if (this._actor.getCurrentMp() < mpConsumeTick && this._actor.isPlayable()) {
                this._actor.sendPacket((IBroadcastPacket)SystemMsg.YOUR_SKILL_WAS_DEACTIVATED_DUE_TO_LACK_OF_MP);
                this._actor.broadcastPacket(new MagicSkillCanceled(this._actor.getObjectId()));
                this.onCastEndTime(false);
                return;
            }
            this._actor.reduceCurrentMp(mpConsumeTick, null);
        }
        skill.onTickCast(this._actor, targets);
        this._actor.useTriggers(aimingTarget, TriggerType.ON_TICK_CAST, null, skill, 0.0);
        if (skill.getTickInterval() > 0) {
            this._skillTickTask = ThreadPoolManager.getInstance().schedule(() -> this.onMagicTickTimer(), skill.getTickInterval());
        }
    }

    private void onMagicUseTimer() {
        double mpConsume2;
        int hpConsume;
        int fameConsume;
        SkillEntry skillEntry = this.getSkillEntry();
        Set<Creature> targets = this.getTargets();
        Creature aimingTarget = this.getTarget();
        if (skillEntry == null || targets == null) {
            this._actor.broadcastPacket(new MagicSkillCanceled(this._actor.getObjectId()));
            this.clearVars();
            return;
        }
        Skill skill = skillEntry.getTemplate();
        switch (skill.getFlyType()) {
            case CHARGE: 
            case WARP_BACK: 
            case WARP_FORWARD: {
                if (this._flyLoc == null) break;
                this._actor.setLoc(this._flyLoc);
            }
        }
        if (!skill.isDebuff() && this._actor.getAggressionTarget() != null) {
            this._forceUse = true;
        }
        skill.checkTargetsEffectiveRange(this._actor, targets);
        if (skill.oneTarget() && targets.isEmpty()) {
            this._actor.sendPacket((IBroadcastPacket)SystemMsg.THE_DISTANCE_IS_TOO_FAR_AND_SO_THE_CASTING_HAS_BEEN_STOPPED);
            this._actor.broadcastPacket(new MagicSkillCanceled(this._actor.getObjectId()));
            this.onCastEndTime(false);
            return;
        }
        if (!skillEntry.checkCondition(this._actor, aimingTarget, this._forceUse, false, false)) {
            if (skill.getSkillType() == Skill.SkillType.PET_SUMMON && this._actor.isPlayer()) {
                this._actor.getPlayer().setPetControlItem(null);
            }
            this._actor.broadcastPacket(new MagicSkillCanceled(this._actor.getObjectId()));
            this.onCastEndTime(false);
            return;
        }
        if (skill.getCastRange() != -2 && skill.getSkillType() != Skill.SkillType.TAKECASTLE && !GeoEngine.canSeeTarget(this._actor, aimingTarget)) {
            this._actor.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
            this._actor.broadcastPacket(new MagicSkillCanceled(this._actor.getObjectId()));
            this.onCastEndTime(false);
            return;
        }
        int clanRepConsume = skill.getClanRepConsume();
        if (clanRepConsume > 0) {
            this._actor.getPlayer().getClan().incReputation(-clanRepConsume, false, "clan skills");
        }
        if ((fameConsume = skill.getFameConsume()) > 0) {
            this._actor.getPlayer().setFame(this._actor.getPlayer().getFame() - fameConsume, "clan skills", true);
        }
        if ((hpConsume = skill.getHpConsume()) > 0) {
            this._actor.setCurrentHp(Math.max(0.0, this._actor.getCurrentHp() - (double)hpConsume), false);
        }
        if ((mpConsume2 = skill.getMpConsume2()) > 0.0) {
            if (skill.isMusic()) {
                double inc = mpConsume2 / 2.0;
                double add = 0.0;
                for (Abnormal e : this._actor.getAbnormalList()) {
                    if (e.getSkill().getId() == skill.getId() || !e.getSkill().isMusic() || e.getTimeLeft() <= 30) continue;
                    add += inc;
                }
                mpConsume2 += add;
                mpConsume2 = this._actor.getStat().calc(Stats.MP_DANCE_SKILL_CONSUME, mpConsume2, aimingTarget, skill);
            } else {
                mpConsume2 = skill.isMagic() ? this._actor.getStat().calc(Stats.MP_MAGIC_SKILL_CONSUME, mpConsume2, aimingTarget, skill) : this._actor.getStat().calc(Stats.MP_PHYSICAL_SKILL_CONSUME, mpConsume2, aimingTarget, skill);
            }
            if (this._actor.getCurrentMp() < mpConsume2 && this._actor.isPlayable()) {
                this._actor.sendPacket((IBroadcastPacket)SystemMsg.NOT_ENOUGH_MP);
                this._actor.broadcastPacket(new MagicSkillCanceled(this._actor.getObjectId()));
                this.onCastEndTime(false);
                return;
            }
            this._actor.reduceCurrentMp(mpConsume2, null);
        }
        this._actor.callSkill(aimingTarget, skillEntry, targets, true, false);
        if (this._actor.getIncreasedForce() > 0) {
            int decreasedForce = skill.getNumCharges();
            if (decreasedForce <= 0) {
                decreasedForce = skill.getCondCharges();
            }
            if (decreasedForce > 15) {
                decreasedForce = 5;
            }
            if (decreasedForce > 0) {
                this._actor.setIncreasedForce(this._actor.getIncreasedForce() - skill.getNumCharges());
            }
        }
        switch (skill.getFlyType()) {
            case THROW_UP: 
            case THROW_HORIZONTAL: 
            case PUSH_HORIZONTAL: 
            case PUSH_DOWN_HORIZONTAL: {
                for (Creature target : targets) {
                    Location flyLoc = target.getFlyLocation(this._actor, skill);
                    if (flyLoc == null) {
                        _log.warn(skill.getFlyType() + " have null flyLoc.");
                        continue;
                    }
                    target.broadcastPacket(new FlyToLocationPacket(target, flyLoc, skill.getFlyType(), skill.getFlySpeed(), skill.getFlyDelay(), skill.getFlyAnimationSpeed()));
                    target.setLoc(flyLoc);
                }
                break;
            }
            case DUMMY: {
                Location flyLoc;
                Creature dummyTarget = aimingTarget;
                if (skill.getTargetType() == Skill.SkillTargetType.TARGET_AURA) {
                    dummyTarget = this._actor;
                }
                if ((flyLoc = this._actor.getFlyLocation(dummyTarget, skill)) == null) break;
                this._actor.broadcastPacket(new FlyToLocationPacket(this._actor, flyLoc, skill.getFlyType(), skill.getFlySpeed(), skill.getFlyDelay(), skill.getFlyAnimationSpeed()));
                this._actor.setLoc(flyLoc);
            }
        }
        int skillCoolTime = 0;
        int chargeAddition = 0;
        if (skill.getFlyType() == FlyToLocationPacket.FlyType.CHARGE && skill.getFlySpeed() > 0) {
            chargeAddition = this._actor.getDistance(aimingTarget) / skill.getFlySpeed() * 1000;
        }
        if ((skillCoolTime = !skill.isSkillTimePermanent() ? Formulas.calcSkillCastSpd(this._actor, skill, skill.getCoolTime() + chargeAddition) : skill.getCoolTime() + chargeAddition) > 0) {
            ThreadPoolManager.getInstance().schedule(() -> this.onCastEndTime(true), skillCoolTime);
        } else {
            this.onCastEndTime(true);
        }
    }

    private void onCastEndTime(boolean success) {
        SkillEntry skillEntry = this.getSkillEntry();
        Creature target = this.getTarget();
        Set<Creature> targets = this.getTargets();
        this.clearVars();
        this._actor.onCastEndTime(skillEntry, target, targets, success);
    }

    private boolean canAbortCast() {
        return this._targets == null;
    }

    public boolean abortCast(boolean force) {
        SkillEntry skillEntry;
        if (this.isCastingNow() && (force || this.canAbortCast()) && (skillEntry = this.getSkillEntry()) != null && skillEntry.getTemplate().isAbortable()) {
            this.clearVars();
            return true;
        }
        return false;
    }

    private void clearVars() {
        this._isCastingNow.set(false);
        this._target = HardReferences.emptyRef();
        this._targets = null;
        this._forceUse = false;
        this._castLeftTime = 0;
        this._animationEndTime = 0L;
        this._skillEntry = null;
        this._isCriticalBlow = false;
        if (this._skillTask != null) {
            this._skillTask.cancel(false);
            this._skillTask = null;
        }
        if (this._skillTickTask != null) {
            this._skillTickTask.cancel(false);
            this._skillTickTask = null;
        }
        this._flyLoc = null;
    }

    private class MagicLaunchedTask
    implements Runnable {
        private MagicLaunchedTask() {
        }

        @Override
        public void run() {
            SkillEntry skillEntry = CreatureSkillCast.this.getSkillEntry();
            if (skillEntry == null) {
                return;
            }
            Creature target = CreatureSkillCast.this.getTarget();
            if (target == null) {
                return;
            }
            Set<Creature> targets = skillEntry.getTemplate().getTargets(skillEntry, CreatureSkillCast.this._actor, target, CreatureSkillCast.this._forceUse);
            CreatureSkillCast.this._targets = targets;
            if (!skillEntry.getTemplate().isNotBroadcastable()) {
                CreatureSkillCast.this._actor.broadcastPacket(new MagicSkillLaunchedPacket(CreatureSkillCast.this._actor.getObjectId(), skillEntry.getDisplayId(), skillEntry.getDisplayLevel(), targets, CreatureSkillCast.this._castingType));
            }
            if (CreatureSkillCast.this._castLeftTime > 0) {
                CreatureSkillCast.this._skillTask = ThreadPoolManager.getInstance().schedule(() -> CreatureSkillCast.this.onMagicUseTimer(), CreatureSkillCast.this._castLeftTime);
            } else {
                CreatureSkillCast.this.onMagicUseTimer();
            }
        }
    }
}

