/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.c2s;

import l2s.gameserver.network.l2.c2s.L2GameClientPacket;

class SuperCmdCharacterInfo
extends L2GameClientPacket {
    private String _characterName;

    SuperCmdCharacterInfo() {
    }

    @Override
    protected boolean readImpl() {
        this._characterName = this.readS();
        return true;
    }

    @Override
    protected void runImpl() {
    }
}

