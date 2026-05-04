package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.GameObjectsStorage;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestTargetActionMenu
extends L2GameClientPacket {
    private int _targetObjectId;

    @Override
    protected boolean readImpl() {
        this._targetObjectId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        GameObject target = GameObjectsStorage.findObject(this._targetObjectId);
        if (target == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (!target.isTargetable(activeChar)) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.getAggressionTarget() != null && activeChar.getAggressionTarget() != target) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.setTarget(target);
    }
}

