/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.ai;

import l2s.gameserver.ai.Fighter;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.instances.NpcInstance;

public class Guard
extends Fighter {
    public Guard(NpcInstance actor) {
        super(actor);
    }

    @Override
    public boolean canAttackCharacter(Creature target) {
        NpcInstance actor = this.getActor();
        if (target.isPlayable()) {
            return target.isPK() && (!actor.getParameter("evilGuard", false) || target.getPvpFlag() <= 0);
        }
        return false;
    }

    @Override
    public boolean checkTarget(Creature target, int range) {
        return super.checkTarget(target, range) && this.canAttackCharacter(target);
    }

    @Override
    protected boolean maybeMoveToHome(boolean force) {
        return this.returnHome(true);
    }
}

