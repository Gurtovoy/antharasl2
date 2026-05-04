/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.data.BoatHolder;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.entity.boat.Boat;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestGetOnShuttle
extends L2GameClientPacket {
    private int _shuttleId;
    private Location _loc = new Location();

    @Override
    protected boolean readImpl() {
        this._shuttleId = this.readD();
        this._loc.x = this.readD();
        this._loc.y = this.readD();
        this._loc.z = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        Boat boat = BoatHolder.getInstance().getBoat(this._shuttleId);
        if (boat == null) {
            return;
        }
        boat.addPlayer(player, this._loc);
    }
}

