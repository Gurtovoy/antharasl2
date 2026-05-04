/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.components.IBroadcastPacket;
import l2s.gameserver.network.l2.s2c.ExGetBookMarkInfoPacket;

public class RequestSaveBookMarkSlot
extends L2GameClientPacket {
    private String name;
    private String acronym;
    private int icon;

    @Override
    protected boolean readImpl() {
        this.name = this.readS(32);
        this.icon = this.readD();
        this.acronym = this.readS(4);
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar != null && activeChar.getBookMarkList().add(this.name, this.acronym, this.icon)) {
            activeChar.sendPacket((IBroadcastPacket)new ExGetBookMarkInfoPacket(activeChar));
        }
    }
}

