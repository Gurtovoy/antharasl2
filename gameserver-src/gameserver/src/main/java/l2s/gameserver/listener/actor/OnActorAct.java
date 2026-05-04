package l2s.gameserver.listener.actor;

import l2s.gameserver.listener.CharListener;
import l2s.gameserver.model.Creature;

public interface OnActorAct
extends CharListener {
    public void onAct(Creature var1, String var2, Object ... var3);
}

