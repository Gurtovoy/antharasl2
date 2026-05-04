/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import java.util.concurrent.CopyOnWriteArrayList;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.Request;
import l2s.gameserver.model.items.TradeItem;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.network.l2.s2c.TradeDonePacket;
import l2s.gameserver.network.l2.s2c.TradeStartPacket;

public class AnswerTradeRequest
extends L2GameClientPacket {
    private int _response;

    @Override
    protected boolean readImpl() {
        this._response = this.readD();
        return true;
    }

    
    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Request request = activeChar.getRequest();
        if (request == null) {
            activeChar.sendActionFailed();
            return;
        }
        if (request.isTypeOf(Request.L2RequestType.TRADE_REQUEST)) {
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
            if (requestor.getRequest() != request) {
                request.cancel(new IBroadcastPacket[0]);
                activeChar.sendActionFailed();
                return;
            }
            if (this._response == 0) {
                request.cancel(new IBroadcastPacket[0]);
                requestor.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_HAS_DENIED_YOUR_REQUEST_TO_TRADE).addString(activeChar.getName()));
                return;
            }
            if (!activeChar.checkInteractionDistance(requestor)) {
                request.cancel(new IBroadcastPacket[0]);
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOUR_TARGET_IS_OUT_OF_RANGE);
                return;
            }
            if (requestor.isActionsDisabled()) {
                request.cancel(new IBroadcastPacket[0]);
                activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_ON_ANOTHER_TASK).addString(requestor.getName()));
                activeChar.sendActionFailed();
                return;
            }
            if (requestor.isInTrainingCamp()) {
                request.cancel(new IBroadcastPacket[0]);
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.YOU_CANNOT_REQUEST_TO_A_CHARACTER_WHO_IS_ENTERING_THE_TRAINING_CAMP);
                activeChar.sendActionFailed();
                return;
            }
            try {
                new Request(Request.L2RequestType.TRADE, activeChar, requestor);
                requestor.setTradeList(new CopyOnWriteArrayList<TradeItem>());
                requestor.sendPacket(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.YOU_BEGIN_TRADING_WITH_C1).addString(activeChar.getName()), new TradeStartPacket(1, requestor, activeChar), new TradeStartPacket(2, requestor, activeChar)});
                activeChar.setTradeList(new CopyOnWriteArrayList<TradeItem>());
                activeChar.sendPacket(new IBroadcastPacket[]{new SystemMessagePacket(SystemMsg.YOU_BEGIN_TRADING_WITH_C1).addString(requestor.getName()), new TradeStartPacket(1, activeChar, requestor), new TradeStartPacket(2, activeChar, requestor)});
            }
            finally {
                request.done(new IBroadcastPacket[0]);
            }
        } else if (request.isTypeOf(Request.L2RequestType.TRADE)) {
            if (!request.isInProgress()) {
                request.cancel(TradeDonePacket.FAIL);
                activeChar.sendActionFailed();
                return;
            }
            if (activeChar.isOutOfControl()) {
                request.cancel(TradeDonePacket.FAIL);
                activeChar.sendActionFailed();
                return;
            }
            Player parthner = request.getOtherPlayer(activeChar);
            if (parthner == null) {
                request.cancel(TradeDonePacket.FAIL);
                activeChar.sendPacket((IBroadcastPacket)SystemMsg.THAT_PLAYER_IS_NOT_ONLINE);
                activeChar.sendActionFailed();
                return;
            }
            if (parthner.getRequest() != request) {
                request.cancel(TradeDonePacket.FAIL);
                activeChar.sendActionFailed();
                return;
            }
            request.cancel(TradeDonePacket.FAIL);
            parthner.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_HAS_CANCELLED_THE_TRADE).addString(activeChar.getName()));
        } else {
            request.cancel(new IBroadcastPacket[0]);
            activeChar.sendActionFailed();
            return;
        }
    }
}

