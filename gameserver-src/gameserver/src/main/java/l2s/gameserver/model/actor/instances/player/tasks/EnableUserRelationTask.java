/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.lang.reference.HardReference
 */
package l2s.gameserver.model.actor.instances.player.tasks;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.events.impl.SiegeEvent;

public class EnableUserRelationTask
implements Runnable {
    private HardReference<Player> _playerRef;
    private SiegeEvent<?, ?> _siegeEvent;

    public EnableUserRelationTask(Player player, SiegeEvent<?, ?> siegeEvent) {
        this._siegeEvent = siegeEvent;
        this._playerRef = player.getRef();
    }

    @Override
    public void run() {
        Player player = (Player)this._playerRef.get();
        if (player == null) {
            return;
        }
        this._siegeEvent.removeBlockFame(player);
        player.stopEnableUserRelationTask();
        player.broadcastUserInfo(true);
    }
}

