/*
 * Decompiled with CFR 0.152.
 */
package l2s.authserver.network.gamecomm.as2gs;

import l2s.authserver.network.gamecomm.SendablePacket;

public class PingRequest
extends SendablePacket {
    @Override
    protected void writeImpl() {
        this.writeC(255);
    }
}

