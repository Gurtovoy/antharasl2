/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.BookMark;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExGetBookMarkInfoPacket;

public class RequestModifyBookMarkSlot
extends L2GameClientPacket {
    private String name;
    private String acronym;
    private int icon;
    private int slot;

    @Override
    protected boolean readImpl() {
        this.slot = this.readD();
        this.name = this.readS(32);
        this.icon = this.readD();
        this.acronym = this.readS(4);
        return true;
    }

    @Override
    protected void runImpl() {
        BookMark mark;
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar != null && (mark = activeChar.getBookMarkList().get(this.slot)) != null) {
            mark.setName(this.name);
            mark.setIcon(this.icon);
            mark.setAcronym(this.acronym);
            activeChar.sendPacket((IBroadcastPacket)new ExGetBookMarkInfoPacket(activeChar));
        }
    }
}

