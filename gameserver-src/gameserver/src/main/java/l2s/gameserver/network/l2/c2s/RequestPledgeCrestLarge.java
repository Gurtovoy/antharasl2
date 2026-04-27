/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  gnu.trove.map.TIntObjectMap
 */
package l2s.gameserver.network.l2.c2s;

import gnu.trove.map.TIntObjectMap;
import java.util.Arrays;
import l2s.gameserver.cache.CrestCache;
import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.GameClient;
import l2s.gameserver.network.l2.c2s.L2GameClientPacket;
import l2s.gameserver.network.l2.s2c.ExPledgeEmblem;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class RequestPledgeCrestLarge
extends L2GameClientPacket {
    private int _crestId;
    private int _pledgeId;

    @Override
    protected boolean readImpl() {
        this._crestId = this.readD();
        this._pledgeId = this.readD();
        return true;
    }

    @Override
    protected void runImpl() {
        Player activeChar = ((GameClient)this.getClient()).getActiveChar();
        if (activeChar == null) {
            return;
        }
        if (this._crestId == 0) {
            return;
        }
        if (this._pledgeId == 0) {
            return;
        }
        TIntObjectMap<byte[]> data = CrestCache.getInstance().getPledgeCrestLarge(this._crestId);
        if (data != null) {
            int totalSize = CrestCache.getByteMapSize(data);
            int[] keys = data.keys();
            Arrays.sort(keys);
            for (int key : keys) {
                this.sendPacket((L2GameServerPacket)new ExPledgeEmblem(this._pledgeId, this._crestId, key, totalSize, (byte[])data.get(key)));
            }
        }
    }
}

