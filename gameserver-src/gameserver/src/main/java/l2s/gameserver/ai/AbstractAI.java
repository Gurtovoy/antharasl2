/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.ai;

import l2s.commons.lang.reference.HardReference;
import l2s.commons.lang.reference.HardReferences;
import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Skill;
import l2s.gameserver.model.instances.NpcInstance;
import l2s.gameserver.skills.SkillEntry;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class AbstractAI
implements Runnable {
    protected static final Logger _log = LoggerFactory.getLogger(AbstractAI.class);
    protected final Creature _actor;
    private HardReference<? extends Creature> _attackTarget = HardReferences.emptyRef();
    private HardReference<? extends Creature> _castTarget = HardReferences.emptyRef();
    private CtrlIntention _intention = CtrlIntention.AI_INTENTION_IDLE;

    protected AbstractAI(Creature actor) {
        this._actor = actor;
    }

    public void changeIntention(CtrlIntention intention, Object arg0, Object arg1) {
        this._intention = intention;
        if (intention != CtrlIntention.AI_INTENTION_CAST && intention != CtrlIntention.AI_INTENTION_ATTACK) {
            this.setAttackTarget(null);
        }
    }

    public final void setIntention(CtrlIntention intention) {
        this.setIntention(intention, null, null);
    }

    public final void setIntention(CtrlIntention intention, Object arg0) {
        this.setIntention(intention, arg0, null);
    }

    public void setIntention(CtrlIntention intention, Object arg0, Object arg1) {
        Creature actor;
        if (intention != CtrlIntention.AI_INTENTION_CAST && intention != CtrlIntention.AI_INTENTION_ATTACK) {
            this.setAttackTarget(null);
        }
        if (!(actor = this.getActor()).isVisible()) {
            if (this._intention == CtrlIntention.AI_INTENTION_IDLE) {
                return;
            }
            intention = CtrlIntention.AI_INTENTION_IDLE;
        }
        actor.getListeners().onAiIntention(intention, arg0, arg1);
        switch (intention) {
            case AI_INTENTION_IDLE: {
                this.onIntentionIdle();
                break;
            }
            case AI_INTENTION_ACTIVE: {
                this.onIntentionActive();
                break;
            }
            case AI_INTENTION_REST: {
                this.onIntentionRest();
                break;
            }
            case AI_INTENTION_ATTACK: {
                this.onIntentionAttack((Creature)arg0);
                break;
            }
            case AI_INTENTION_CAST: {
                this.onIntentionCast((SkillEntry)arg0, (Creature)arg1);
                break;
            }
            case AI_INTENTION_PICK_UP: {
                this.onIntentionPickUp((GameObject)arg0);
                break;
            }
            case AI_INTENTION_INTERACT: {
                this.onIntentionInteract((GameObject)arg0);
                break;
            }
            case AI_INTENTION_FOLLOW: {
                this.onIntentionFollow((Creature)arg0, (Integer)arg1);
                break;
            }
            case AI_INTENTION_COUPLE_ACTION: {
                this.onIntentionCoupleAction((Player)arg0, (Integer)arg1);
                break;
            }
            case AI_INTENTION_RETURN_HOME: {
                this.onIntentionReturnHome((Boolean)arg0);
                break;
            }
            case AI_INTENTION_WALKER_ROUTE: {
                this.onIntentionWalkerRoute();
            }
        }
    }

    public final void notifyEvent(CtrlEvent evt) {
        this.notifyEvent(evt, new Object[0]);
    }

    public final void notifyEvent(CtrlEvent evt, Object arg0) {
        this.notifyEvent(evt, new Object[]{arg0});
    }

    public final void notifyEvent(CtrlEvent evt, Object arg0, Object arg1) {
        this.notifyEvent(evt, new Object[]{arg0, arg1});
    }

    public final void notifyEvent(CtrlEvent evt, Object arg0, Object arg1, Object arg2) {
        this.notifyEvent(evt, new Object[]{arg0, arg1, arg2});
    }

    public void notifyEvent(CtrlEvent evt, Object[] args) {
        Creature actor = this.getActor();
        actor.getListeners().onAiEvent(evt, args);
        switch (evt) {
            case EVT_THINK: {
                this.onEvtThink();
                break;
            }
            case EVT_ATTACK: {
                this.onEvtAttack((Creature)args[0], (Skill)args[1], ((Number)args[2]).intValue());
                break;
            }
            case EVT_ATTACKED: {
                this.onEvtAttacked((Creature)args[0], (Skill)args[1], ((Number)args[2]).intValue());
                break;
            }
            case EVT_CLAN_ATTACKED: {
                this.onEvtClanAttacked((NpcInstance)args[0], (Creature)args[1], ((Number)args[2]).intValue());
                break;
            }
            case EVT_CLAN_DIED: {
                this.onEvtClanDied((NpcInstance)args[0], (Creature)args[1]);
                break;
            }
            case EVT_PARTY_ATTACKED: {
                this.onEvtPartyAttacked((NpcInstance)args[0], (Creature)args[1], ((Number)args[2]).intValue());
                break;
            }
            case EVT_PARTY_DIED: {
                this.onEvtPartyDied((NpcInstance)args[0], (Creature)args[1]);
                break;
            }
            case EVT_AGGRESSION: {
                this.onEvtAggression((Creature)args[0], ((Number)args[1]).intValue());
                break;
            }
            case EVT_READY_TO_ACT: {
                this.onEvtReadyToAct();
                break;
            }
            case EVT_ARRIVED: {
                this.onEvtArrived();
                break;
            }
            case EVT_ARRIVED_TARGET: {
                this.onEvtArrivedTarget();
                break;
            }
            case EVT_ARRIVED_BLOCKED: {
                this.onEvtArrivedBlocked((Location)args[0]);
                break;
            }
            case EVT_FORGET_OBJECT: {
                this.onEvtForgetObject((GameObject)args[0]);
                break;
            }
            case EVT_DEAD: {
                this.onEvtDead((Creature)args[0]);
                break;
            }
            case EVT_FAKE_DEATH: {
                this.onEvtFakeDeath();
                break;
            }
            case EVT_FINISH_CASTING: {
                this.onEvtFinishCasting((Skill)args[0], (Creature)args[1], (Boolean)args[2]);
                break;
            }
            case EVT_SEE_SPELL: {
                this.onEvtSeeSpell((Skill)args[0], (Creature)args[1], (Creature)args[2]);
                break;
            }
            case EVT_SPAWN: {
                this.onEvtSpawn();
                break;
            }
            case EVT_DESPAWN: {
                this.onEvtDeSpawn();
                break;
            }
            case EVT_DELETE: {
                this.onEvtDelete();
                break;
            }
            case EVT_TIMER: {
                this.onEvtTimer(((Number)args[0]).intValue(), args[1], args[2]);
                break;
            }
            case EVT_SCRIPT_EVENT: {
                this.onEvtScriptEvent(args[0].toString(), args[1], args[2]);
                break;
            }
            case EVT_MENU_SELECTED: {
                this.onEvtMenuSelected((Player)args[0], ((Number)args[1]).intValue(), ((Number)args[2]).intValue());
                break;
            }
            case EVT_KNOCK_DOWN: {
                this.onEvtKnockDown((Creature)args[0]);
                break;
            }
            case EVT_KNOCK_BACK: {
                this.onEvtKnockBack((Creature)args[0]);
                break;
            }
            case EVT_FLY_UP: {
                this.onEvtFlyUp((Creature)args[0]);
                break;
            }
            case EVT_TELEPORTED: {
                this.onEvtTeleported();
                break;
            }
            case EVT_SEE_CREATURE: {
                this.onEvtSeeCreatue((Creature)args[0]);
                break;
            }
            case EVT_DISAPPEAR_CREATURE: {
                this.onEvtDisappearCreatue((Creature)args[0]);
                break;
            }
            case EVT_FINISH_WALKER_ROUTE: {
                this.onEvtFinishWalkerRoute(((Number)args[0]).intValue());
                break;
            }
            case EVT_MOST_HATED_CHANGED: {
                this.onEvtMostHatedChanged();
                break;
            }
            case EVT_NO_DESIRE: {
                this.onEvtNoDesire();
            }
        }
    }

    protected void clientActionFailed() {
        Creature actor = this.getActor();
        if (actor != null && actor.isPlayer()) {
            actor.sendActionFailed();
        }
    }

    public void clientStopMoving() {
        Creature actor = this.getActor();
        actor.getMovement().stopMove();
    }

    public Creature getActor() {
        return this._actor;
    }

    public CtrlIntention getIntention() {
        return this._intention;
    }

    public void setAttackTarget(Creature target) {
        this._attackTarget = target == null ? HardReferences.emptyRef() : target.getRef();
    }

    public Creature getAttackTarget() {
        return (Creature)this._attackTarget.get();
    }

    public void setCastTarget(Creature target) {
        this._castTarget = target == null ? HardReferences.emptyRef() : target.getRef();
    }

    public Creature getCastTarget() {
        return (Creature)this._castTarget.get();
    }

    public boolean isGlobalAI() {
        return false;
    }

    @Override
    public void run() {
    }

    public String toString() {
        return this.getClass().getSimpleName() + " for " + this.getActor();
    }

    protected abstract void onIntentionIdle();

    protected abstract void onIntentionActive();

    protected abstract void onIntentionRest();

    protected abstract void onIntentionAttack(Creature var1);

    protected abstract void onIntentionCast(SkillEntry var1, Creature var2);

    protected abstract void onIntentionPickUp(GameObject var1);

    protected abstract void onIntentionInteract(GameObject var1);

    protected abstract void onIntentionCoupleAction(Player var1, Integer var2);

    protected abstract void onIntentionReturnHome(boolean var1);

    protected abstract void onEvtThink();

    protected abstract void onEvtAttack(Creature var1, Skill var2, int var3);

    protected abstract void onEvtAttacked(Creature var1, Skill var2, int var3);

    protected abstract void onEvtClanAttacked(NpcInstance var1, Creature var2, int var3);

    protected abstract void onEvtClanDied(NpcInstance var1, Creature var2);

    protected abstract void onEvtPartyAttacked(NpcInstance var1, Creature var2, int var3);

    protected abstract void onEvtPartyDied(NpcInstance var1, Creature var2);

    protected abstract void onEvtAggression(Creature var1, int var2);

    protected abstract void onEvtReadyToAct();

    protected abstract void onEvtArrived();

    protected abstract void onEvtArrivedTarget();

    protected abstract void onEvtTeleported();

    protected abstract void onEvtArrivedBlocked(Location var1);

    protected abstract void onEvtForgetObject(GameObject var1);

    protected abstract void onEvtDead(Creature var1);

    protected abstract void onEvtFakeDeath();

    protected abstract void onEvtFinishCasting(Skill var1, Creature var2, boolean var3);

    protected abstract void onEvtSeeSpell(Skill var1, Creature var2, Creature var3);

    protected abstract void onEvtSpawn();

    protected abstract void onEvtDeSpawn();

    protected abstract void onEvtDelete();

    protected abstract void onIntentionFollow(Creature var1, Integer var2);

    protected abstract void onEvtTimer(int var1, Object var2, Object var3);

    protected abstract void onEvtScriptEvent(String var1, Object var2, Object var3);

    protected abstract void onEvtMenuSelected(Player var1, int var2, int var3);

    protected abstract void onEvtKnockDown(Creature var1);

    protected abstract void onEvtKnockBack(Creature var1);

    protected abstract void onEvtFlyUp(Creature var1);

    protected abstract void onEvtSeeCreatue(Creature var1);

    protected abstract void onEvtDisappearCreatue(Creature var1);

    protected abstract void onIntentionWalkerRoute();

    protected void onEvtFinishWalkerRoute(int routeId) {
    }

    protected void onEvtMostHatedChanged() {
    }

    protected abstract void onEvtNoDesire();

    public boolean canAttackCharacter(Creature target) {
        return false;
    }
}

