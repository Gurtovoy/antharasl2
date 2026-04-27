/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  l2s.commons.net.nio.impl.SendablePacket
 *  org.slf4j.Logger
 *  org.slf4j.LoggerFactory
 */
package l2s.authserver.network.l2.s2c;

import l2s.authserver.network.l2.L2LoginClient;
import l2s.commons.net.nio.impl.SendablePacket;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class L2LoginServerPacket
extends SendablePacket<L2LoginClient> {
    private static final Logger _log = LoggerFactory.getLogger(L2LoginServerPacket.class);

    public final boolean write() {
        try {
            this.writeImpl();
            return true;
        }
        catch (Exception e) {
            _log.error("Client: " + this.getClient() + " - Failed writing: " + ((Object)((Object)this)).getClass().getSimpleName() + "!", (Throwable)e);
            return false;
        }
    }

    protected abstract void writeImpl();
}

