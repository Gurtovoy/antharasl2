/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.handler.usercommands.IUserCommandHandler;
import l2s.gameserver.handler.usercommands.UserCommandHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;

public class BypassUserCmd
extends L2GameClientPacket {
    private int _command;

    @Override
    protected boolean readImpl() {
        this._command = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        IUserCommandHandler handler = UserCommandHandler.getInstance().getUserCommandHandler(this._command);
        if (handler == null) {
            activeChar.sendMessage(new CustomMessage("common.S1NotImplemented").addString(String.valueOf(this._command)));
        } else {
            handler.useUserCommand(this._command, activeChar);
        }
    }
}

