/*
 * Decompiled with CFR 0.152.
 */
package l2s.gameserver.network.l2.s2c;

import l2s.gameserver.model.Player;
import l2s.gameserver.model.actor.instances.player.PremiumItem;
import l2s.gameserver.network.l2.s2c.L2GameServerPacket;

public class ExGetPremiumItemListPacket
extends L2GameServerPacket {
    private final int _objectId;
    private final PremiumItem[] _list;

    public ExGetPremiumItemListPacket(Player activeChar) {
        this._objectId = activeChar.getObjectId();
        this._list = activeChar.getPremiumItemList().values();
    }

    @Override
    protected void writeImpl() {
        this.writeD(this._list.length);
        for (int i = 0; i < this._list.length; ++i) {
            this.writeD(i);
            this.writeD(this._objectId);
            this.writeD(this._list[i].getItemId());
            this.writeQ(this._list[i].getItemCount());
            this.writeD(0);
            this.writeS(this._list[i].getSender());
        }
    }
}

