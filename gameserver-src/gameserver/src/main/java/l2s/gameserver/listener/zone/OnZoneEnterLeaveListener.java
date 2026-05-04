package l2s.gameserver.listener.zone;

import l2s.commons.listener.Listener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Zone;

public interface OnZoneEnterLeaveListener
extends Listener<Zone> {
    public void onZoneEnter(Zone var1, Creature var2);

    public void onZoneLeave(Zone var1, Creature var2);
}

