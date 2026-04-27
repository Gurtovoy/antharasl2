/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.ai;

import java.util.concurrent.ScheduledFuture;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CharacterAI;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.FakePlayer;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.items.ItemInstance;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;
import l2s.gameserver.utils.PositionUtils;

public class PlayableAI
extends CharacterAI {
    private volatile int thinking = 0;
    protected Object _intention_arg0 = null;
    protected Object _intention_arg1 = null;
    protected SkillEntry _skillEntry;
    private AINextAction _nextAction;
    private Object _nextAction_arg0;
    private Object _nextAction_arg1;
    private boolean _nextAction_arg2;
    private boolean _nextAction_arg3;
    protected boolean _forceUse;
    private boolean _dontMove;
    private ScheduledFuture<?> _followTask;

    public PlayableAI(Playable actor) {
        super(actor);
    }

    @Override
    public void changeIntention(CtrlIntention intention, Object arg0, Object arg1) {
        super.changeIntention(intention, arg0, arg1);
        this._intention_arg0 = arg0;
        this._intention_arg1 = arg1;
    }

    @Override
    public void setIntention(CtrlIntention intention, Object arg0, Object arg1) {
        this._intention_arg0 = null;
        this._intention_arg1 = null;
        super.setIntention(intention, arg0, arg1);
    }

    @Override
    protected void onIntentionCast(SkillEntry skillEntry, Creature target) {
        this._skillEntry = skillEntry;
        super.onIntentionCast(skillEntry, target);
    }

    @Override
    public void setNextAction(AINextAction action, Object arg0, Object arg1, boolean arg2, boolean arg3) {
        this._nextAction = action;
        this._nextAction_arg0 = arg0;
        this._nextAction_arg1 = arg1;
        this._nextAction_arg2 = arg2;
        this._nextAction_arg3 = arg3;
    }

    public boolean setNextIntention() {
        SkillEntry skillEntry;
        AINextAction nextAction = this._nextAction;
        if (nextAction == null) {
            return false;
        }
        Object nextAction_arg0 = this._nextAction_arg0;
        Object nextAction_arg1 = this._nextAction_arg1;
        boolean nextAction_arg2 = this._nextAction_arg2;
        boolean nextAction_arg3 = this._nextAction_arg3;
        Playable actor = this.getActor();
        if (nextAction == AINextAction.CAST) {
            skillEntry = (SkillEntry)nextAction_arg0;
            if (actor.isActionsDisabled(false) || actor.getSkillCast(SkillCastingType.NORMAL).isCastingNow() && (!actor.isDualCastEnable() || actor.getSkillCast(SkillCastingType.NORMAL_SECOND).isCastingNow() || !skillEntry.getTemplate().isDouble())) {
                return false;
            }
        } else if (actor.isActionsDisabled()) {
            return false;
        }
        switch (nextAction) {
            case ATTACK: {
                if (nextAction_arg0 == null) {
                    return false;
                }
                Creature target = (Creature)nextAction_arg0;
                this._forceUse = nextAction_arg2;
                this._dontMove = nextAction_arg3;
                this.clearNextAction();
                this.setIntention(CtrlIntention.AI_INTENTION_ATTACK, target);
                break;
            }
            case CAST: {
                if (nextAction_arg0 == null || nextAction_arg1 == null) {
                    return false;
                }
                skillEntry = (SkillEntry)nextAction_arg0;
                Creature target = (Creature)nextAction_arg1;
                this._forceUse = nextAction_arg2;
                this._dontMove = nextAction_arg3;
                this.clearNextAction();
                if (!skillEntry.checkCondition(actor, target, this._forceUse, this._dontMove, true)) {
                    if (target.isAutoAttackable(actor) && skillEntry.getTemplate().getNextAction() == Skill.NextAction.ATTACK && !actor.equals(target)) {
                        this.setNextAction(AINextAction.ATTACK, target, null, this._forceUse, false);
                        return this.setNextIntention();
                    }
                    return false;
                }
                this.setIntention(CtrlIntention.AI_INTENTION_CAST, skillEntry, target);
                break;
            }
            case MOVE: {
                if (nextAction_arg0 == null || nextAction_arg1 == null) {
                    return false;
                }
                Location loc = (Location)nextAction_arg0;
                Integer offset = (Integer)nextAction_arg1;
                this.clearNextAction();
                actor.getMovement().moveToLocation(loc, offset, nextAction_arg2);
                break;
            }
            case REST: {
                actor.sitDown(null);
                break;
            }
            case INTERACT: {
                if (nextAction_arg0 == null) {
                    return false;
                }
                GameObject object = (GameObject)nextAction_arg0;
                this.clearNextAction();
                this.onIntentionInteract(object);
                break;
            }
            case PICKUP: {
                if (nextAction_arg0 == null) {
                    return false;
                }
                GameObject object = (GameObject)nextAction_arg0;
                this.clearNextAction();
                this.onIntentionPickUp(object);
                break;
            }
            case EQUIP: {
                if (!(nextAction_arg0 instanceof ItemInstance)) {
                    return false;
                }
                ItemInstance item = (ItemInstance)nextAction_arg0;
                if (item.isEquipable()) {
                    actor.useItem(item, nextAction_arg2, nextAction_arg3);
                }
                this.clearNextAction();
                if (this.getIntention() != CtrlIntention.AI_INTENTION_ATTACK) break;
                return false;
            }
            case COUPLE_ACTION: {
                if (nextAction_arg0 == null || nextAction_arg1 == null) {
                    return false;
                }
                Creature target = (Creature)nextAction_arg0;
                int socialId = (Integer)nextAction_arg1;
                this._forceUse = nextAction_arg2;
                this._nextAction = null;
                this.clearNextAction();
                this.onIntentionCoupleAction((Player)target, socialId);
                break;
            }
            default: {
                return false;
            }
        }
        return true;
    }

    @Override
    public void clearNextAction() {
        this._nextAction = null;
        this._nextAction_arg0 = null;
        this._nextAction_arg1 = null;
        this._nextAction_arg2 = false;
        this._nextAction_arg3 = false;
    }

    @Override
    public AINextAction getNextAction() {
        return this._nextAction;
    }

    @Override
    public Object[] getNextActionArgs() {
        return new Object[]{this._nextAction_arg0, this._nextAction_arg1};
    }

    @Override
    protected void onEvtFinishCasting(Skill skill, Creature target, boolean success) {
        if (!this.setNextIntention()) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        }
    }

    @Override
    protected void onEvtReadyToAct() {
        if (!this.setNextIntention()) {
            this.onEvtThink();
        }
    }

    @Override
    protected void onEvtArrived() {
        if (!this.setNextIntention()) {
            if (this.getIntention() == CtrlIntention.AI_INTENTION_ATTACK) {
                this.thinkAttack(true);
            } else if (this.getIntention() == CtrlIntention.AI_INTENTION_CAST) {
                this.thinkCast(true);
            } else if (this.getIntention() == CtrlIntention.AI_INTENTION_INTERACT) {
                this.thinkInteract(true);
            } else if (this.getIntention() == CtrlIntention.AI_INTENTION_FOLLOW) {
                this.thinkFollow();
            } else if (this.getIntention() == CtrlIntention.AI_INTENTION_PICK_UP) {
                this.onEvtThink();
            } else {
                this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
            }
        }
    }

    @Override
    protected void onEvtArrivedTarget() {
        switch (this.getIntention()) {
            case AI_INTENTION_ATTACK: {
                this.thinkAttack(true);
                break;
            }
            case AI_INTENTION_CAST: {
                this.thinkCast(true);
                break;
            }
            case AI_INTENTION_INTERACT: {
                this.thinkInteract(true);
                break;
            }
            case AI_INTENTION_FOLLOW: {
                this.thinkFollow();
                break;
            }
            default: {
                this.onEvtThink();
            }
        }
    }

    /*
     * WARNING - Removed try catching itself - possible behaviour change.
     * Enabled aggressive block sorting
     * Enabled unnecessary exception pruning
     * Enabled aggressive exception aggregation
     */
    @Override
    protected final void onEvtThink() {
        Playable actor = this.getActor();
        CtrlIntention intention = this.getIntention();
        if (intention == CtrlIntention.AI_INTENTION_CAST) {
            if (actor.isActionsDisabled(false)) return;
            if (actor.getSkillCast(SkillCastingType.NORMAL).isCastingNow()) {
                if (!actor.isDualCastEnable()) return;
                if (actor.getSkillCast(SkillCastingType.NORMAL_SECOND).isCastingNow()) {
                    return;
                }
            }
        } else if (actor.isActionsDisabled()) {
            return;
        }
        try {
            if (this.thinking++ > 1) {
                return;
            }
            switch (intention) {
                case AI_INTENTION_ACTIVE: {
                    this.thinkActive();
                    return;
                }
                case AI_INTENTION_ATTACK: {
                    this.thinkAttack(false);
                    return;
                }
                case AI_INTENTION_CAST: {
                    this.thinkCast(false);
                    return;
                }
                case AI_INTENTION_PICK_UP: {
                    this.thinkPickUp();
                    return;
                }
                case AI_INTENTION_INTERACT: {
                    this.thinkInteract(false);
                    return;
                }
                case AI_INTENTION_FOLLOW: {
                    this.thinkFollow();
                    return;
                }
                case AI_INTENTION_COUPLE_ACTION: {
                    this.thinkCoupleAction((Player)this._intention_arg0, (Integer)this._intention_arg1, false);
                    return;
                }
            }
            return;
        }
        catch (Exception e) {
            _log.error("", (Throwable)e);
            return;
        }
        finally {
            --this.thinking;
        }
    }

    protected void thinkActive() {
    }

    protected void thinkFollow() {
        int offset;
        Playable actor = this.getActor();
        Creature target = (Creature)this._intention_arg0;
        int n = offset = this._intention_arg1 instanceof Integer ? (Integer)this._intention_arg1 : -1;
        if (target == null || actor.getDistance(target) > 4000 || offset == -1 || actor.getReflection() != target.getReflection()) {
            this.clientActionFailed();
            return;
        }
        if (actor.getMovement().isFollow() && actor.getMovement().getFollowTarget() == target) {
            this.clientActionFailed();
            return;
        }
        if (actor.isInRange(target, offset + 16) || actor.isMovementDisabled()) {
            this.clientActionFailed();
        }
        if (this._followTask != null) {
            this._followTask.cancel(false);
            this._followTask = null;
        }
        this._followTask = ThreadPoolManager.getInstance().schedule(new ThinkFollow(), 250L);
    }

    @Override
    protected void onIntentionInteract(GameObject object) {
        Playable actor = this.getActor();
        if (actor.isActionsDisabled()) {
            this.setNextAction(AINextAction.INTERACT, object, null, false, false);
            this.clientActionFailed();
            return;
        }
        this.clearNextAction();
        this.changeIntention(CtrlIntention.AI_INTENTION_INTERACT, object, null);
        this.onEvtThink();
    }

    @Override
    protected void onIntentionCoupleAction(Player player, Integer socialId) {
        this._nextAction = null;
        this.clearNextAction();
        this.changeIntention(CtrlIntention.AI_INTENTION_COUPLE_ACTION, player, socialId);
        this.onEvtThink();
    }

    protected void thinkInteract(boolean arrived) {
        Playable actor = this.getActor();
        if (actor.isActionsDisabled()) {
            actor.sendActionFailed();
            return;
        }
        GameObject target = (GameObject)this._intention_arg0;
        if (target == null) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            return;
        }
        int range = actor.getInteractionDistance(target);
        if (actor.isInRangeZ(target, range + (arrived || actor.isMovementDisabled() ? 32 : 16))) {
            if (actor.isPlayer()) {
                ((Player)actor).doInteract(target);
            }
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        } else {
            actor.getMovement().moveToLocation(target.getLoc(), range, false);
            this.setNextAction(AINextAction.INTERACT, target, null, false, false);
        }
    }

    @Override
    protected void onIntentionPickUp(GameObject object) {
        Playable actor = this.getActor();
        if (actor.isActionsDisabled()) {
            this.setNextAction(AINextAction.PICKUP, object, null, false, false);
            this.clientActionFailed();
            return;
        }
        this.clearNextAction();
        this.changeIntention(CtrlIntention.AI_INTENTION_PICK_UP, object, null);
        this.onEvtThink();
    }

    protected void thinkPickUp() {
        Playable actor = this.getActor();
        GameObject target = (GameObject)this._intention_arg0;
        if (target == null) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            return;
        }
        if (actor.isInRange(target, 30) && Math.abs(actor.getZ() - target.getZ()) < 50) {
            if (actor.isPlayer() || actor.isPet()) {
                actor.doPickupItem(target);
            }
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
        } else {
            ThreadPoolManager.getInstance().execute(() -> {
                actor.getMovement().moveToLocation(target.getLoc(), 10, false);
                this.setNextAction(AINextAction.PICKUP, target, null, false, false);
            });
        }
    }

    protected void thinkAttack(boolean arrived) {
        Playable actor = this.getActor();
        Player player = actor.getPlayer();
        if (player == null) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            return;
        }
        if (actor.isActionsDisabled() || actor.isAttackingDisabled()) {
            actor.sendActionFailed();
            return;
        }
        boolean isPosessed = actor.isServitor() && ((Servitor)actor).isDepressed();
        Creature attack_target = this.getAttackTarget();
        if (attack_target == null || attack_target.isDead() || !isPosessed && !(!this._forceUse ? attack_target.isAutoAttackable(actor) : attack_target.isAttackable(actor))) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            actor.sendActionFailed();
            return;
        }
        int range = Math.max(10, actor.getPhysicalAttackRange()) + (int)actor.getMinDistance(attack_target);
        if (!actor.isInRangeZ(attack_target, range + (arrived || actor.isMovementDisabled() ? 32 : 16))) {
            if (this._dontMove) {
                actor.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
                this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                actor.sendActionFailed();
            } else if (!actor.getMovement().followToCharacter(attack_target, range, false)) {
                actor.getMovement().moveToLocation(attack_target.getLoc(), range, true, false, false);
            }
            return;
        }
        if (!GeoEngine.canSeeTarget(actor, attack_target)) {
            if (actor.isPlayer()) {
                actor.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
                this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                actor.sendActionFailed();
            } else if (!actor.getMovement().followToCharacter(attack_target, range, false) && !actor.getMovement().moveToLocation(attack_target.getLoc(), range, true, false, false)) {
                this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                actor.sendActionFailed();
            }
            return;
        }
        this.clientStopMoving();
        actor.doAttack(attack_target);
    }

    protected boolean thinkCast(boolean arrived) {
        boolean noRangeSkill;
        boolean isCorpseSkill;
        Playable actor = this.getActor();
        if (this._skillEntry == null) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            actor.sendActionFailed();
            return false;
        }
        Creature target = this.getCastTarget();
        Skill skill = this._skillEntry.getTemplate();
        if (skill.getSkillType() == Skill.SkillType.CRAFT || skill.isToggle() && skill.getHitTime() <= 0) {
            if (skill.checkCondition(this._skillEntry, actor, target, this._forceUse, this._dontMove, true)) {
                actor.doCast(this._skillEntry, target, this._forceUse);
            }
            return true;
        }
        if (target == null) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            actor.sendActionFailed();
            return false;
        }
        boolean bl = isCorpseSkill = skill.isCorpse() || skill.getTargetType() == Skill.SkillTargetType.TARGET_AREA_AIM_CORPSE;
        if (target.isDead() != isCorpseSkill && !skill.isNotTargetAoE()) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            actor.sendActionFailed();
            return false;
        }
        boolean isGroundSkill = skill.getTargetType() == Skill.SkillTargetType.TARGET_GROUND;
        Location targetLoc = target.getLoc();
        if (isGroundSkill) {
            if (actor.isPlayer()) {
                Location groundLoc = actor.getPlayer().getGroundSkillLoc();
                if (groundLoc == null) {
                    this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                    actor.sendActionFailed();
                    return false;
                }
                targetLoc = groundLoc;
            } else {
                this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                actor.sendActionFailed();
                return false;
            }
        }
        boolean bl2 = noRangeSkill = skill.getCastRange() == -1 || skill.getCastRange() == -2;
        if (!noRangeSkill) {
            boolean canSee;
            int range = Math.max(10, actor.getMagicalAttackRange(skill));
            if (!isGroundSkill) {
                range = (int)((double)range + actor.getMinDistance(target));
            }
            if (!actor.isInRangeZ(targetLoc, range + (arrived || actor.isMovementDisabled() ? 32 : 16))) {
                if (this._dontMove) {
                    if (!isGroundSkill) {
                        actor.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
                    }
                    this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                    actor.sendActionFailed();
                } else if (isGroundSkill || !actor.getMovement().followToCharacter(target, range, false)) {
                    actor.getMovement().moveToLocation(targetLoc, range, true, false, false);
                }
                return false;
            }
            boolean bl3 = canSee = isGroundSkill || skill.getSkillType() == Skill.SkillType.TAKECASTLE || GeoEngine.canSeeTarget(actor, target);
            if (!canSee) {
                if (actor.isPlayer()) {
                    if (!isGroundSkill) {
                        actor.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
                    }
                    this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                    actor.sendActionFailed();
                } else if (!actor.getMovement().followToCharacter(target, range, false) && !actor.getMovement().moveToLocation(targetLoc, range, true, false, false)) {
                    this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                    actor.sendActionFailed();
                }
                return false;
            }
        } else if (skill.getCastRange() == -1) {
            boolean canSee;
            boolean bl4 = canSee = isGroundSkill || skill.getSkillType() == Skill.SkillType.TAKECASTLE || GeoEngine.canSeeTarget(actor, target);
            if (!canSee) {
                if (!isGroundSkill) {
                    actor.sendPacket((IBroadcastPacket)SystemMsg.CANNOT_SEE_TARGET);
                }
                this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                actor.sendActionFailed();
                return false;
            }
        }
        if (actor.isFakeDeath()) {
            actor.breakFakeDeath();
        }
        if (target.isAutoAttackable(actor)) {
            if (skill.getNextAction() == Skill.NextAction.ATTACK && !actor.equals(target)) {
                this.setNextAction(AINextAction.ATTACK, target, null, this._forceUse, false);
            } else if (skill.getNextAction() == Skill.NextAction.CAST && !actor.equals(target)) {
                this.setNextAction(AINextAction.CAST, this._skillEntry, target, false, this._dontMove);
            } else {
                this.clearNextAction();
            }
        } else {
            this.clearNextAction();
        }
        if (skill.checkCondition(this._skillEntry, actor, target, this._forceUse, this._dontMove, true)) {
            this.clientStopMoving();
            actor.doCast(this._skillEntry, target, this._forceUse);
            return true;
        }
        this.setNextIntention();
        if (this.getIntention() == CtrlIntention.AI_INTENTION_ATTACK) {
            this.thinkAttack(true);
        }
        return false;
    }

    protected void thinkCoupleAction(Player target, Integer socialId, boolean cancel) {
    }

    @Override
    protected void onEvtDead(Creature killer) {
        this.clearNextAction();
        super.onEvtDead(killer);
    }

    @Override
    protected void onEvtFakeDeath() {
        this.clearNextAction();
        super.onEvtFakeDeath();
    }

    @Override
    public void Attack(GameObject target, boolean forceUse, boolean dontMove) {
        Playable actor = this.getActor();
        if (target.isCreature() && (actor.isActionsDisabled() || actor.isAttackingDisabled())) {
            this.setNextAction(AINextAction.ATTACK, target, null, forceUse, false);
            actor.sendActionFailed();
            return;
        }
        this._dontMove = dontMove;
        this._forceUse = forceUse;
        this.clearNextAction();
        this.setIntention(CtrlIntention.AI_INTENTION_ATTACK, target);
    }

    @Override
    public boolean Cast(SkillEntry skillEntry, Creature target, boolean forceUse, boolean dontMove) {
        Playable actor = this.getActor();
        Skill skill = skillEntry.getTemplate();
        if (skill.isCanUseWhileAbnormal() && (actor.isStunned() || actor.isSleeping() || actor.isDecontrolled() || actor.isFrozen())) {
            actor.altUseSkill(skillEntry, target);
            return true;
        }
        if (actor.getAbnormalList().contains(1570)) {
            this.clientActionFailed();
            return false;
        }
        if (skillEntry.isAltUse() || skill.isToggle() && skill.getHitTime() <= 0) {
            if (skill.isToggle() && !skill.checkCondition(skillEntry, actor, target, forceUse, dontMove, true)) {
                this.clientActionFailed();
                return false;
            }
            if ((skill.isToggle() || skill.isHandler()) && !skill.isCanUseWhileAbnormal() && (actor.isStunned() || actor.isSleeping() || actor.isDecontrolled() || actor.isFrozen())) {
                this.clientActionFailed();
                return false;
            }
            actor.altUseSkill(skillEntry, target);
            return true;
        }
        if (actor.isActionsDisabled(false) || actor.getSkillCast(SkillCastingType.NORMAL).isCastingNow() && (!actor.isDualCastEnable() || actor.getSkillCast(SkillCastingType.NORMAL_SECOND).isCastingNow() || !skill.isDouble())) {
            if (!skill.isHandler()) {
                this.setNextAction(AINextAction.CAST, skillEntry, target, forceUse, dontMove);
                this.clientActionFailed();
                return true;
            }
            this.clientActionFailed();
            return false;
        }
        this._forceUse = forceUse;
        this._dontMove = dontMove;
        this.clearNextAction();
        this.setIntention(CtrlIntention.AI_INTENTION_CAST, skillEntry, target);
        return true;
    }

    @Override
    public Playable getActor() {
        return (Playable)super.getActor();
    }

    protected class ExecuteFollow
    implements Runnable {
        private Creature _target;
        private Location _loc;
        private int _range;

        public ExecuteFollow(Creature target, int range) {
            this(target, null, range);
        }

        public ExecuteFollow(Creature target, Location loc, int range) {
            this._target = target;
            this._loc = loc;
            this._range = range;
        }

        @Override
        public void run() {
            if (this._loc != null) {
                PlayableAI.this._actor.getMovement().moveToLocation(this._loc, this._range, true, false, false);
            } else if (this._target.isDoor()) {
                PlayableAI.this._actor.getMovement().moveToLocation(this._target.getLoc(), 32, true, false, false);
            } else {
                PlayableAI.this._actor.getMovement().followToCharacter(this._target, this._range, false);
            }
        }
    }

    protected class ThinkFollow
    implements Runnable {
        protected ThinkFollow() {
        }

        @Override
        public void run() {
            int offset;
            Playable actor = PlayableAI.this.getActor();
            if (PlayableAI.this.getIntention() != CtrlIntention.AI_INTENTION_FOLLOW) {
                if (actor.isServitor() && PlayableAI.this.getIntention() == CtrlIntention.AI_INTENTION_ACTIVE) {
                    ((Servitor)actor).setFollowMode(false);
                }
                return;
            }
            if (!(PlayableAI.this._intention_arg0 instanceof Creature)) {
                PlayableAI.this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                return;
            }
            Creature target = (Creature)PlayableAI.this._intention_arg0;
            if (actor.getDistance(target) > 4000 || actor.getReflection() != target.getReflection()) {
                PlayableAI.this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                return;
            }
            Player player = actor.getPlayer();
            if (player == null || player.isLogoutStarted() || actor.isServitor() && !player.isMyServitor(actor.getObjectId())) {
                PlayableAI.this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
                return;
            }
            int n = offset = PlayableAI.this._intention_arg1 instanceof Integer ? (Integer)PlayableAI.this._intention_arg1 : 0;
            if (!(actor.isAfraid() || actor.isInRange(target, offset + 16) || actor.getMovement().isFollow() && actor.getMovement().getFollowTarget() == target)) {
                if (actor.isServitor()) {
                    int servitorsCount = actor.getPlayer().getServitorsCount();
                    if (servitorsCount > 1) {
                        int frontMaxRadius = 6000;
                        int heading = target.getHeading();
                        int radius = 6000 / (servitorsCount - 1) * (((Servitor)actor).getIndex() - 1) - 3000;
                        int x = (int)((double)target.getX() - (double)offset * Math.sin(PositionUtils.convertHeadingToRadian(radius + heading)));
                        int y = (int)((double)target.getY() + (double)offset * Math.cos(PositionUtils.convertHeadingToRadian(radius + heading)));
                        actor.getMovement().followToCharacter(new Location(x, y, target.getZ()), target, offset, false);
                    } else {
                        actor.getMovement().followToCharacter(target, offset, false);
                    }
                } else if (actor instanceof FakePlayer) {
                    Location loc = new Location(target.getX() + 30, target.getY() + 30, target.getZ());
                    actor.getMovement().followToCharacter(loc, target, offset, false);
                } else {
                    actor.getMovement().followToCharacter(target, offset, false);
                }
            }
            PlayableAI.this._followTask = ThreadPoolManager.getInstance().schedule(this, 250L);
        }
    }

    public static enum AINextAction {
        ATTACK,
        CAST,
        MOVE,
        REST,
        PICKUP,
        EQUIP,
        INTERACT,
        COUPLE_ACTION;

    }
}

