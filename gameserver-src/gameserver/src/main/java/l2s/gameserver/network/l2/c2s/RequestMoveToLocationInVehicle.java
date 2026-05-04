package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.BoatHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestMoveToLocationInVehicle
extends L2GameClientPacket {
    private Location _pos = new Location();
    private Location _originPos = new Location();
    private int _boatObjectId;

    @Override
    protected boolean readImpl() {
        this._boatObjectId = this.readD();
        this._pos.x = this.readD();
        this._pos.y = this.readD();
        this._pos.z = this.readD();
        this._originPos.x = this.readD();
        this._originPos.y = this.readD();
        this._originPos.z = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Boat boat = BoatHolder.getInstance().getBoat(this._boatObjectId);
        if (boat == null) {
            player.sendActionFailed();
            return;
        }
        boat.moveInBoat(player, this._originPos, this._pos);
    }
}

