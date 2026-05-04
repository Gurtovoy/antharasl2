package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.handler.admincommands.AdminCommandHandler;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class SendBypassBuildCmd
extends L2GameClientPacket {
    private String _command;

    @Override
    protected boolean readImpl() {
        this._command = this.readS();
        if (this._command != null) {
            this._command = this._command.trim();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        String cmd = this._command;
        if (!cmd.contains("admin_")) {
            cmd = "admin_" + cmd;
        }
        AdminCommandHandler.getInstance().useAdminCommandHandler(activeChar, cmd);
    }
}

