/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.StartRotatingPacket;

public class StartRotatingC
extends L2GameClientPacket {
    private int _degree;
    private int _side;

    @Override
    protected boolean readImpl() {
        this._degree = this.readD();
        this._side = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        activeChar.setHeading(this._degree);
        activeChar.broadcastPacket(new StartRotatingPacket(activeChar, this._degree, this._side, 0));
    }
}

