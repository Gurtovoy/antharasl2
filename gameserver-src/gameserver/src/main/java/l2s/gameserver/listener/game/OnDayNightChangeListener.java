package l2s.gameserver.listener.game;

import l2s.gameserver.listener.GameListener;

public interface OnDayNightChangeListener
extends GameListener {
    public void onDay(boolean var1);

    public void onNight(boolean var1);
}

