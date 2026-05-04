/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.ai;

import l2s.gameserver.ai.DefaultAI;
import l2s.gameserver.model.instances.NpcInstance;

public class Priest
extends DefaultAI {
    public Priest(NpcInstance actor) {
        super(actor);
    }

    @Override
    protected boolean thinkActive() {
        return super.thinkActive() || this.defaultThinkBuff(2, 2);
    }

    @Override
    protected boolean createNewTask() {
        return this.defaultFightTask();
    }

    @Override
    public int getRatePHYS() {
        return 10;
    }

    @Override
    public int getRateDOT() {
        return 15;
    }

    @Override
    public int getRateDEBUFF() {
        return 15;
    }

    @Override
    public int getRateDAM() {
        return 30;
    }

    @Override
    public int getRateSTUN() {
        return 3;
    }

    @Override
    public int getRateBUFF() {
        return 10;
    }

    @Override
    public int getRateHEAL() {
        return 40;
    }
}

