package l2s.gameserver.listener.actor;

import l2s.gameserver.listener.CharListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Skill;

public interface OnCurrentHpDamageListener
extends CharListener {
    public void onCurrentHpDamage(Creature var1, double var2, Creature var4, Skill var5);
}

