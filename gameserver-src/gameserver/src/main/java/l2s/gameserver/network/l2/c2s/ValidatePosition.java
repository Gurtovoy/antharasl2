package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ValidateLocationPacket;
import l2s.gameserver.utils.PositionUtils;

public class ValidatePosition
extends L2GameClientPacket {
    private static final int MAX_VALID_DIST = 1024;
    private int _clientX;
    private int _clientY;
    private int _clientZ;
    private int _clientHeading;
    private int _vehicle;
    private boolean _stopMove;

    @Override
    protected boolean readImpl() {
        this._clientX = this.readD();
        this._clientY = this.readD();
        this._clientZ = this.readD();
        this._clientHeading = this.readD();
        this._vehicle = this.readD();
        this._stopMove = this.readC() == 1;
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        ValidatePosition.validatePosition(activeChar, this._clientX, this._clientY, this._clientZ, this._clientHeading);
    }

    public static boolean validatePosition(Player player, int clientX, int clientY, int clientZ, int clientHeading) {
        if (player.isTeleporting() || player.isInObserverMode() || player.isFalling(clientZ)) {
            return false;
        }
        if (clientHeading >= 0) {
            player.setHeading(clientHeading);
        }
        if (!GeoEngine.hasGeo(player.getX(), player.getY(), player.getGeoIndex())) {
            player.setXYZ(player.getX(), player.getY(), clientZ, true);
        }
        if (!PositionUtils.checkIfInRange(1024, player.getX(), player.getY(), player.getZ(), clientX, clientY, clientZ, true)) {
            if (player.isInBoat()) {
                player.sendPacket((IBroadcastPacket)player.getBoat().validateLocationPacket(player));
            } else {
                player.sendPacket((IBroadcastPacket)new ValidateLocationPacket(player));
            }
            return true;
        }
        return false;
    }
}

