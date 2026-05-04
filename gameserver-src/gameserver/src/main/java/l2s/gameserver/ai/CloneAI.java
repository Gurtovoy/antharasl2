/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.ai;

import l2s.gameserver.Config;
import l2s.gameserver.ai.CtrlIntention;
import l2s.gameserver.ai.PlayableAI;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.FakePlayer;
import l2s.gameserver.model.Skill;

public class CloneAI
extends PlayableAI {
    public CloneAI(FakePlayer actor) {
        super(actor);
    }

    @Override
    protected void thinkActive() {
        FakePlayer actor = this.getActor();
        this.clearNextAction();
        this.changeIntention(CtrlIntention.AI_INTENTION_FOLLOW, actor.getPlayer(), Config.FOLLOW_RANGE);
        this.thinkFollow();
        super.thinkActive();
    }

    @Override
    protected void onEvtAttacked(Creature attacker, Skill skill, int damage) {
        FakePlayer actor = this.getActor();
        if (attacker == actor.getPlayer()) {
            return;
        }
        this.Attack(attacker, false, false);
        super.onEvtAttacked(attacker, skill, damage);
    }

    @Override
    public FakePlayer getActor() {
        return (FakePlayer)super.getActor();
    }
}

