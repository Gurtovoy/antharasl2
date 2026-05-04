/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Creature;
import l2s.gameserver.model.GameObject;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class AttackRequest
extends L2GameClientPacket {
    private int _objectId;
    private int _originX;
    private int _originY;
    private int _originZ;
    private int _attackId;

    @Override
    protected boolean readImpl() {
        this._objectId = this.readD();
        this._originX = this.readD();
        this._originY = this.readD();
        this._originZ = this.readD();
        this._attackId = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.setActive();
        if (activeChar.isOutOfControl()) {
            activeChar.sendActionFailed();
            return;
        }
        if (!activeChar.getPlayerAccess().CanAttack) {
            activeChar.sendActionFailed();
            return;
        }
        GameObject target = activeChar.getVisibleObject(this._objectId);
        if (target == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (!(target instanceof Creature)) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.getAggressionTarget() != null && activeChar.getAggressionTarget() != target && !activeChar.getAggressionTarget().isDead()) {
            activeChar.sendActionFailed();
            return;
        }
        if (target.isPlayer() && (activeChar.isInBoat() || target.isInBoat())) {
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.getTarget() != target || activeChar.isTransformed() && !activeChar.getTransform().isNormalAttackable()) {
            target.onAction(activeChar, this._attackId == 1);
            return;
        }
        if (target.getObjectId() != activeChar.getObjectId() && !activeChar.isInStoreMode() && !activeChar.isProcessingRequest()) {
            activeChar.getAI().Attack(target, true, this._attackId == 1);
        }
    }
}

