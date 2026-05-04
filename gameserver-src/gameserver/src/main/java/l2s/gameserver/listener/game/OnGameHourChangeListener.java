package l2s.gameserver.listener.game;

import l2s.gameserver.listener.GameListener;

public interface OnGameHourChangeListener
extends GameListener {
    public void onChangeHour(int var1, boolean var2);
}

