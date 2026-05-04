package l2s.gameserver.listener.actor.player.impl;

import l2s.commons.lang.reference.HardReference;
import l2s.gameserver.geometry.ILocation;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.instancemanager.ReflectionManager;
import l2s.gameserver.listener.actor.player.OnAnswerListener;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class SummonAnswerListener
implements OnAnswerListener {
    private HardReference<Player> _playerRef;
    private Location _location;
    private long _count;

    public SummonAnswerListener(Player player, Location loc, long count) {
        this._playerRef = player.getRef();
        this._location = loc;
        this._count = count;
    }

    @Override
    public void sayYes() {
        Player player = (Player)this._playerRef.get();
        if (player == null) {
            return;
        }
        player.abortAttack(true, true);
        player.abortCast(true, true);
        player.getMovement().stopMove();
        if (this._count > 0L) {
            if (player.getInventory().destroyItemByItemId(8615, this._count)) {
                player.sendPacket((IBroadcastPacket)SystemMessagePacket.removeItems(8615, this._count));
                player.teleToLocation((ILocation)this._location, ReflectionManager.MAIN);
            } else {
                player.sendPacket((IBroadcastPacket)SystemMsg.INCORRECT_ITEM_COUNT);
            }
        } else {
            player.teleToLocation((ILocation)this._location, ReflectionManager.MAIN);
        }
    }

    @Override
    public void sayNo() {
    }
}

