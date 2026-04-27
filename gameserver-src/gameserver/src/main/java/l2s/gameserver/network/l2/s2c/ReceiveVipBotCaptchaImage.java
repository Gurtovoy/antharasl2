/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ReceiveVipBotCaptchaImage
extends L2GameServerPacket {
    @Override
    protected final void writeImpl() {
        this.writeQ(0L);
        this.writeC(0);
        this.writeD(0);
    }
}

