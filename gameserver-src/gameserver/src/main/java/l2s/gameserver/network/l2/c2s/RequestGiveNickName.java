/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.Config;
import l2s.gameserver.model.Player;
import l2s.gameserver.model.pledge.UnitMember;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.CustomMessage;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.components.SystemMsg;
import l2s.gameserver.utils.Util;

public class RequestGiveNickName
extends L2GameClientPacket {
    private String _target;
    private String _title;

    @Override
    protected boolean readImpl() {
        this._target = this.readS(Config.CNAME_MAXLEN);
        this._title = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (!this._title.isEmpty() && !Util.isMatchingRegexp(this._title, Config.CLAN_TITLE_TEMPLATE)) {
            activeChar.sendMessage("Incorrect title.");
            return;
        }
        if ((activeChar.getClanPrivileges() & 4) != 4) {
            return;
        }
        if (activeChar.getClan().getLevel() < 3) {
            activeChar.sendPacket((IBroadcastPacket)SystemMsg.A_PLAYER_CAN_ONLY_BE_GRANTED_A_TITLE_IF_THE_CLAN_IS_LEVEL_3_OR_ABOVE);
            return;
        }
        UnitMember member = activeChar.getClan().getAnyMember(this._target);
        if (member != null) {
            member.setTitle(this._title);
            if (member.isOnline()) {
                member.getPlayer().sendPacket((IBroadcastPacket)SystemMsg.YOUR_TITLE_HAS_BEEN_CHANGED);
                member.getPlayer().sendChanges();
            }
        } else {
            activeChar.sendMessage(new CustomMessage("l2s.gameserver.network.l2.c2s.RequestGiveNickName.NotInClan"));
        }
    }
}

