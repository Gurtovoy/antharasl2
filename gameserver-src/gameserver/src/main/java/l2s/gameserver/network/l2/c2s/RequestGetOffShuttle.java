package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.BoatHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestGetOffShuttle
extends L2GameClientPacket {
    private int _shuttleId;
    private Location _location = new Location();

    @Override
    protected boolean readImpl() {
        this._shuttleId = this.readD();
        this._location.x = this.readD();
        this._location.y = this.readD();
        this._location.z = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Boat boat = BoatHolder.getInstance().getBoat(this._shuttleId);
        if (boat == null || boat.getMovement().isMoving()) {
            player.sendActionFailed();
            return;
        }
        boat.oustPlayer(player, this._location, false);
    }
}

