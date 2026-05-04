/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.ActionFailPacket;

public class Action
extends L2GameClientPacket {
    private int _objectId;
    private int _actionId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this.readD();
        this.readD();
        this.readD();
        this._actionId = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (activeChar.isOutOfControl()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isInStoreMode()) {
            activeChar.sendActionFailed();
            return;
        }
        GameObject obj = activeChar.getVisibleObject(this._objectId);
        if (obj == null) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.setActive();
        if (activeChar.getAggressionTarget() != null && activeChar.getAggressionTarget() != obj) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isLockedTarget()) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isFrozen()) {
            activeChar.sendPacket(SystemMsg.YOU_CANNOT_MOVE_WHILE_FROZEN, ActionFailPacket.STATIC);
            return;
        }
        obj.onAction(activeChar, this._actionId == 1);
    }
}

