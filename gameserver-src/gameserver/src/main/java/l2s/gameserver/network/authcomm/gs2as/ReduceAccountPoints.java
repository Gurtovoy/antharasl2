/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.authcomm.gs2as;

import l2s.gameserver.network.authcomm.SendablePacket;

public class ReduceAccountPoints
extends SendablePacket {
    private String account;
    private int count;

    public ReduceAccountPoints(String account, int count) {
        this.account = account;
        this.count = count;
    }

    @Override
    protected void writeImpl() {
        this.writeC(18);
        this.writeS(this.account);
        this.writeD(this.count);
    }
}

