/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.ai.PlayableAI;
import l2s.gameserver.geodata.GeoEngine;
import l2s.gameserver.geometry.Location;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.utils.PositionUtils;

public class AnswerCoupleAction
extends L2GameClientPacket {
    private int _charObjId;
    private int _actionId;
    private int _answer;

    @Override
    protected boolean readImpl() {
        this._actionId = this.readD();
        this._answer = this.readD();
        this._charObjId = this.readD();
        return true;
    }

    
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Request request = activeChar.getRequest();
        if (request == null || !request.isTypeOf(Request.L2RequestType.COUPLE_ACTION)) {
            return;
        }
        if (!request.isInProgress()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        if (activeChar.isOutOfControl()) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        Player requestor = request.getRequestor();
        if (requestor == null) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_ONLINE);
            activeChar.sendActionFailed();
            return;
        }
        if (requestor.getObjectId() != this._charObjId || requestor.getRequest() != request) {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
        switch (this._answer) {
            case -1: {
                requestor.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_SET_TO_REFUSE_COUPLE_ACTIONS_AND_CANNOT_BE_REQUESTED_FOR_A_COUPLE_ACTION).addName(activeChar));
                request.cancel(new IBroadcastPacket[0]);
                break;
            }
            case 0: {
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_COUPLE_ACTION_WAS_DENIED);
                requestor.sendPacket((IBroadcastPacket)SystemMsg.THE_COUPLE_ACTION_WAS_CANCELLED);
                requestor.sendActionFailed();
                request.cancel(new IBroadcastPacket[0]);
                break;
            }
            case 1: {
                try {
                    if (!AnswerCoupleAction.checkCondition(activeChar, requestor) || !AnswerCoupleAction.checkCondition(requestor, activeChar)) {
                        return;
                    }
                    Location loc = PositionUtils.applyOffset(activeChar, activeChar.getLoc(), 25);
                    loc = GeoEngine.moveCheck(requestor.getX(), requestor.getY(), requestor.getZ(), loc.x, loc.y, requestor.getGeoIndex());
                    if (loc == null) break;
                    requestor.getMovement().moveToLocation(loc, 0, false);
                    requestor.getAI().setNextAction(PlayableAI.AINextAction.COUPLE_ACTION, activeChar, this._actionId, true, false);
                    break;
                }
                finally {
                    request.done(new IBroadcastPacket[0]);
                }
            }
        }
    }

    private static boolean checkCondition(Player activeChar, Player requestor) {
        if (!activeChar.isInRange(requestor, 300) || activeChar.isInRange(requestor, 25) || !GeoEngine.canSeeTarget(activeChar, requestor)) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_REQUEST_CANNOT_BE_COMPLETED_BECAUSE_THE_TARGET_DOES_NOT_MEET_LOCATION_REQUIREMENTS);
            return false;
        }
        return activeChar.checkCoupleAction(requestor);
    }
}

