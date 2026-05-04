/*
 * This file was originally decompiled from L2S rev.[31495].
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;
import org.apache.commons.lang3.StringUtils;

public class PrivateStoreBuyMsg
extends L2GameServerPacket {
    private int _objId;
    private String _name;

    public PrivateStoreBuyMsg(Player player, boolean showName) {
        this._objId = player.getObjectId();
        this._name = showName ? StringUtils.defaultString((String)player.getBuyStoreName()) : "";
    }

    @Override
    protected final void writeImpl() {
        this.writeD(this._objId);
        this.writeS(this._name);
    }
}

