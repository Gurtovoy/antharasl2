/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExPledgeBonusOpen;
import l2s.gameserver.utils.PledgeBonusUtils;

public class RequestPledgeBonusReward
extends L2GameClientPacket {
    private int _type;

    @Override
    protected boolean readImpl() {
        this._type = this.readC();
        return true;
    }

    @Override
    protected void runImpl() {
        if (!Config.EX_USE_PLEDGE_BONUS) {
            return;
        }
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (PledgeBonusUtils.tryReceiveReward(this._type, activeChar)) {
            activeChar.sendPacket((IBroadcastPacket)new ExPledgeBonusOpen(activeChar));
        }
    }
}

