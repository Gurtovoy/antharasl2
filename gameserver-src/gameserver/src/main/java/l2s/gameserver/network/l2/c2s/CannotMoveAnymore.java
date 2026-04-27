/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.ai.CtrlEvent;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.ObservePoint;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class CannotMoveAnymore
extends L2GameClientPacket {
    protected final Location _loc = new Location();

    @Override
    protected boolean readImpl() {
        this._loc.x = this.readD();
        this._loc.y = this.readD();
        this._loc.z = this.readD();
        this._loc.h = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isInObserverMode()) {
            ObservePoint observer = activeChar.getObservePoint();
            if (observer != null) {
                observer.getMovement().stopMove();
            }
            return;
        }
        activeChar.getAI().notifyEvent(CtrlEvent.EVT_ARRIVED_BLOCKED, this._loc, null);
    }

    public static class Shuttle
    extends Boat {
    }

    public static class Vehicle
    extends Boat {
    }

    public static class AirShip
    extends Boat {
    }

    private static abstract class Boat
    extends CannotMoveAnymore {
        protected int _boatId = -1;

        private Boat() {
        }

        @Override
        protected boolean readImpl() {
            this._boatId = this.readD();
            this._loc.x = this.readD();
            this._loc.y = this.readD();
            this._loc.z = this.readD();
            this._loc.h = this.readD();
            return true;
        }

        @Override
        protected void runImpl() {
            Player activeChar = ((GameClient)this.getClient()).getActiveChar();
            if (activeChar == null) {
                return;
            }
            l2s.gameserver.model.entity.boat.Boat boat = activeChar.getBoat();
            if (boat != null && boat.getBoatId() == this._boatId) {
                activeChar.setInBoatPosition(this._loc);
                activeChar.setHeading(this._loc.h);
                activeChar.broadcastPacket(boat.inStopMovePacket(activeChar));
            }
        }
    }
}

