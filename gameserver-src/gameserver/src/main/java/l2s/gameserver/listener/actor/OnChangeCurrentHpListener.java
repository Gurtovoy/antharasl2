package l2s.gameserver.listener.actor;

import l2s.gameserver.listener.CharListener;
import l2s.gameserver.model.Creature;

public interface OnChangeCurrentHpListener
extends CharListener {
    public void onChangeCurrentHp(Creature var1, double var2, double var4);
}

