package l2s.gameserver.listener.actions;

import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.model.Creature;

@FunctionalInterface
public interface OnArrivedAction {
    public void onArrived(Creature var1, ILocation var2, boolean var3);
}

