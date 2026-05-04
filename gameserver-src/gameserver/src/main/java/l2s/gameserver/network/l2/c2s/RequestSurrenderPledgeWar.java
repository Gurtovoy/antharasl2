/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.Clan;
import l2s.gameserver.model.pledge.ClanWar;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.network.l2.s2c.SystemMessagePacket;
import l2s.gameserver.tables.ClanTable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public final class RequestSurrenderPledgeWar
extends L2GameClientPacket {
    private static final Logger _log = LoggerFactory.getLogger(RequestSurrenderPledgeWar.class);
    private String _pledgeName;

    @Override
    protected boolean readImpl() {
        this._pledgeName = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        Clan clan = activeChar.getClan();
        if (clan == null) {
            return;
        }
        Clan targetClan = ClanTable.getInstance().getClanByName(this._pledgeName);
        if (targetClan == null) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.THE_TARGET_FOR_DECLARATION_IS_WRONG);
            activeChar.sendActionFailed();
            return;
        }
        _log.info(this.getClass().getSimpleName() + ": by " + clan.getName() + " with " + this._pledgeName);
        if (!clan.isAtWarWith(targetClan.getClanId())) {
            activeChar.sendActionFailed();
            return;
        }
        activeChar.sendPacket((IBroadcastPacket)new SystemMessagePacket(SystemMsg.YOU_HAVE_SURRENDERED_TO_THE_S1_CLAN).addString(this._pledgeName));
        ClanWar war = clan.getWarWith(targetClan.getClanId());
        if (war != null) {
            war.setPeriod(ClanWar.ClanWarPeriod.PEACE);
        }
    }
}

