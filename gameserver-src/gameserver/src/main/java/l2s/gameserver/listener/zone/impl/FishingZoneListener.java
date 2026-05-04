package l2s.gameserver.listener.zone.impl;

import gnu.trove.map.TIntObjectMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import java.util.concurrent.ScheduledFuture;
import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.ThreadPoolManager;
import l2s.gameserver.listener.zone.OnZoneEnterLeaveListener;
import l2s.gameserver.model.Creature;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Zone;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExAutoFishAvailable;

public class FishingZoneListener
implements OnZoneEnterLeaveListener {
    public static final OnZoneEnterLeaveListener STATIC = new FishingZoneListener();
    private final TIntObjectMap<ScheduledFuture<?>> _notifyTasks = new TIntObjectHashMap();

    @Override
    public void onZoneEnter(Zone zone, Creature actor) {
        if (!actor.isPlayer()) {
            return;
        }
        if (this._notifyTasks.containsKey(actor.getObjectId())) {
            return;
        }
        this._notifyTasks.put(actor.getObjectId(), ThreadPoolManager.getInstance().scheduleAtFixedRate(new NotifyPacketTask(zone, actor.getPlayer()), 0L, 5000L));
    }

    @Override
    public void onZoneLeave(Zone zone, Creature actor) {
        if (!actor.isPlayer()) {
            return;
        }
        actor.sendPacket((IBroadcastPacket)ExAutoFishAvailable.REMOVE);
        this.stopAndRemoveNotifyTask(actor.getObjectId());
    }

    private void stopAndRemoveNotifyTask(int objectId) {
        ScheduledFuture notifyTask = (ScheduledFuture)this._notifyTasks.remove(objectId);
        if (notifyTask != null) {
            notifyTask.cancel(false);
        }
    }

    private class NotifyPacketTask
    implements Runnable {
        private final Zone _zone;
        private final int _objectId;
        private final HardReference<Player> _playerRef;

        public NotifyPacketTask(Zone zone, Player player) {
            this._zone = zone;
            this._objectId = player.getObjectId();
            this._playerRef = player.getRef();
        }

        @Override
        public void run() {
            Player player = (Player)this._playerRef.get();
            if (player == null) {
                FishingZoneListener.this.stopAndRemoveNotifyTask(this._objectId);
                return;
            }
            if (!player.isInZone(Zone.ZoneType.FISHING)) {
                player.sendPacket((IBroadcastPacket)ExAutoFishAvailable.REMOVE);
                FishingZoneListener.this.stopAndRemoveNotifyTask(player.getObjectId());
                return;
            }
            if (player.isFishing()) {
                player.sendPacket((IBroadcastPacket)ExAutoFishAvailable.FISHING);
            } else {
                player.sendPacket((IBroadcastPacket)ExAutoFishAvailable.SHOW);
            }
        }
    }
}

