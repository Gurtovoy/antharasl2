package l2s.gameserver.handler.onshiftaction;

import l2s.gameserver.model.Player;

public interface OnShiftActionHandler<T> {
    public boolean call(T var1, Player var2);
}

