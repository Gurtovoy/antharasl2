/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import java.util.Calendar;
import java.util.TimeZone;
import java.util.concurrent.TimeUnit;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExEnterWorldPacket
extends L2GameServerPacket {
    private final int _serverTime;
    private final int _utcTimeDiff;

    public ExEnterWorldPacket() {
        long currentTimeMillis = System.currentTimeMillis();
        this._serverTime = (int)TimeUnit.MILLISECONDS.toSeconds(currentTimeMillis);
        this._utcTimeDiff = (int)TimeUnit.MILLISECONDS.toMinutes(Calendar.getInstance(TimeZone.getTimeZone("UTC")).getTimeInMillis() - currentTimeMillis);
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._serverTime);
        this.writeD(this._utcTimeDiff);
        this.writeD(0);
    }
}

