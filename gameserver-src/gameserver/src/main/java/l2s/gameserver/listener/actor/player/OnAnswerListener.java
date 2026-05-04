package l2s.gameserver.listener.actor.player;

import l2s.gameserver.listener.PlayerListener;

public interface OnAnswerListener
extends PlayerListener {
    public void sayYes();

    public void sayNo();
}

