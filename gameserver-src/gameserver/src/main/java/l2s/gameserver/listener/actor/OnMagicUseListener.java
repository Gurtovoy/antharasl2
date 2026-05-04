package l2s.gameserver.listener.actor;

import l2s.gameserver.listener.CharListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;

public interface OnMagicUseListener
extends CharListener {
    public void onMagicUse(Creature var1, Skill var2, Creature var3, boolean var4);
}

