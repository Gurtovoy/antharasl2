/*
 * Decompiled with CFR 0.152.
 * 
 * Could not load the following classes:
 *  org.apache.commons.lang3.StringUtils
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import org.apache.commons.lang3.StringUtils;

public class PrivateStoreMsg
extends L2GameServerPacket {
    private final int _objId;
    private final String _name;

    public PrivateStoreMsg(Player player, boolean showName) {
        this._objId = player.getObjectId();
        this._name = showName ? StringUtils.defaultString((String)player.getSellStoreName()) : "";
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objId);
        this.writeS(this._name);
    }
}

