/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

public class RequestExJoinDominionWar
extends L2GameClientPacket {
    @Override
    protected boolean readImpl() {
        this.readD();
        this.readD();
        this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

