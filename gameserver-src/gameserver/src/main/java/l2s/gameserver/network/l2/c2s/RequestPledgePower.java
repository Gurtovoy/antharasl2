/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ManagePledgePowerPacket;

public class RequestPledgePower
extends L2GameClientPacket {
    private int _rank;
    private int _action;
    private int _privs;

    @Override
    protected boolean readImpl() {
        this._rank = this.readD();
        this._action = this.readD();
        if (this._action == 2) {
            this._privs = this.readD();
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._action == 2) {
            if (this._rank < 1 || this._rank > 9) {
                return;
            }
            if (activeChar.getClan() != null && (activeChar.getClanPrivileges() & 0x10) == 16) {
                if (this._rank == 9) {
                    this._privs = (this._privs & 8) + (this._privs & 0x800) + (this._privs & 0x10000) + (this._privs & 0x1000) + (this._privs & 0x80000);
                }
                activeChar.getClan().setRankPrivs(this._rank, this._privs);
                activeChar.getClan().updatePrivsForRank(this._rank);
            }
        } else if (activeChar.getClan() != null) {
            activeChar.sendPacket((IBroadcastPacket)new ManagePledgePowerPacket(activeChar, this._action, this._rank));
        } else {
            activeChar.sendActionFailed();
        }
    }
}

