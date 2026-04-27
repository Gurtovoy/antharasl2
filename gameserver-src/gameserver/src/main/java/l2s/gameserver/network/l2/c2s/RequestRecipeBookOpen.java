/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import l2s.gameserver.network.l2.s2c.RecipeBookItemListPacket;

public class RequestRecipeBookOpen
extends L2GameClientPacket {
    private boolean isDwarvenCraft;

    @Override
    protected boolean readImpl() {
        if (this._buf.hasRemaining()) {
            this.isDwarvenCraft = this.readD() == 0;
        }
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        this.sendPacket((L2GameServerPacket)new RecipeBookItemListPacket(activeChar, this.isDwarvenCraft));
    }
}

