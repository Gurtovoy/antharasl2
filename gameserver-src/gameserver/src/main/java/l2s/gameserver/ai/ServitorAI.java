/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.ai;

import l2s.gameserver.Config;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.PlayableAI;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Servitor;
import l2s.gameserver.model.Skill;

public class ServitorAI
extends PlayableAI {
    public ServitorAI(Servitor actor) {
        super(actor);
    }

    @Override
    protected void thinkActive() {
        Servitor actor = this.getActor();
        this.clearNextAction();
        if (actor.isDepressed()) {
            this.setAttackTarget(actor.getPlayer());
            this.changeIntention(CtrlIntention.AI_INTENTION_ATTACK, actor.getPlayer(), null);
            this.thinkAttack(false);
        } else if (actor.isFollowMode()) {
            this.changeIntention(CtrlIntention.AI_INTENTION_FOLLOW, actor.getPlayer(), Config.FOLLOW_RANGE);
            this.thinkFollow();
        }
        super.thinkActive();
    }

    @Override
    protected void thinkAttack(boolean arrived) {
        Servitor actor = this.getActor();
        if (actor.isDepressed()) {
            this.setAttackTarget(actor.getPlayer());
        }
        super.thinkAttack(arrived);
    }

    @Override
    protected boolean thinkCast(boolean arrived) {
        if (super.thinkCast(arrived)) {
            this.setNextAction(PlayableAI.AINextAction.ATTACK, this.getAttackTarget(), null, this._forceUse, false);
            return true;
        }
        return false;
    }

    @Override
    protected void onEvtAttacked(Creature attacker, Skill skill, int damage) {
        super.onEvtAttacked(attacker, skill, damage);
        Servitor actor = this.getActor();
        if (attacker == null || actor.isDead()) {
            return;
        }
        if (damage > 0) {
            actor.onAttacked(attacker);
            if (actor.getPlayer().isDead() && !actor.isDepressed()) {
                this.Attack(attacker, false, false);
            }
        }
    }

    @Override
    public Servitor getActor() {
        return (Servitor)super.getActor();
    }

    public void notifyAttackModeChange(Servitor.AttackMode mode) {
        this.getActor().setAttackMode(mode);
    }
}

