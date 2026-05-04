package l2s.gameserver.ai;

import l2s.gameserver.Config;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.PlayableAI;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Playable;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.entity.events.impl.PvPEvent;
import l2s.gameserver.model.items.attachment.FlagItemAttachment;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;
import l2s.gameserver.network.l2.s2c.ExRotation;
import l2s.gameserver.network.l2.s2c.SocialActionPacket;
import l2s.gameserver.skills.EffectUseType;
import l2s.gameserver.skills.SkillCastingType;
import l2s.gameserver.skills.SkillEntry;

public class PlayerAI
extends PlayableAI {
    public PlayerAI(Player actor) {
        super(actor);
    }

    @Override
    protected void onEvtAttack(Creature target, Skill skill, int damage) {
        super.onEvtAttack(target, skill, damage);
        Player actor = this.getActor();
        if (target == null || actor.isDead()) {
            return;
        }
        if (damage > 0) {
            for (Servitor servitor : actor.getServitors()) {
                servitor.onOwnerOfAttacks(target);
            }
        }
    }

    @Override
    protected void onEvtAttacked(Creature attacker, Skill skill, int damage) {
        super.onEvtAttacked(attacker, skill, damage);
        Player actor = this.getActor();
        if (attacker == null || actor.isDead()) {
            return;
        }
        if (damage > 0) {
            for (Servitor servitor : actor.getServitors()) {
                servitor.onOwnerGotAttacked(attacker);
            }
        }
    }

    @Override
    protected void onIntentionRest() {
        this.changeIntention(CtrlIntention.AI_INTENTION_REST, null, null);
        this.setAttackTarget(null);
        this.clientStopMoving();
    }

    @Override
    protected void onIntentionActive() {
        this.clearNextAction();
        this.changeIntention(CtrlIntention.AI_INTENTION_ACTIVE, null, null);
    }

    @Override
    public void onIntentionInteract(GameObject object) {
        Player actor = this.getActor();
        if (actor.getSittingTask()) {
            this.setNextAction(PlayableAI.AINextAction.INTERACT, object, null, false, false);
            return;
        }
        if (actor.isSitting()) {
            actor.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_MOVE_WHILE_SITTING);
            this.clientActionFailed();
            return;
        }
        super.onIntentionInteract(object);
    }

    @Override
    public void onIntentionPickUp(GameObject object) {
        Player actor = this.getActor();
        if (actor.getSittingTask()) {
            this.setNextAction(PlayableAI.AINextAction.PICKUP, object, null, false, false);
            return;
        }
        if (actor.isSitting()) {
            actor.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_MOVE_WHILE_SITTING);
            this.clientActionFailed();
            return;
        }
        super.onIntentionPickUp(object);
    }

    @Override
    protected void thinkAttack(boolean arrived) {
        Player actor = this.getActor();
        if (actor.isInFlyingTransform()) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            return;
        }
        FlagItemAttachment attachment = actor.getActiveWeaponFlagAttachment();
        if (attachment != null && !attachment.canAttack(actor)) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            actor.sendActionFailed();
            return;
        }
        if (actor.isFrozen()) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            actor.sendPacket(SystemMsg.YOU_CANNOT_MOVE_WHILE_FROZEN, ActionFailPacket.STATIC);
            return;
        }
        super.thinkAttack(arrived);
    }

    @Override
    protected boolean thinkCast(boolean arrived) {
        Player actor = this.getActor();
        FlagItemAttachment attachment = actor.getActiveWeaponFlagAttachment();
        if (attachment != null && !attachment.canCast(actor, this._skillEntry.getTemplate())) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            actor.sendActionFailed();
            return false;
        }
        if (actor.isFrozen()) {
            this.setIntention(CtrlIntention.AI_INTENTION_ACTIVE);
            actor.sendPacket(SystemMsg.YOU_CANNOT_MOVE_WHILE_FROZEN, ActionFailPacket.STATIC);
            return false;
        }
        return super.thinkCast(arrived);
    }

    @Override
    protected void thinkCoupleAction(Player target, Integer socialId, boolean cancel) {
        Player actor = this.getActor();
        if (target == null || !target.isOnline()) {
            actor.sendPacket((IBroadcastPacket)SystemMsg.THE_COUPLE_ACTION_WAS_CANCELLED);
            return;
        }
        if (cancel || !actor.isInRange(target, 50) || actor.isInRange(target, 20) || actor.getReflection() != target.getReflection() || !GeoEngine.canSeeTarget(actor, target)) {
            target.sendPacket((IBroadcastPacket)SystemMsg.THE_COUPLE_ACTION_WAS_CANCELLED);
            actor.sendPacket((IBroadcastPacket)SystemMsg.THE_COUPLE_ACTION_WAS_CANCELLED);
            return;
        }
        if (this._forceUse) {
            target.getAI().setIntention(CtrlIntention.AI_INTENTION_COUPLE_ACTION, actor, socialId);
        }
        ThreadPoolManager.getInstance().schedule(() -> {
            int heading = actor.calcHeading(target.getX(), target.getY());
            actor.setHeading(heading);
            actor.broadcastPacket(new ExRotation(actor.getObjectId(), heading));
            actor.broadcastPacket(new SocialActionPacket(actor.getObjectId(), socialId));
        }, 500L);
    }

    @Override
    public void Attack(GameObject target, boolean forceUse, boolean dontMove) {
        Player actor = this.getActor();
        if (System.currentTimeMillis() - actor.getLastAttackPacket() < (long)Config.ATTACK_PACKET_DELAY) {
            actor.sendActionFailed();
            return;
        }
        actor.setLastAttackPacket();
        if (actor.getSittingTask()) {
            this.setNextAction(PlayableAI.AINextAction.ATTACK, target, null, forceUse, false);
            return;
        }
        if (actor.isSitting()) {
            actor.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_MOVE_WHILE_SITTING);
            this.clientActionFailed();
            return;
        }
        if (target instanceof Playable) {
            for (PvPEvent event : actor.getEvents(PvPEvent.class)) {
                if (event.checkForAttack((Creature)target, actor, null, forceUse) == null) continue;
                this.clientActionFailed();
                return;
            }
        }
        super.Attack(target, forceUse, dontMove);
    }

    @Override
    public boolean Cast(SkillEntry skillEntry, Creature target, boolean forceUse, boolean dontMove) {
        Skill castingSkill;
        Player actor = this.getActor();
        if (actor == null) {
            this.clientActionFailed();
            return false;
        }
        SkillEntry castingSkillEntry = actor.getSkillCast(SkillCastingType.NORMAL).getSkillEntry();
        if (castingSkillEntry != null && ((castingSkill = castingSkillEntry.getTemplate()).hasEffect(EffectUseType.NORMAL, "Transformation") || castingSkill.isToggle())) {
            this.clientActionFailed();
            return false;
        }
        castingSkillEntry = actor.getSkillCast(SkillCastingType.NORMAL_SECOND).getSkillEntry();
        if (castingSkillEntry != null && ((castingSkill = castingSkillEntry.getTemplate()).hasEffect(EffectUseType.NORMAL, "Transformation") || castingSkill.isToggle())) {
            this.clientActionFailed();
            return false;
        }
        Skill skill = skillEntry.getTemplate();
        if (!(skillEntry.isAltUse() || skill.isToggle() && skill.getHitTime() <= 0 || skill.getSkillType() == Skill.SkillType.CRAFT && Config.ALLOW_TALK_WHILE_SITTING)) {
            if (actor.getSittingTask()) {
                if (!skill.isHandler()) {
                    this.setNextAction(PlayableAI.AINextAction.CAST, skillEntry, target, forceUse, dontMove);
                    this.clientActionFailed();
                    return true;
                }
                this.clientActionFailed();
                return false;
            }
            if (skill.getSkillType() == Skill.SkillType.SUMMON && actor.getPrivateStoreType() != 0) {
                actor.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_SUMMON_DURING_A_TRADE_OR_WHILE_USING_A_PRIVATE_STORE);
                this.clientActionFailed();
                return false;
            }
            if (actor.isSitting()) {
                if (skill.hasEffect(EffectUseType.NORMAL, "Transformation")) {
                    actor.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TRANSFORM_WHILE_SITTING);
                } else {
                    actor.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_MOVE_WHILE_SITTING);
                }
                this.clientActionFailed();
                return false;
            }
        }
        return super.Cast(skillEntry, target, forceUse, dontMove);
    }

    @Override
    public Player getActor() {
        return (Player)super.getActor();
    }

    public boolean isFake() {
        return false;
    }
}

