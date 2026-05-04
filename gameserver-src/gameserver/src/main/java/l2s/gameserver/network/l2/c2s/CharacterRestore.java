/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.CharacterSelectionInfoPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class CharacterRestore
extends L2GameClientPacket {
    private int _charSlot;

    @Override
    protected boolean readImpl() {
        this._charSlot = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        GameClient client = (GameClient)this.getClient();
        try {
            client.markRestoredChar(this._charSlot);
        }
        catch (Exception e) {
            // empty catch block
        }
        CharacterSelectionInfoPacket cl = new CharacterSelectionInfoPacket(client);
        this.sendPacket((L2GameServerPacket)cl);
        client.setCharSelection(cl.getCharInfo());
    }
}

