/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.data.xml.holder.EventHolder;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.World;
import l2s.gameserver.model.entity.events.EventType;
import l2s.gameserver.model.entity.events.impl.DuelEvent;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;

public class RequestDuelStart
extends L2GameClientPacket {
    private String _name;
    private int _duelType;

    @Override
    protected boolean readImpl() {
        this._name = this.readS(Config.CNAME_MAXLEN);
        this._duelType = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player player = ((GameClient)this.getClient()).getActiveChar();
        if (player == null) {
            return;
        }
        if (player.isActionsDisabled()) {
            player.sendActionFailed();
            return;
        }
        if (player.isProcessingRequest()) {
            player.sendPacket((IBroadcastPacket)SystemMsg.WAITING_FOR_ANOTHER_REPLY);
            return;
        }
        DuelEvent duelEvent = (DuelEvent)EventHolder.getInstance().getEvent(EventType.PVP_EVENT, this._duelType);
        if (duelEvent == null) {
            return;
        }
        Player target = World.getPlayer(this._name);
        if (target == null || target == player) {
            player.sendPacket((IBroadcastPacket)SystemMsg.THERE_IS_NO_OPPONENT_TO_RECEIVE_YOUR_CHALLENGE_FOR_A_DUEL);
            return;
        }
        if (!duelEvent.canDuel(player, target, true)) {
            return;
        }
        if (target.isBusy()) {
            player.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.C1_IS_ON_ANOTHER_TASK).addName(target));
            return;
        }
        duelEvent.askDuel(player, target, 0);
    }
}

