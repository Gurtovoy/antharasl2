/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

class SuperCmdServerStatus
extends L2GameClientPacket {
    SuperCmdServerStatus() {
    }

    @Override
    protected boolean readImpl() {
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

