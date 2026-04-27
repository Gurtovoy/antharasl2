/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.ObservePoint;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.c2s.ValidatePosition;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;

public class MoveBackwardToLocation
extends L2GameClientPacket {
    private Location _targetLoc = new Location();
    private Location _originLoc = new Location();
    private boolean _keyboardMovement;

    @Override
    protected boolean readImpl() {
        this._targetLoc.x = this.readD();
        this._targetLoc.y = this.readD();
        this._targetLoc.z = this.readD();
        this._originLoc.x = this.readD();
        this._originLoc.y = this.readD();
        this._originLoc.z = this.readD();
        if (this._buf.hasRemaining()) {
            this._keyboardMovement = this.readD() == 0;
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._keyboardMovement && !Config.ALLOW_KEYBOARD_MOVE) {
            activeChar.sendActionFailed();
            return;
        }
        if (this._targetLoc.equals(this._originLoc)) {
            if (this._keyboardMovement) {
                activeChar.getMovement().stopMove();
            } else {
                activeChar.sendActionFailed();
            }
            return;
        }
        if (ValidatePosition.validatePosition(activeChar, this._originLoc.x, this._originLoc.y, this._originLoc.z, -1)) {
            return;
        }
        activeChar.setActive();
        if (System.currentTimeMillis() - activeChar.getLastMovePacket() < (long)Config.MOVE_PACKET_DELAY) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.setLastMovePacket();
        if (activeChar.isTeleporting()) {
            activeChar.sendActionFailed();
            return;
        }
        this._targetLoc.z = (int)((double)this._targetLoc.z + activeChar.getCollisionHeight());
        if (activeChar.isInObserverMode()) {
            ObservePoint observer = activeChar.getObservePoint();
            if (observer != null) {
                observer.getMovement().moveToLocation(this._targetLoc, 0, false);
            }
            return;
        }
        if (activeChar.isFrozen()) {
            activeChar.sendPacket(SystemMsg.YOU_CANNOT_MOVE_WHILE_FROZEN, ActionFailPacket.STATIC);
            return;
        }
        if (activeChar.isFishing()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_DO_THAT_WHILE_FISHING_2);
            return;
        }
        if (activeChar.isInTrainingCamp()) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_TAKE_OTHER_ACTION_WHILE_ENTERING_THE_TRAINING_CAMP);
            return;
        }
        if ((long)activeChar.getNpcDialogEndTime() > System.currentTimeMillis() / 1000L) {
            activeChar.sendPacket(SystemMsg.YOU_CANNOT_MOVE_WHILE_SPEAKING_TO_AN_NPC, ActionFailPacket.STATIC);
            return;
        }
        if (activeChar.isOutOfControl()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.getTeleMode() > 0) {
            if (activeChar.getTeleMode() == 1) {
                activeChar.setTeleMode(0);
            }
            activeChar.sendActionFailed();
            activeChar.teleToLocation(this._targetLoc);
            return;
        }
        if (activeChar.isInFlyingTransform()) {
            this._targetLoc.z = Math.min(5950, Math.max(50, this._targetLoc.z));
        }
        if (activeChar.getDistance(this._targetLoc) > 98010000) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.getMovement().moveToLocation(this._targetLoc, 0, !activeChar.getVarBoolean("no_pf"), true, this._keyboardMovement);
    }
}

